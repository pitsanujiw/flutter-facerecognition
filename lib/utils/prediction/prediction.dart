import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

import '../utils.dart';

List<dynamic> recogImage(imglib.Image img, Interpreter interpreter) {
  List input = imageToByteListFloat32(img, 112, 128, 128);
  input = input.reshape([1, 112, 112, 3]);
  List output = List(1 * 192).reshape([1, 192]);
  interpreter.run(input, output);
  output = output.reshape([192]);
  return List.from(output);
}
