import 'package:tflite_flutter/tflite_flutter.dart';

Future<Interpreter> loadModel() async {
  try {
    final gpuDelegateV2 = GpuDelegateV2(
        options: GpuDelegateOptionsV2(
      false,
      TfLiteGpuInferenceUsage.fastSingleAnswer,
      TfLiteGpuInferencePriority.minLatency,
      TfLiteGpuInferencePriority.auto,
      TfLiteGpuInferencePriority.auto,
    ));

    var interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegateV2);
    return await Interpreter.fromAsset('mobilefacenet.tflite',
        options: interpreterOptions);
  } on Exception {
    print('Failed to load model.');
    throw '';
  }
}
