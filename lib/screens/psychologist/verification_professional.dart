import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerificacionProfesionalScreen extends StatefulWidget {
  const VerificacionProfesionalScreen({super.key});

  @override
  State<VerificacionProfesionalScreen> createState() => _VerificacionProfesionalScreenState();
}

class _VerificacionProfesionalScreenState extends State<VerificacionProfesionalScreen> {
  final _picker = ImagePicker();
  XFile? _ineFront;
  XFile? _ineBack;
  XFile? _cedula;
  bool _sending = false;

  String _extensionOf(XFile file) {
    final name = file.name;
    final dot = name.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    return name.substring(dot + 1).toLowerCase();
  }

  Future<void> _pickIneFront() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    setState(() => _ineFront = file);
  }

  Future<void> _pickIneBack() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    setState(() => _ineBack = file);
  }

  Future<void> _pickCedula() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    setState(() => _cedula = file);
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para continuar.')),
      );
      return;
    }
    if (_ineFront == null || _ineBack == null || _cedula == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sube INE frente, INE reverso y cedula profesional.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final uid = user.uid;
      final ineFrontExt = _extensionOf(_ineFront!);
      final ineBackExt = _extensionOf(_ineBack!);
      final cedulaExt = _extensionOf(_cedula!);

      final ineFrontRef = FirebaseStorage.instance.ref().child('documentos/$uid/ine_frente.$ineFrontExt');
      final ineBackRef = FirebaseStorage.instance.ref().child('documentos/$uid/ine_reverso.$ineBackExt');
      final cedulaRef = FirebaseStorage.instance.ref().child('documentos/$uid/cedula.$cedulaExt');

      await ineFrontRef.putFile(File(_ineFront!.path));
      await ineBackRef.putFile(File(_ineBack!.path));
      await cedulaRef.putFile(File(_cedula!.path));

      final ineFrontUrl = await ineFrontRef.getDownloadURL();
      final ineBackUrl = await ineBackRef.getDownloadURL();
      final cedulaUrl = await cedulaRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'ineFrontUrl': ineFrontUrl,
        'ineBackUrl': ineBackUrl,
        'cedulaUrl': cedulaUrl,
        'verificationStatus': 'pending',
        'verificationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documentos enviados. En revision.')),
      );
    } catch (e) {
      debugPrint('Verification submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar la verificacion.')),
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
        child: Padding(
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
              ),
              const SizedBox(height: 12),
              _DocTile(
                title: 'INE reverso',
                subtitle: _ineBack?.name ?? 'Sin archivo seleccionado',
                onPick: _pickIneBack,
              ),
              const SizedBox(height: 12),
              _DocTile(
                title: 'Cedula profesional',
                subtitle: _cedula?.name ?? 'Sin archivo seleccionado',
                onPick: _pickCedula,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sending ? null : _submit,
                  child: Text(_sending ? 'Enviando...' : 'Enviar'),
                ),
              ),
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

  const _DocTile({required this.title, required this.subtitle, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: OutlinedButton(
          onPressed: onPick,
          child: const Text('Subir'),
        ),
      ),
    );
  }
}
