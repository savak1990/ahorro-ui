terraform {
  backend "s3" {
    bucket         = "ahorro-app-state"
    key            = "pipeline/ahorro-ui/android/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "ahorro-app-state-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Project   = "ahorro-app"
      Service   = "ahorro-ui-android-pipeline"
      Terraform = "true"
    }
  }
}

data "aws_secretsmanager_secret" "ahorro_app" {
  name = local.secret_name
}

data "aws_secretsmanager_secret_version" "ahorro_app" {
  secret_id = data.aws_secretsmanager_secret.ahorro_app.id
}

locals {
  project_name       = "ahorro-ui-android"
  github_owner       = "savak1990"
  github_repo        = "ahorro-ui"
  github_branch      = "main"
  artifact_bucket    = "ahorro-artifacts"
  secret_name        = "ahorro-app-secrets"
  github_oauth_token = jsondecode(data.aws_secretsmanager_secret_version.ahorro_app.secret_string)["github_token"]
}

resource "aws_codepipeline" "flutter_pipeline" {
  name     = "${local.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = local.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = local.github_owner
        Repo       = local.github_repo
        Branch     = local.github_branch
        OAuthToken = local.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Flutter_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.flutter_build.name
      }
    }
  }
}

resource "aws_codebuild_project" "flutter_build" {
  name         = "${local.project_name}-build"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "cirrusci/flutter:stable"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "pipeline/android/buildspec-android.yml"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.project_name}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_policy" "s3_artifacts" {
  name = "${local.project_name}-s3-artifacts-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ],
      Resource = [
        "arn:aws:s3:::${local.artifact_bucket}",
        "arn:aws:s3:::${local.artifact_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.s3_artifacts.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.s3_artifacts.arn
}

resource "aws_iam_policy" "codepipeline_codebuild" {
  name = "${local.project_name}-codebuild-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      Resource = aws_codebuild_project.flutter_build.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_codebuild" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild.arn
}

resource "aws_iam_policy" "codebuild_logs" {
  name = "${local.project_name}-codebuild-logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_logs_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logs.arn
}
