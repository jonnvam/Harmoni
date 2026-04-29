import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/models/user_role.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';
import 'package:flutter_application_1/screens/sign_login.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/verification_professional.dart';
import 'package:flutter_application_1/services/auth_email.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';

class VerificacionScreen extends StatefulWidget {
  final String email;
  const VerificacionScreen({super.key, required this.email});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  bool _checking = false;
  bool _sending = false;
  int _secondsLeft = 0; // cooldown para reenviar
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Primera vez: empezamos con un pequeño cooldown para no spamear
    _startCooldown(20);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    setState(() => _secondsLeft = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_secondsLeft > 0) return;
    setState(() => _sending = true);
    try {
      await EmailAuthService().resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te enviamos otro correo de verificación.'),
        ),
      );
      _startCooldown(30);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo reenviar: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _routeAfterEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignLoginScreen()),
        (route) => false,
      );
      return;
    }

    await user.reload();

    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null || !refreshedUser.emailVerified) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu correo todavía no aparece como verificado.'),
        ),
      );
      return;
    }

    final profile = await UserProfileService.instance.loadProfileAfterAuth(
      refreshedUser.uid,
    );

    if (!mounted) return;

    if (profile == null) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el perfil del usuario.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignLoginScreen()),
        (route) => false,
      );
      return;
    }

    debugPrint('VERIFICACION UID: ${profile.uid}');
    debugPrint('VERIFICACION ROLE: ${profile.role}');
    debugPrint(
      'VERIFICACION PROFESSIONAL STATUS: ${profile.professionalVerificationStatus}',
    );

    if (!profile.profileCompleted || profile.role == null) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu perfil no está completo. Inicia sesión de nuevo.'),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignLoginScreen()),
        (route) => false,
      );
      return;
    }

    if (profile.isPaciente) {
      await AppState.instance.setRole(UserRole.paciente);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PrincipalScreen()),
        (route) => false,
      );
      return;
    }

    if (profile.isPsicologo) {
      await AppState.instance.setRole(UserRole.psicologo);

      if (!mounted) return;

      if (profile.isVerifiedPsychologist) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PsychologistHomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const VerificacionProfesionalScreen(),
          ),
          (route) => false,
        );
      }

      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu cuenta no tiene un rol válido.')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);

    try {
      final ok = await EmailAuthService().refreshVerificationStatus();

      if (!mounted) return;

      if (ok) {
        await _routeAfterEmailVerified();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aún no se ha verificado. Revisa tu correo.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo comprobar: $e')));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón back
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignLoginScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borde2, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),

              // Contenido
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verifica tu correo',
                          style: TextStyles.tituloBienvenida.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Te enviamos un correo de verificación a:',
                          style: TextStyles.textBlackLogin.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borde2,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.email,
                            style: TextStyles.textBlackLogin.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Abre el enlace del correo para activar tu cuenta. Luego vuelve y presiona “Ya verifiqué”.',
                          style: TextStyles.textDicho.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 28),

                        // Botón comprobar
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fondo3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _checking ? null : _checkVerified,
                            child:
                                _checking
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Ya verifiqué',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reenviar
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.borde3,
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed:
                                    (_secondsLeft > 0 || _sending)
                                        ? null
                                        : _resendEmail,
                                child:
                                    _sending
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          _secondsLeft > 0
                                              ? 'Reenviar (${_secondsLeft}s)'
                                              : 'Reenviar correo',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            '¿Correo incorrecto? Regresa y edítalo en el registro.',
                            style: TextStyles.textDicho.copyWith(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
