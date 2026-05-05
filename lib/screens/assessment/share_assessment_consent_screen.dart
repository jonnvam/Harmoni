import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/services/assessment_consent_service.dart';

class ShareAssessmentConsentScreen extends StatefulWidget {
  final String assessmentId;
  final String psychologistUid;
  final String psychologistName;

  const ShareAssessmentConsentScreen({
    super.key,
    required this.assessmentId,
    required this.psychologistUid,
    required this.psychologistName,
  });

  @override
  State<ShareAssessmentConsentScreen> createState() =>
      _ShareAssessmentConsentScreenState();
}

class _ShareAssessmentConsentScreenState
    extends State<ShareAssessmentConsentScreen> {
  bool _saving = false;
  bool _accepted = false;

  Future<void> _confirmConsent() async {
    if (!_accepted || _saving) return;

    setState(() => _saving = true);

    try {
      await AssessmentConsentService.instance.grantAssessmentConsent(
        assessmentId: widget.assessmentId,
        psychologistUid: widget.psychologistUid,
        psychologistName: widget.psychologistName,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Consentimiento guardado',
            style: TextStyle(
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Tus resultados fueron autorizados para compartirse con ${widget.psychologistName}.',
            style: const TextStyle(
              fontFamily: 'Kantumruy Pro',
              height: 1.35,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el consentimiento: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SmallBackButton(
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 42),

              const Text(
                'Compartir evaluación',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Consentimiento informado',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.ios_share_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estás por compartir tus resultados con:',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Kantumruy Pro',
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.psychologistName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _InfoCard(
                icon: Icons.fact_check_outlined,
                title: '¿Qué se compartirá?',
                text:
                    'Tus puntajes PHQ-9 y GAD-7, niveles de severidad y respuestas registradas en esta evaluación inicial.',
              ),

              const SizedBox(height: 14),

              _InfoCard(
                icon: Icons.lock_outline_rounded,
                title: 'Privacidad',
                text:
                    'Esta autorización solo aplica para el psicólogo vinculado. No se compartirá con otros profesionales sin tu autorización.',
              ),

              const SizedBox(height: 14),

              _InfoCard(
                icon: Icons.undo_rounded,
                title: 'Revocación',
                text:
                    'Más adelante podrás revocar este consentimiento desde la app. Por ahora quedará registrado como consentimiento activo.',
              ),

              const SizedBox(height: 22),

              CheckboxListTile(
                value: _accepted,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _accepted = value ?? false;
                        });
                      },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Confirmo que deseo compartir esta evaluación con mi psicólogo vinculado.',
                  style: TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _accepted ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: (!_accepted || _saving) ? null : _confirmConsent,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Aceptar y compartir',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SmallBackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF8FAFC),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
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