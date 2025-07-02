import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

String generateOperationId() {
  return _uuid.v4();
} 