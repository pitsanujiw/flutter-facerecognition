import 'package:uuid/uuid.dart';

Uuid uuid = Uuid();

String genId() {
  return uuid.v4();
}

