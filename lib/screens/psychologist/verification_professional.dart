import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'selfie_verification_screen.dart';
import 'validation_status_screen.dart';

class VerificacionProfesionalScreen extends StatefulWidget {
  const VerificacionProfesionalScreen({super.key});

  @override
  State<VerificacionProfesionalScreen> createState() =>
      _VerificacionProfesionalScreenState();
}

class _VerificacionProfesionalScreenState
    extends State<VerificacionProfesionalScreen> {
  final _picker = ImagePicker();

  static const String _apiValidacionUrl =
      'https://harmoni-production-27ae.up.railway.app;

  XFile? _ineFront;
  XFile? _ineBack;
  XFile? _cedulaFrente;
  XFile? _cedulaReverso;

  File? _cedulaFrentePdf;
  File? _cedulaReversoPdf;

  bool _sending = false;

  String _textoIneDetectado = '';
  String _textoCedulaFrenteDetectado = '';
  String _textoCedulaReversoDetectado = '';
  String _nombreCompletoIne = '';
  String _cedulaDetectada = '';

  String _normalizarTexto(String texto) {
    return texto
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
  }

  String _extraerCedulaProfesional(String texto) {
    final normalizado = _normalizarTexto(texto);
    final coincidencias = RegExp(r'\b\d{6,10}\b').allMatches(normalizado);

    if (coincidencias.isEmpty) return '';
    return coincidencias.first.group(0) ?? '';
  }

  Map<String, String> _separarNombre(String nombreCompleto) {
    final partes = _normalizarTexto(nombreCompleto)
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();

    if (partes.length < 3) {
      return {
        'nombreIne': nombreCompleto,
        'apellidoPaternoIne': '',
        'apellidoMaternoIne': '',
      };
    }

    return {
      'apellidoPaternoIne': partes[0],
      'apellidoMaternoIne': partes[1],
      'nombreIne': partes.sublist(2).join(' '),
    };
  }

  bool _coincidenNombres(String nombreIne, String textoCedula) {
    final ine = _normalizarTexto(nombreIne);
    final cedula = _normalizarTexto(textoCedula);

    if (ine.isEmpty || cedula.isEmpty) return false;

    return cedula.contains(ine) || ine.contains(cedula);
  }

  Future<Map<String, dynamic>?> _validarConBuhoLegal({
    required String uid,
    required String cedula,
    required String nombreCompletoIne,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiValidacionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'cedula': cedula,
          'nombreCompletoIne': nombreCompletoIne,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['ok'] != true) {
        debugPrint('Error API Búho: $data');
        return null;
      }

      return data['resultado'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error conectando API Búho: $e');
      return null;
    }
  }

  Future<void> _reiniciarVerificacion(String uid) async {
    await FirebaseFirestore.instance
        .collection('verificacionesProfesionales')
        .doc(uid)
        .set({
      'estadoValidacion': 'SIN_VERIFICAR',
      'puedeEjercer': false,
      'requiereRevisionManual': true,
      'motivoRechazo': '',
      'selfieRealizada': false,
      'livenessPassed': false,
      'faceMatchPassed': false,
      'faceMatchScore': 0.0,
      'modeloFaceMatch': '',
      'fechaActualizacion': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('usuariosPsicologos')
        .doc(uid)
        .set({
      'estadoValidacion': 'SIN_VERIFICAR',
      'puedeEjercer': false,
      'verificationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    setState(() {
      _ineFront = null;
      _ineBack = null;
      _cedulaFrente = null;
      _cedulaReverso = null;
      _cedulaFrentePdf = null;
      _cedulaReversoPdf = null;
      _textoIneDetectado = '';
      _textoCedulaFrenteDetectado = '';
      _textoCedulaReversoDetectado = '';
      _nombreCompletoIne = '';
      _cedulaDetectada = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificación reiniciada.')),
    );
  }

  void _limpiarArchivo(String tipo) {
    setState(() {
      if (tipo == 'ineFront') {
        _ineFront = null;
        _textoIneDetectado = '';
        _nombreCompletoIne = '';
      }

      if (tipo == 'ineBack') {
        _ineBack = null;
      }

      if (tipo == 'cedulaFrente') {
        _cedulaFrente = null;
        _cedulaFrentePdf = null;
        _textoCedulaFrenteDetectado = '';
        _cedulaDetectada = '';
      }

      if (tipo == 'cedulaReverso') {
        _cedulaReverso = null;
        _cedulaReversoPdf = null;
        _textoCedulaReversoDetectado = '';
      }
    });
  }

  Future<String> _leerTextoDesdeImagen(XFile file) async {
    final inputImage = InputImage.fromFile(File(file.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    return recognizedText.text;
  }

  String _extraerNombreDesdeIne(String texto) {
    final lineas = texto
        .split('\n')
        .map((linea) => _normalizarTexto(linea))
        .where((linea) => linea.isNotEmpty)
        .toList();

    final indiceNombre = lineas.indexWhere(
      (linea) => linea == 'NOMBRE' || linea.contains('NOMBRE'),
    );

    if (indiceNombre == -1) return '';

    final posibles = <String>[];

    for (int i = indiceNombre + 1;
        i < lineas.length && posibles.length < 4;
        i++) {
      final linea = lineas[i];

      if (linea.contains('DOMICILIO') ||
          linea.contains('CLAVE') ||
          linea.contains('CURP') ||
          linea.contains('FECHA') ||
          linea.contains('SEXO') ||
          linea.contains('ESTADO') ||
          linea.contains('MUNICIPIO') ||
          linea.contains('SECCION') ||
          linea.contains('LOCALIDAD') ||
          linea.contains('EMISION') ||
          linea.contains('VIGENCIA')) {
        break;
      }

      if (RegExp(r'\d').hasMatch(linea)) continue;
      if (linea.length < 3) continue;

      posibles.add(linea);
    }

    return posibles.join(' ').trim();
  }

  Future<void> _pickIneFront() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (!mounted || file == null) return;

    final texto = await _leerTextoDesdeImagen(file);
    final nombreDetectado = _extraerNombreDesdeIne(texto);

    setState(() {
      _ineFront = file;
      _textoIneDetectado = texto;
      _nombreCompletoIne = nombreDetectado;
    });
  }

  Future<void> _pickIneBack() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (!mounted || file == null) return;

    setState(() => _ineBack = file);
  }

  Future<void> _pickCedulaFrente() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto de cédula frente'),
                onTap: () async {
                  Navigator.pop(context);

                  final file = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );

                  if (!mounted || file == null) return;

                  final texto = await _leerTextoDesdeImagen(file);
                  final cedula = _extraerCedulaProfesional(texto);

                  setState(() {
                    _cedulaFrente = file;
                    _cedulaFrentePdf = null;
                    _textoCedulaFrenteDetectado = texto;
                    _cedulaDetectada = cedula;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Seleccionar PDF de cédula frente'),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (!mounted ||
                      result == null ||
                      result.files.single.path == null) {
                    return;
                  }

                  setState(() {
                    _cedulaFrentePdf = File(result.files.single.path!);
                    _cedulaFrente = null;
                    _textoCedulaFrenteDetectado = '';
                    _cedulaDetectada = '';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCedulaReverso() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto de cédula reverso'),
                onTap: () async {
                  Navigator.pop(context);

                  final file = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );

                  if (!mounted || file == null) return;

                  final texto = await _leerTextoDesdeImagen(file);

                  setState(() {
                    _cedulaReverso = file;
                    _cedulaReversoPdf = null;
                    _textoCedulaReversoDetectado = texto;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Seleccionar PDF de cédula reverso'),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (!mounted ||
                      result == null ||
                      result.files.single.path == null) {
                    return;
                  }

                  setState(() {
                    _cedulaReversoPdf = File(result.files.single.path!);
                    _cedulaReverso = null;
                    _textoCedulaReversoDetectado = '';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _cedulaFrenteSubtitle() {
    if (_cedulaFrentePdf != null) {
      return _cedulaFrentePdf!.path.split('\\').last;
    }
    if (_cedulaFrente != null) return _cedulaFrente!.name;
    return 'Sin archivo seleccionado';
  }

  String _cedulaReversoSubtitle() {
    if (_cedulaReversoPdf != null) {
      return _cedulaReversoPdf!.path.split('\\').last;
    }
    if (_cedulaReverso != null) return _cedulaReverso!.name;
    return 'Sin archivo seleccionado';
  }

  Future<void> _abrirSelfieConFaceMatch() async {
    if (_ineFront == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelfieVerificationScreen(
          ineFrontPath: _ineFront!.path,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para continuar.')),
      );
      return;
    }

    if (_ineFront == null ||
        _ineBack == null ||
        (_cedulaFrente == null && _cedulaFrentePdf == null) ||
        (_cedulaReverso == null && _cedulaReversoPdf == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Captura INE frente, INE reverso, cédula frente y cédula reverso.',
          ),
        ),
      );
      return;
    }

    if (_nombreCompletoIne.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo detectar el nombre de la INE.'),
        ),
      );
      return;
    }

    if (_cedulaDetectada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo detectar la cédula profesional.'),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final uid = user.uid;

      final tipoCedulaFrente = _cedulaFrentePdf != null ? 'PDF' : 'FOTO';
      final tipoCedulaReverso = _cedulaReversoPdf != null ? 'PDF' : 'FOTO';

      final partesNombre = _separarNombre(_nombreCompletoIne);

      final textoCedulaCompleto =
          '$_textoCedulaFrenteDetectado $_textoCedulaReversoDetectado';

      final coincideNombreLocal = _coincidenNombres(
        _nombreCompletoIne,
        textoCedulaCompleto,
      );

      final coincideCedulaLocal = _cedulaDetectada.isNotEmpty;

      String estadoLocal = 'RECHAZADO';
      bool requiereRevisionManualLocal = true;
      String motivoRechazoLocal =
          'No se pudo confirmar coincidencia entre INE y cédula mediante OCR.';

      if (coincideNombreLocal && coincideCedulaLocal) {
        estadoLocal = 'PREVALIDADO';
        requiereRevisionManualLocal = false;
        motivoRechazoLocal = '';
      }

      final resultadoBuho = await _validarConBuhoLegal(
        uid: uid,
        cedula: _cedulaDetectada,
        nombreCompletoIne: _nombreCompletoIne,
      );

      final estadoFinal = resultadoBuho?['estadoValidacion'] ?? estadoLocal;

      await FirebaseFirestore.instance
          .collection('verificacionesProfesionales')
          .doc(uid)
          .set({
        'uid': uid,
        'nombreCompletoIne': _nombreCompletoIne,
        'nombreIne': partesNombre['nombreIne'] ?? '',
        'apellidoPaternoIne': partesNombre['apellidoPaternoIne'] ?? '',
        'apellidoMaternoIne': partesNombre['apellidoMaternoIne'] ?? '',
        'cedulaIngresada': _cedulaDetectada,
        'textoIneDetectado': _textoIneDetectado,
        'textoCedulaFrenteDetectado': _textoCedulaFrenteDetectado,
        'textoCedulaReversoDetectado': _textoCedulaReversoDetectado,
        'ocrIneRealizado': _textoIneDetectado.isNotEmpty,
        'ocrCedulaFrenteRealizado': _textoCedulaFrenteDetectado.isNotEmpty,
        'ocrCedulaReversoRealizado': _textoCedulaReversoDetectado.isNotEmpty,
        'tipoCedulaFrente': tipoCedulaFrente,
        'tipoCedulaReverso': tipoCedulaReverso,
        'coincideNombre':
            resultadoBuho?['coincideNombre'] ?? coincideNombreLocal,
        'coincideCedula':
            resultadoBuho?['coincideCedula'] ?? coincideCedulaLocal,
        'esPsicologia': resultadoBuho?['esPsicologia'] ?? false,
        'nombreBuholegal': resultadoBuho?['nombreBuholegal'] ?? '',
        'cedulaBuholegal': resultadoBuho?['cedulaBuholegal'] ?? '',
        'carreraBuholegal': resultadoBuho?['carreraBuholegal'] ?? '',
        'institucionBuholegal':
            resultadoBuho?['institucionBuholegal'] ?? '',
        'fuentePrevalidacion':
            resultadoBuho?['fuentePrevalidacion'] ?? 'OCR_LOCAL',
        'estadoValidacion': estadoFinal,
        'puedeEjercer': false,
        'requiereRevisionManual': resultadoBuho?['requiereRevisionManual'] ??
            requiereRevisionManualLocal,
        'motivoRechazo': resultadoBuho == null
            ? 'No se pudo validar con Búho Legal. Se usó validación local OCR.'
            : (resultadoBuho['motivoRechazo'] ?? motivoRechazoLocal),
        'selfieRealizada': false,
        'livenessPassed': false,
        'faceMatchPassed': false,
        'faceMatchScore': 0.0,
        'modeloFaceMatch': '',
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('usuariosPsicologos')
          .doc(uid)
          .set({
        'estadoValidacion': estadoFinal,
        'puedeEjercer': false,
        'nombreLegal': _nombreCompletoIne,
        'nombreFuente': 'INE_OCR',
        'verificationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      if (estadoFinal == 'PREVALIDADO') {
        await _abrirSelfieConFaceMatch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado: $estadoFinal')),
        );
      }
    } catch (e) {
      debugPrint('Verification submit error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar la verificación.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _formularioDocumentos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sube tus documentos para verificación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _DocTile(
            title: 'INE frente',
            subtitle: _ineFront?.name ?? 'Sin archivo seleccionado',
            onPick: _pickIneFront,
            onClear: () => _limpiarArchivo('ineFront'),
          ),
          if (_nombreCompletoIne.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Nombre detectado: $_nombreCompletoIne',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _DocTile(
            title: 'INE reverso',
            subtitle: _ineBack?.name ?? 'Sin archivo seleccionado',
            onPick: _pickIneBack,
            onClear: () => _limpiarArchivo('ineBack'),
          ),
          const SizedBox(height: 12),
          _DocTile(
            title: 'Cédula profesional frente',
            subtitle: _cedulaFrenteSubtitle(),
            onPick: _pickCedulaFrente,
            onClear: () => _limpiarArchivo('cedulaFrente'),
          ),
          if (_cedulaDetectada.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Cédula detectada: $_cedulaDetectada',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _DocTile(
            title: 'Cédula profesional reverso',
            subtitle: _cedulaReversoSubtitle(),
            onPick: _pickCedulaReverso,
            onClear: () => _limpiarArchivo('cedulaReverso'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? 'Enviando...' : 'Enviar'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ValidationStatusScreen(),
                  ),
                );
              },
              child: const Text('Ver estado de validación'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para continuar.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verificación profesional'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('verificacionesProfesionales')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final exists = snapshot.hasData && snapshot.data!.exists;
            final data = exists
                ? snapshot.data!.data() as Map<String, dynamic>
                : <String, dynamic>{};

            final estado = data['estadoValidacion'] ?? 'SIN_VERIFICAR';
            final motivo = data['motivoRechazo'] ?? '';

            if (estado == 'RECHAZADO' || estado == 'RECHAZADO_SELFIE') {
              return _EstadoSimple(
                icon: Icons.cancel,
                color: Colors.red,
                title: 'Verificación rechazada',
                message: motivo.toString().isNotEmpty
                    ? motivo.toString()
                    : 'Los datos enviados no pudieron ser validados.',
                buttonText: 'Intentar nuevamente',
                onPressed: () async {
                  await _reiniciarVerificacion(uid);
                },
              );
            }

            if (estado == 'PREVALIDADO') {
              return _EstadoSimple(
                icon: Icons.verified,
                color: Colors.blue,
                title: 'Documentos prevalidados',
                message:
                    'Tus documentos fueron validados con Búho Legal. Ahora finaliza con selfie.',
                buttonText: 'Ir a estado',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ValidationStatusScreen(),
                    ),
                  );
                },
              );
            }

            if (estado == 'PENDIENTE_REVISION_SELFIE') {
              return const _EstadoSimple(
                icon: Icons.pending_actions,
                color: Colors.orange,
                title: 'Revisión pendiente',
                message:
                    'La comparación facial requiere revisión manual antes de validar oficialmente el perfil.',
              );
            }

            if (estado == 'VALIDADO_OFICIAL') {
              return const _EstadoSimple(
                icon: Icons.check_circle,
                color: Colors.green,
                title: 'Validación completada',
                message:
                    'Tu perfil profesional ya fue validado oficialmente.',
              );
            }

            return _formularioDocumentos();
          },
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = subtitle != 'Sin archivo seleccionado';

    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tieneArchivo && onClear != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onClear,
              ),
            OutlinedButton(
              onPressed: onPick,
              child: Text(tieneArchivo ? 'Cambiar' : 'Subir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoSimple extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _EstadoSimple({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  child: Text(buttonText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}