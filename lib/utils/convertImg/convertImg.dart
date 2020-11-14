import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart';

Image convertCameraImage(CameraImage image, CameraLensDirection _dir) {
  int width = image.width;
  int height = image.height;
  // imglib -> Image package from https://pub.dartlang.org/packages/image
  var img = Image(width, height); // Create Image buffer
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      // Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      img.data[index] = hexFF | (b << 16) | (g << 8) | r;
    }
  }
  var img1 = (_dir == CameraLensDirection.front)
      ? copyRotate(img, -90)
      : copyRotate(img, 90);
  return img1;
}

Image croppingImage(Face _face, Image convertedImage) {
  double x, y, w, h;
  x = (_face.boundingBox.left - 10);
  y = (_face.boundingBox.top - 10);
  w = (_face.boundingBox.width + 10);
  h = (_face.boundingBox.height + 10);
  Image croppedImage =
      copyCrop(convertedImage, x.round(), y.round(), w.round(), h.round());
  return copyResizeCropSquare(croppedImage, 112);
}
