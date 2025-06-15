output "codebuild_badge_url" {
  description = "The badge URL for the Flutter build in AWS CodeBuild."
  value       = aws_codebuild_project.flutter_build.badge_url
}
