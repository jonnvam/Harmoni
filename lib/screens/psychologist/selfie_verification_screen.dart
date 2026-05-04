import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../services/face_embedding_service.dart';

class SelfieVerificationScreen extends StatefulWidget {
  final String ineFrontPath;

  const SelfieVerificationScreen({
    super.key,
    required this.ineFrontPath,
  });

  @override
  State<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends State<SelfieVerificationScreen> {
  CameraController? _controller;
  FaceDetector? _faceDetector;
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();

  bool _loading = true;
  bool _processing = false;
  String _message = 'Preparando cámara frontal...';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _embeddingService.loadModel();

      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _message = 'Coloca tu rostro al centro y toma la selfie.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _processing = false;
        _message = 'No se pudo iniciar la validación facial: $e';
      });
    }
  }

  Future<Face> _detectarUnRostro(File file, String origen) async {
    final detector = _faceDetector;

    if (detector == null) {
      throw Exception('Detector facial no inicializado.');
    }

    final inputImage = InputImage.fromFile(file);
    final faces = await detector.processImage(inputImage);

    if (faces.isEmpty) {
      throw Exception('No se detectó rostro en $origen.');
    }

    if (faces.length > 1) {
      throw Exception('Se detectó más de un rostro en $origen.');
    }

    return faces.first;
  }

  double _calcularLiveness({
    required double leftEye,
    required double rightEye,
    required double headY,
  }) {
    double score = 0.0;

    if (leftEye > 0.35) score += 0.35;
    if (rightEye > 0.35) score += 0.35;
    if (headY.abs() < 20) score += 0.30;

    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(2));
  }

  Future<void> _takeSelfieAndValidate() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      setState(() {
        _message = 'La cámara aún no está lista.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _processing = false;
        _message = 'Sesión expirada. Vuelve a iniciar sesión.';
      });
      return;
    }

    setState(() {
      _processing = true;
      _message = 'Comparando rostro de INE contra selfie...';
    });

    try {
      final ineFile = File(widget.ineFrontPath);

      if (!await ineFile.exists()) {
        throw Exception('No se encontró la imagen local de la INE.');
      }

      final selfiePicture = await controller.takePicture();
      final selfieFile = File(selfiePicture.path);

      final ineFace = await _detectarUnRostro(ineFile, 'INE');
      final selfieFace = await _detectarUnRostro(selfieFile, 'selfie');

      final leftEye = selfieFace.leftEyeOpenProbability ?? 0.0;
      final rightEye = selfieFace.rightEyeOpenProbability ?? 0.0;
      final headY = selfieFace.headEulerAngleY ?? 0.0;

      final livenessScore = _calcularLiveness(
        leftEye: leftEye,
        rightEye: rightEye,
        headY: headY,
      );

      final livenessPassed = livenessScore >= 0.70;

      if (!livenessPassed) {
        setState(() {
          _processing = false;
          _message =
              'No pasó prueba de vida. Mira al frente y abre bien los ojos.';
        });
        return;
      }

      final ineEmbedding = await _embeddingService.getEmbeddingFromFile(
        ineFile,
        faceBox: ineFace.boundingBox,
      );

      final selfieEmbedding = await _embeddingService.getEmbeddingFromFile(
        selfieFile,
        faceBox: selfieFace.boundingBox,
      );

      final faceMatchScore = _embeddingService.cosineSimilarity(
        ineEmbedding,
        selfieEmbedding,
      );

      String estadoValidacion;
      bool puedeEjercer;
      bool faceMatchPassed;
      bool requiereRevisionManual;
      String motivoRechazo = '';

      if (faceMatchScore >= 0.80) {
        estadoValidacion = 'VALIDADO_OFICIAL';
        puedeEjercer = true;
        faceMatchPassed = true;
        requiereRevisionManual = false;
      } else if (faceMatchScore >= 0.60) {
        estadoValidacion = 'PENDIENTE_REVISION_SELFIE';
        puedeEjercer = false;
        faceMatchPassed = false;
        requiereRevisionManual = true;
        motivoRechazo = 'La similitud facial requiere revisión manual.';
      } else {
        estadoValidacion = 'RECHAZADO_SELFIE';
        puedeEjercer = false;
        faceMatchPassed = false;
        requiereRevisionManual = true;
        motivoRechazo = 'La selfie no coincide con el rostro de la INE.';
      }

      await _guardarResultadoFaceMatch(
        uid: user.uid,
        estadoValidacion: estadoValidacion,
        puedeEjercer: puedeEjercer,
        requiereRevisionManual: requiereRevisionManual,
        motivoRechazo: motivoRechazo,
        livenessPassed: livenessPassed,
        livenessScore: livenessScore,
        faceMatchPassed: faceMatchPassed,
        faceMatchScore: faceMatchScore,
        leftEyeOpenProbability: leftEye,
        rightEyeOpenProbability: rightEye,
        headEulerAngleY: headY,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            estadoValidacion == 'VALIDADO_OFICIAL'
                ? 'Rostro validado correctamente.'
                : 'Resultado: $estadoValidacion',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('ERROR FACE MATCH: $e');

      if (!mounted) return;

      setState(() {
        _processing = false;
        _message = 'Error en face match: $e';
      });
    }
  }

  Future<void> _guardarResultadoFaceMatch({
    required String uid,
    required String estadoValidacion,
    required bool puedeEjercer,
    required bool requiereRevisionManual,
    required String motivoRechazo,
    required bool livenessPassed,
    required double livenessScore,
    required bool faceMatchPassed,
    required double faceMatchScore,
    required double leftEyeOpenProbability,
    required double rightEyeOpenProbability,
    required double headEulerAngleY,
  }) async {
    await FirebaseFirestore.instance
        .collection('verificacionesProfesionales')
        .doc(uid)
        .set({
      'selfieRealizada': true,
      'livenessPassed': livenessPassed,
      'livenessScore': livenessScore,
      'faceMatchPassed': faceMatchPassed,
      'faceMatchScore': faceMatchScore,
      'modeloFaceMatch': 'MOBILEFACENET_LOCAL',
      'selfieGuardada': false,
      'estadoValidacion': estadoValidacion,
      'puedeEjercer': puedeEjercer,
      'requiereRevisionManual': requiereRevisionManual,
      'motivoRechazo': motivoRechazo,
      'fechaSelfie': FieldValue.serverTimestamp(),
      'fechaFaceMatch': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'selfieAnalisis': {
        'rostrosDetectados': 1,
        'leftEyeOpenProbability': leftEyeOpenProbability,
        'rightEyeOpenProbability': rightEyeOpenProbability,
        'headEulerAngleY': headEulerAngleY,
        'metodo': 'MLKIT_FACE_DETECTION_PLUS_MOBILEFACENET',
      },
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('usuariosPsicologos')
        .doc(uid)
        .set({
      'estadoValidacion': estadoValidacion,
      'puedeEjercer': puedeEjercer,
      'verificationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector?.close();
    _embeddingService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Face match de verificación'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: controller != null && controller.value.isInitialized
                      ? CameraPreview(controller)
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _message,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black,
                  child: Column(
                    children: [
                      Text(
                        _message,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              _processing ? null : _takeSelfieAndValidate,
                          child: Text(
                            _processing
                                ? 'Comparando...'
                                : 'Tomar selfie y comparar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}