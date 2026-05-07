import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
  }

  Future<List<double>> getEmbeddingFromFile(
    File file, {
    Rect? faceBox,
  }) async {
    await loadModel();

    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) {
      throw Exception('No se pudo leer la imagen.');
    }

    img.Image faceImage = original;

    if (faceBox != null) {
      final x = faceBox.left.clamp(0, original.width - 1).toInt();
      final y = faceBox.top.clamp(0, original.height - 1).toInt();
      final w = faceBox.width.clamp(1, original.width - x).toInt();
      final h = faceBox.height.clamp(1, original.height - y).toInt();

      faceImage = img.copyCrop(
        original,
        x: x,
        y: y,
        width: w,
        height: h,
      );
    }

    final resized = img.copyResize(
      faceImage,
      width: 112,
      height: 112,
    );

    final input = _imageToFloat32(resized);

    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final embeddingSize = outputShape.last;

    final output = List.generate(
      1,
      (_) => List<double>.filled(embeddingSize, 0.0),
    );

    _interpreter!.run(input, output);

    return _l2Normalize(output.first);
  }

  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    return [
      List.generate(112, (y) {
        return List.generate(112, (x) {
          final pixel = image.getPixel(x, y);

          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          return [
            (r - 127.5) / 128.0,
            (g - 127.5) / 128.0,
            (b - 127.5) / 128.0,
          ];
        });
      }),
    ];
  }

  List<double> _l2Normalize(List<double> vector) {
    final norm = sqrt(
      vector.fold<double>(0.0, (sum, value) => sum + value * value),
    );

    if (norm == 0) return vector;

    return vector.map((value) => value / norm).toList();
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Los embeddings no tienen el mismo tamaño.');
    }

    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;

    final score = dot / (sqrt(normA) * sqrt(normB));

    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(3));
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}