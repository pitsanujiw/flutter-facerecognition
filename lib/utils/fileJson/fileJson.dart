//

import 'dart:io';

import 'package:facedetector/constants/constants.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getFileModel() async {
  Directory tempDir = await getApplicationDocumentsDirectory();
  String _embPath = tempDir.path + FilePath.pathModel;
  return new File(_embPath);
}
