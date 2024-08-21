import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import '../services/image_preprocessing.dart';
import '../services/model_inference.dart';
import '../services/postprocessing.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  Interpreter? _interpreter;
  bool _isTakingPicture = false;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _loadModel() async {
    _interpreter = await loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Just snap it! Allergen Analysis Software'),
      ),
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndPredict,
        child: const Icon(Icons.camera),
      ),
    );
  }

  Future<void> _takePictureAndPredict() async {
    if (_isTakingPicture) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait, processing previous picture...')),
      );
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      XFile? picture = await _controller?.takePicture();
      if (picture != null) {
        final image = File(picture.path);

        // Preprocess the image
        final img.Image preprocessedImage = await preprocessImage(image);

        // Convert to Float32List
        final inputImage = imageToByteListFloat32(
            preprocessedImage, 224); // Assuming 224x224 input size

        // Load the model
        final interpreter = _interpreter;
        if (interpreter == null) {
          print("Error: Model could not be loaded");
          return;
        }

        // Run inference
        final inferenceOutput =
            await runModelInference(interpreter, inputImage);

        // Postprocess the output
        if (inferenceOutput != null) {
          final result = postprocessOutput(inferenceOutput);
          await showResultDialog(context, result); // Show result in dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get prediction')),
          );
        }
      }
    } on CameraException catch (e) {
      if (e.code == 'takePictureBeforePreviousReturned') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please wait until the previous capture is done.')),
        );
      } else {
        print('CameraException: $e');
      }
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }
}
