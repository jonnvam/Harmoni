import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
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
      'nombreIne': partes.sublist(0, partes.length - 2).join(' '),
      'apellidoPaternoIne': partes[partes.length - 2],
      'apellidoMaternoIne': partes[partes.length - 1],
    };
  }

  bool _coincidenNombres(String nombreIne, String textoCedula) {
    final ine = _normalizarTexto(nombreIne);
    final cedula = _normalizarTexto(textoCedula);

    if (ine.isEmpty || cedula.isEmpty) return false;

    return cedula.contains(ine) || ine.contains(cedula);
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
        .map((linea) => linea.trim())
        .where((linea) => linea.isNotEmpty)
        .toList();

    final indiceNombre = lineas.indexWhere(
      (linea) => linea.toUpperCase().contains('NOMBRE'),
    );

    if (indiceNombre != -1 && indiceNombre + 1 < lineas.length) {
      return _normalizarTexto(lineas[indiceNombre + 1]);
    }

    return '';
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
    if (_cedulaFrentePdf != null) return _cedulaFrentePdf!.path.split('\\').last;
    if (_cedulaFrente != null) return _cedulaFrente!.name;
    return 'Sin archivo seleccionado';
  }

  String _cedulaReversoSubtitle() {
    if (_cedulaReversoPdf != null) return _cedulaReversoPdf!.path.split('\\').last;
    if (_cedulaReverso != null) return _cedulaReverso!.name;
    return 'Sin archivo seleccionado';
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

    setState(() => _sending = true);

    try {
      final uid = user.uid;

      final tipoCedulaFrente = _cedulaFrentePdf != null ? 'PDF' : 'FOTO';
      final tipoCedulaReverso = _cedulaReversoPdf != null ? 'PDF' : 'FOTO';

      final partesNombre = _separarNombre(_nombreCompletoIne);

      final textoCedulaCompleto =
          '$_textoCedulaFrenteDetectado $_textoCedulaReversoDetectado';

      final coincideNombre = _coincidenNombres(
        _nombreCompletoIne,
        textoCedulaCompleto,
      );

      final coincideCedula = _cedulaDetectada.isNotEmpty;

      String estadoValidacion = 'RECHAZADO';
      bool requiereRevisionManual = true;
      String motivoRechazo = '';

      if (coincideNombre && coincideCedula) {
        estadoValidacion = 'PREVALIDADO';
        requiereRevisionManual = false;
      } else {
        motivoRechazo =
            'No se pudo confirmar coincidencia entre INE y cédula mediante OCR.';
      }

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
        'coincideNombre': coincideNombre,
        'coincideCedula': coincideCedula,
        'estadoValidacion': estadoValidacion,
        'puedeEjercer': false,
        'requiereRevisionManual': requiereRevisionManual,
        'motivoRechazo': motivoRechazo,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('usuariosPsicologos')
          .doc(uid)
          .set({
        'estadoValidacion': estadoValidacion,
        'puedeEjercer': false,
        'nombreLegal': _nombreCompletoIne,
        'nombreFuente': 'INE_OCR',
        'verificationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado: $estadoValidacion')),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verificacion profesional'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sube tus documentos para verificacion',
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
              const SizedBox(height: 16),
            ],
          ),
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
