// model_inference.dart

import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

// Function to load the TensorFlow Lite model
Future<Interpreter?> loadModel() async {
  try {
    Interpreter interpreter =
        //get dataset from company. train ai model using python. export as tensorflowlite.
        await Interpreter.fromAsset(
            'assets/model.tflite'); //train model using datasets containing bread images and ingredient information.
    return interpreter;
  } catch (e) {
    print("Failed to load model: $e");
    return null;
  }
}

// Function to run inference
Future<List<double>?> runModelInference(
    Interpreter interpreter, Float32List inputImage) async {
  try {
    // Define the output tensor
    var output = List<double>.filled(
        2024, 0.0); // Adjust size based on your model's output

    // Run inference
    interpreter.run(inputImage.buffer.asFloat32List(), output);

    // Return the result
    return output;
  } catch (e) {
    print("Failed to run inference: $e");
    return null;
  }
}
