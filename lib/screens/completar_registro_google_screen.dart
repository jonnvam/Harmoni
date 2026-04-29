import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/user_role.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';
import 'package:flutter_application_1/screens/sign_login.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/verification_professional.dart';
import 'package:flutter_application_1/services/auth_google.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';
import 'package:flutter_application_1/state/app_state.dart';

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
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignLoginScreen()),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    await AuthService().completeGoogleRegistration(
      uid: user.uid,
      role: _selectedRole,
    );

    final profile = await UserProfileService.instance.loadProfileAfterAuth(
      user.uid,
    );

    if (!mounted) return;

    if (profile == null) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar tu perfil. Intenta iniciar sesión de nuevo.'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignLoginScreen()),
      );
      return;
    }

    if (profile.isPaciente) {
      await AppState.instance.setRole(UserRole.paciente);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PrincipalScreen()),
      );
      return;
    }

    if (profile.isPsicologo) {
      await AppState.instance.setRole(UserRole.psicologo);

      if (!mounted) return;

      if (profile.isVerifiedPsychologist) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PsychologistHomeScreen(),
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
        content: Text('Tu cuenta no tiene un rol válido.'),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignLoginScreen()),
    );
  } catch (e, st) {
    debugPrint('Complete Google registration error: $e');
    debugPrint('Complete Google registration stack: $st');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al completar el registro: $e'),
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