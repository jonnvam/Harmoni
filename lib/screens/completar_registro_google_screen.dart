import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';
import 'package:flutter_application_1/screens/psychologist/verification_professional.dart';
import 'package:flutter_application_1/services/auth_google.dart';

class CompletarRegistroGoogleScreen extends StatefulWidget {
  const CompletarRegistroGoogleScreen({super.key});

  @override
  State<CompletarRegistroGoogleScreen> createState() =>
      _CompletarRegistroGoogleScreenState();
}

class _CompletarRegistroGoogleScreenState
    extends State<CompletarRegistroGoogleScreen> {
  String _selectedRole = 'paciente';
  bool _loading = false;

  Future<void> _completeRegistration() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService().completeGoogleRegistration(
        uid: user.uid,
        role: _selectedRole,
      );

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      final role = (data?['role'] ?? '').toString();
      final professionalStatus =
          (data?['professionalVerificationStatus'] ?? '').toString();

      if (role == 'paciente') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PrincipalScreen()),
        );
        return;
      }

      if (role == 'psicologo') {
        if (professionalStatus == 'verified') {
          // Esto casi nunca debería pasar al registrar por primera vez.
          // Lo dejamos por consistencia.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const VerificacionProfesionalScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const VerificacionProfesionalScreen(),
            ),
          );
        }
        return;
      }

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo completar tu registro.'),
        ),
      );
    } catch (e) {
      debugPrint('Complete Google registration error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al completar el registro.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: const Text('Completar registro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elige tu tipo de cuenta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esto nos ayuda a configurar tu experiencia dentro de Harmoni.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'paciente',
                          child: Text('Paciente'),
                        ),
                        DropdownMenuItem(
                          value: 'psicologo',
                          child: Text('Psicólogo'),
                        ),
                      ],
                      onChanged: _loading
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _selectedRole = value);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_selectedRole == 'psicologo')
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Como psicólogo, primero deberás subir tus documentos profesionales antes de acceder al panel clínico.',
                    ),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _completeRegistration,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}