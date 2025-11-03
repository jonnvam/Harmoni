import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/sign_login.dart';

class VerificacionScreen extends StatefulWidget {
  final String email;
  const VerificacionScreen({super.key, this.email = 'example@email.com'});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onConfirm() {
    final isValid = _code.length == 4 && RegExp(r'^\d{4}$').hasMatch(_code);
    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código verificado (demo).')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 4 dígitos.')),
      );
    }
  }

  OutlineInputBorder _otpBorder(Color color) => OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(24),
      );

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(1)],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: _otpBorder(const Color.fromRGBO(165, 180, 252, 1)), // AppColors.borde2 tone
          focusedBorder: _otpBorder(AppColors.fondo3),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < _focusNodes.length - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
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
              // Back button inside a circle
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  // Ir explícitamente a SignLoginScreen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => SignLoginScreen()),
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

              // Outer bordered theme container for the main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    // Se quita el borde morado/lavanda
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Verificación',
                            style: TextStyles.tituloBienvenida.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Central illustration: circle with friendly icon
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(224, 231, 255, 1),
                                Color.fromRGBO(199, 210, 254, 1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color.fromRGBO(165, 180, 252, 1), width: 1),
                          ),
                          child: const Center(
                            child: Icon(Icons.verified_user_outlined, size: 64, color: Color.fromRGBO(99, 102, 241, 1)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Subtitle and helper
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Código de verificación',
                            style: TextStyles.textBlackLogin.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Escribe el código que enviamos a ${widget.email}',
                            style: TextStyles.textDicho.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OTP boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, _buildOtpBox),
                        ),
                        const SizedBox(height: 24),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fondo3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: _onConfirm,
                            child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Secondary help text
                        Text(
                          '¿No recibiste el código?',
                          style: TextStyles.textDicho.copyWith(fontSize: 13, color: Colors.black54),
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
