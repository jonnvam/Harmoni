import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';
import 'package:flutter_application_1/screens/assessment/share_assessment_consent_screen.dart';
import 'package:flutter_application_1/services/assessment_consent_service.dart';

class AssessmentDetailScreen extends StatelessWidget {
  final String assessmentId;

  const AssessmentDetailScreen({super.key, required this.assessmentId});

  static const List<String> _phq9Questions = [
    'Poco interés o placer en hacer cosas',
    'Se ha sentido desanimado/a, deprimido/a o sin esperanzas',
    'Dificultad para conciliar el sueño o quedarse dormido/a, o dormir demasiado',
    'Se ha sentido cansado/a o con poca energía',
    'Poco apetito o comer en exceso',
    'Se ha sentido mal consigo mismo/a – o que es un/a fracasado/a o que ha quedado mal consigo mismo/a o su familia',
    'Dificultad para concentrarse en cosas, como leer el periódico o ver la televisión',
    'Se ha movido o hablado tan lentamente que otras personas lo han notado o lo contrario, ha estado tan inquieto/a o agitado/a que se ha estado moviendo mucho más de lo habitual',
    'Pensamientos de que estaría mejor muerto/a o de lastimarse de alguna manera',
  ];

  static const List<String> _gad7Questions = [
    'Sentirse nervioso/a, ansioso/a, o al límite',
    'No poder parar o controlar la preocupación',
    'Preocuparse demasiado por diferentes cosas',
    'Dificultad para relajarse',
    'Estar tan inquieto/a que es difícil quedarse quieto/a',
    'Enojarse o irritarse fácilmente',
    'Sentir miedo como si algo terrible fuese a pasar',
  ];

  static const List<String> _choices = [
    'Nunca',
    'Varios días',
    'Más de la mitad de los días',
    'Casi todos los días',
  ];

  String _answerLabel(dynamic value) {
    if (value is int && value >= 0 && value <= 3) {
      return '${_choices[value]} ($value)';
    }

    if (value is num && value >= 0 && value <= 3) {
      final clean = value.toInt();
      return '${_choices[clean]} ($clean)';
    }

    return 'Sin respuesta';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No hay una sesión activa.')),
      );
    }

    final assessmentRef = FirebaseFirestore.instance
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid)
        .collection('assessments')
        .doc(assessmentId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: assessmentRef.get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return _ErrorState(
                message: 'No se pudo cargar la evaluación.',
                detail: snap.error.toString(),
              );
            }

            final data = snap.data?.data();

            if (data == null) {
              return const _ErrorState(
                message: 'No se encontró esta evaluación.',
                detail: 'Verifica que el documento exista en Firestore.',
              );
            }

            final phq9 = data['phq9'] as Map<String, dynamic>? ?? {};
            final gad7 = data['gad7'] as Map<String, dynamic>? ?? {};

            final phqAnswersRaw = phq9['answers'];
            final gadAnswersRaw = gad7['answers'];

            final phqAnswers = phqAnswersRaw is List ? phqAnswersRaw : const [];
            final gadAnswers = gadAnswersRaw is List ? gadAnswersRaw : const [];

            final phqScore = phq9['score'] ?? 0;
            final gadScore = gad7['score'] ?? 0;

            final phqLabel =
                (phq9['severityLabelEs'] ?? 'Sin clasificar').toString();
            final gadLabel =
                (gad7['severityLabelEs'] ?? 'Sin clasificar').toString();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),

                  const SizedBox(height: 42),

                  const Text(
                    'Tu evaluación',
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
                    'Resumen de tu estudio inicial',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 34),

                  _MainResultCard(
                    phqScore: '$phqScore / 27',
                    phqLabel: phqLabel,
                    gadScore: '$gadScore / 21',
                    gadLabel: gadLabel,
                  ),

                  const SizedBox(height: 18),

                  const _PrivacyCard(),

                  const SizedBox(height: 18),

                  _ShareWithPsychologistButton(assessmentId: assessmentId),

                  const SizedBox(height: 34),

                  _QuestionSection(
                    title: 'PHQ-9',
                    subtitle: 'Síntomas depresivos',
                    score: '$phqScore / 27',
                    label: phqLabel,
                    questions: _phq9Questions,
                    answers: phqAnswers,
                    answerLabelBuilder: _answerLabel,
                  ),

                  const SizedBox(height: 34),

                  _QuestionSection(
                    title: 'GAD-7',
                    subtitle: 'Síntomas de ansiedad',
                    score: '$gadScore / 21',
                    label: gadLabel,
                    questions: _gad7Questions,
                    answers: gadAnswers,
                    answerLabelBuilder: _answerLabel,
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

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x09000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

class _MainResultCard extends StatelessWidget {
  final String phqScore;
  final String phqLabel;
  final String gadScore;
  final String gadLabel;

  const _MainResultCard({
    required this.phqScore,
    required this.phqLabel,
    required this.gadScore,
    required this.gadLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(32),
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
          const Text(
            'Resultados principales',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Estos puntajes ayudan a orientar tu seguimiento dentro de la app.',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w300,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _ScorePill(
                  title: 'PHQ-9',
                  score: phqScore,
                  label: phqLabel,
                  icon: Icons.favorite_border_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ScorePill(
                  title: 'GAD-7',
                  score: gadScore,
                  label: gadLabel,
                  icon: Icons.psychology_alt_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String title;
  final String score;
  final String label;
  final IconData icon;

  const _ScorePill({
    required this.title,
    required this.score,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            score,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 22, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tus respuestas son privadas. Solo podrán compartirse con un psicólogo si das tu consentimiento explícito.',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w300,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String score;
  final String label;
  final List<String> questions;
  final List<dynamic> answers;
  final String Function(dynamic value) answerLabelBuilder;

  const _QuestionSection({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.label,
    required this.questions,
    required this.answers,
    required this.answerLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Kantumruy Pro',
            fontWeight: FontWeight.w300,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 16),

        ...List.generate(questions.length, (index) {
          final answer = index < answers.length ? answers[index] : null;

          return _AnswerCard(
            number: index + 1,
            question: questions[index],
            answer: answerLabelBuilder(answer),
          );
        }),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final int number;
  final String question;
  final String answer;

  const _AnswerCard({
    required this.number,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEF2FF),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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

/// Widget para el botón de compartir resultados con el psicólogo vinculado, incluyendo la lógica de consentimiento y verificación de psicólogo activo.

class _ShareWithPsychologistButton extends StatefulWidget {
  final String assessmentId;

  const _ShareWithPsychologistButton({
    required this.assessmentId,
  });

  @override
  State<_ShareWithPsychologistButton> createState() =>
      _ShareWithPsychologistButtonState();
}

class _ShareWithPsychologistButtonState
    extends State<_ShareWithPsychologistButton> {
  bool _loading = false;

  Future<Map<String, dynamic>?> _loadAssessmentConsent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final assessmentDoc = await FirebaseFirestore.instance
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(user.uid)
        .collection('assessments')
        .doc(widget.assessmentId)
        .get();

    return assessmentDoc.data()?['consent'] as Map<String, dynamic>?;
  }

  Future<void> _handleShare(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una sesión activa.')),
      );
      return;
    }

    try {
      final patientDoc = await FirebaseFirestore.instance
          .collection(UserProfileService.collectionUsuariosPacientes)
          .doc(user.uid)
          .get();

      if (!context.mounted) return;

      final data = patientDoc.data();
      final activePsychologist = data?['activePsychologist'];

      if (activePsychologist is! Map ||
          activePsychologist['uid'] == null ||
          activePsychologist['nombre'] == null) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Aún no tienes psicólogo vinculado',
              style: TextStyle(
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Para compartir tu evaluación, primero debes reservar una cita con un psicólogo y esperar a que quede confirmada.',
              style: TextStyle(
                fontFamily: 'Kantumruy Pro',
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );

        return;
      }

      final psychologistUid = activePsychologist['uid'].toString();
      final psychologistName = activePsychologist['nombre'].toString();

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ShareAssessmentConsentScreen(
            assessmentId: widget.assessmentId,
            psychologistUid: psychologistUid,
            psychologistName: psychologistName,
          ),
        ),
      );

      if (result == true && mounted) {
        setState(() {});
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo verificar tu psicólogo vinculado: $e'),
        ),
      );
    }
  }

  Future<void> _handleRevoke(BuildContext context) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Revocar consentimiento',
              style: TextStyle(
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Tu psicólogo dejará de tener autorización para consultar esta evaluación. Podrás volver a compartirla más adelante si lo decides.',
              style: TextStyle(
                fontFamily: 'Kantumruy Pro',
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Revocar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    setState(() => _loading = true);

    try {
      await AssessmentConsentService.instance.revokeAssessmentConsent(
        assessmentId: widget.assessmentId,
      );

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consentimiento revocado.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo revocar el consentimiento: $e'),
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
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadAssessmentConsent(),
      builder: (context, snap) {
        final consent = snap.data;

        final isShared = consent?['sharedWithPsychologist'] == true &&
            consent?['revokedAt'] == null;

        final text = isShared
            ? 'Revocar consentimiento'
            : 'Compartir con mi psicólogo';

        final icon = isShared
            ? Icons.link_off_rounded
            : Icons.ios_share_rounded;

        return SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _loading || snap.connectionState == ConnectionState.waiting
                ? null
                : () {
                    if (isShared) {
                      _handleRevoke(context);
                    } else {
                      _handleShare(context);
                    }
                  },
            child: _loading || snap.connectionState == ConnectionState.waiting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}


class _ErrorState extends StatelessWidget {
  final String message;
  final String detail;

  const _ErrorState({required this.message, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 48),

              Text(
                message,
                style: const TextStyle(
                  fontSize: 34,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                detail,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
