// image_preprocessing.dart

import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

// Function to preprocess the image (resize and normalize)
Future<img.Image> preprocessImage(File imageFile) async {
  // Decode the image file into an image object
  img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;

  // Resize the image to 224x224 as required by the model
  img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  return resizedImage;
}

// Function to convert the image to a Float32List for TensorFlow Lite input
Float32List imageToByteListFloat32(img.Image image, int inputSize) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (img.getRed(pixel) / 255.0);
      buffer[pixelIndex++] = (img.getGreen(pixel) / 255.0);
      buffer[pixelIndex++] = (img.getBlue(pixel) / 255.0);
    }
  }
  return convertedBytes;
}
