import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResetMethod { email, whatsapp }

class RestCodigoScreen extends StatefulWidget {
  const RestCodigoScreen({super.key});

  @override
  State<RestCodigoScreen> createState() => _RestCodigoScreenState();
}

class _RestCodigoScreenState extends State<RestCodigoScreen> {
  ResetMethod _method = ResetMethod.email;
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_method == ResetMethod.email) {
      _sendResetEmail();
    } else {
      _sendWhatsApp();
    }
  }

  bool _validEmail(String v) {
    final email = v.trim();
    final re = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return re.hasMatch(email);
  }

  String _sanitizePhone(String v) {
    String d = v.replaceAll(RegExp(r"[^0-9]"), "");
    if (d.startsWith("00")) d = d.substring(2);
    return d;
  }

  Future<void> _sendResetEmail() async {
    final email = _emailCtrl.text.trim();
    if (!_validEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo válido.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enlace enviado a $email')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message ?? e.code}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al enviar el correo.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendWhatsApp() async {
    String raw = _phoneCtrl.text;
    final phone = _sanitizePhone(raw);
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa un número de WhatsApp válido con código de país.',
          ),
        ),
      );
      return;
    }
    final msg = Uri.encodeComponent(
      'Hola, quisiera recibir mi enlace de restablecimiento de contraseña.',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
      );
    }
  }

  Widget _methodTile({
    required String title,
    required IconData icon,
    required ResetMethod value,
  }) {
    final isSelected = _method == value;
    return InkWell(
      onTap: () => setState(() => _method = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? const Color.fromRGBO(165, 180, 252, 1)
                    : const Color.fromARGB(162, 255, 255, 255),
            width: 1,
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyles.textBlackLogin.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            Icon(icon, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(33, 76, 44, 31 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Restablecer Contraseña',
                    style: TextStyles.tituloBienvenida.copyWith(
                      fontSize: 27,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 0)),
                  Text(
                    'Selecciona el método para recibir el enlace de restablecimiento de contraseña',
                    style: TextStyles.textDicho.copyWith(
                      fontSize: 20,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 165,
                      height: 165,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromRGBO(175, 189, 250, 1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 129,
                          height: 129,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(224, 231, 255, 1),
                                Color.fromRGBO(224, 231, 255, 1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),

                          child: Center(
                            child: SvgPicture.asset(
                              'assets/images/lock.svg',
                              width: 96,
                              height: 96,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 55),
                  _methodTile(
                    title: 'Enviar por correo',
                    icon: Icons.email_outlined,
                    value: ResetMethod.email,
                  ),
                  const SizedBox(height: 12),
                  _methodTile(
                    title: 'Enviar por WhatsApp',
                    icon: Icons.chat_bubble_outline,
                    value: ResetMethod.whatsapp,
                  ),
                  const SizedBox(height: 16),
                  if (_method == ResetMethod.email) ...[
                    Text(
                      'Correo',
                      textAlign: TextAlign.center,
                      style: TextStyles.textDicho.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(165, 180, 252, 1),
                        ),
                      ),
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: 'tu@correo.com',
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Número WhatsApp (con código de país)',
                      style: TextStyles.textDicho.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(165, 180, 252, 1),
                        ),
                      ),
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: '521XXXXXXXXXX',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fondo3,
                        padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _sending ? null : _onConfirm,
                      child:
                          _sending
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Confirmar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Kantumruy Pro',
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
