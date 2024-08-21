import 'package:flutter/material.dart';

// My function to postprocess the output and show the top prediction
String postprocessOutput(List<double> output) {
  // Assuming the output is a list of probabilities, find the index of the highest probability
  int topPredictionIndex = output.indexWhere(
      (e) => e == output.reduce((curr, next) => curr > next ? curr : next));

  // Assuming you have a list of labels corresponding to the model's output
  // You need to load the label list here or pass it as a parameter
  List<String> labels = [
    'Label1',
    'Label2', /* Add all other labels */
  ];

  String topLabel = labels[topPredictionIndex];
  double confidence = output[topPredictionIndex];

  print('Detected: $topLabel with confidence $confidence');
  return 'Detected: $topLabel with confidence ${confidence.toStringAsFixed(2)}';
}

Future<void> showResultDialog(BuildContext context, String result) async {
  // Display the result
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Prediction"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
