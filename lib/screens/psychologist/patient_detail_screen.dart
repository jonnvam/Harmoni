import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_application_1/components/appointment_access_card.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del paciente'),
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
              Text(
                patientName,
                style: TextStyles.textEditar.copyWith(fontSize: 24),
              ),

              const SizedBox(height: 6),

              if (uid == null)
                const Center(
                  child: Text(
                    'Inicia sesión para ver la información del paciente',
                  ),
                )
              else ...[
                _SharedAssessmentSection(
                  patientId: patientId,
                  psychologistUid: uid,
                ),

                const SizedBox(height: 16),

                Text(
                  'Historial de citas',
                  style: TextStyles.textDicho.copyWith(color: Colors.black54),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('citas')
                            .where('psychologistUid', isEqualTo: uid)
                            .where('patientUid', isEqualTo: patientId)
                            .orderBy('fechaInicio', descending: true)
                            .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const _HistorySkeleton();
                      }

                      if (snap.hasError) {
                        return const _HistoryStateMessage(
                          icon: Icons.error_outline,
                          title: 'No se pudo cargar el historial',
                          message: 'Intenta de nuevo en unos momentos.',
                        );
                      }

                      final docs = snap.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return const _HistoryStateMessage(
                          icon: Icons.history_toggle_off,
                          title: 'Sin historial aún',
                          message: 'Las citas aparecerán aquí cuando existan.',
                        );
                      }

                      final lastConfirmed = docs
                          .map((d) => d.data() as Map<String, dynamic>? ?? {})
                          .where(
                            (d) =>
                                (d['estado'] ?? '').toString() == 'confirmada',
                          )
                          .map((d) => d['fechaInicio'])
                          .whereType<Timestamp>()
                          .map((t) => t.toDate())
                          .fold<DateTime?>(
                            null,
                            (prev, cur) =>
                                prev == null || cur.isAfter(prev) ? cur : prev,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoCard(
                            title: 'Última sesión',
                            value:
                                lastConfirmed == null
                                    ? 'Sin sesiones confirmadas'
                                    : _formatDateTime(lastConfirmed),
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final data =
                                    docs[i].data() as Map<String, dynamic>? ??
                                    {};

                                final date =
                                    (data['fechaInicio'] as Timestamp?)
                                        ?.toDate();

                                final status =
                                    (data['estado'] ?? 'pendiente').toString();

                                final modalidad =
                                    (data['modalidad'] ?? '').toString();
                                final meetUrl =
                                    (data['meetUrl'] ?? '').toString();

                                final ubicacion =
                                    (data['ubicacion'] ??
                                            data['location'] ??
                                            data['direccion'] ??
                                            '')
                                        .toString();

                                return _AppointmentRow(
                                  date: date,
                                  status: status,
                                  modalidad: modalidad,
                                  meetUrl: meetUrl,
                                  ubicacion: ubicacion,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month ${dt.year} · $hour:$minute';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.textDicho.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyles.textBlackLogin.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final DateTime? date;
  final String status;
  final String modalidad;
  final String? meetUrl;
  final String? ubicacion;

  const _AppointmentRow({
    required this.date,
    required this.status,
    required this.modalidad,
    this.meetUrl,
    this.ubicacion,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        date == null
            ? 'Sin fecha'
            : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')} ${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}';
    final color =
        status == 'confirmada'
            ? const Color(0xFF22C55E)
            : status == 'cancelada'
            ? const Color(0xFFEF4444)
            : const Color(0xFF6366F1);

    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                dateStr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Kantumruy Pro',
                ),
              ),
              subtitle: Text(
                'Estado: $status · Modalidad: ${modalidad.isEmpty ? 'No especificada' : modalidad}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontFamily: 'Kantumruy Pro',
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            AppointmentAccessCard(
              modalidad: modalidad,
              estado: status,
              meetUrl: meetUrl,
              ubicacion: ubicacion,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _HistoryStateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.black38),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyles.textEditar.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyles.textDicho.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedAssessmentSection extends StatelessWidget {
  final String patientId;
  final String psychologistUid;

  const _SharedAssessmentSection({
    required this.patientId,
    required this.psychologistUid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('assessmentConsents')
              .where('patientUid', isEqualTo: patientId)
              .where('psychologistUid', isEqualTo: psychologistUid)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .snapshots(),
      builder: (context, consentSnap) {
        if (consentSnap.connectionState == ConnectionState.waiting) {
          return const _SharedAssessmentSkeleton();
        }

        if (consentSnap.hasError) {
          return const _SharedAssessmentStateCard(
            icon: Icons.error_outline,
            title: 'Evaluación compartida',
            message: 'No se pudo consultar el consentimiento del paciente.',
          );
        }

        final consentDocs = consentSnap.data?.docs ?? [];

        if (consentDocs.isEmpty) {
          return const _SharedAssessmentStateCard(
            icon: Icons.lock_outline_rounded,
            title: 'Evaluación inicial',
            message:
                'El paciente aún no ha compartido su evaluación inicial contigo.',
          );
        }

        final consentData = consentDocs.first.data();
        final assessmentPath = (consentData['assessmentPath'] ?? '').toString();

        if (assessmentPath.isEmpty) {
          return const _SharedAssessmentStateCard(
            icon: Icons.warning_amber_rounded,
            title: 'Evaluación compartida',
            message:
                'El consentimiento no tiene una ruta de evaluación válida.',
          );
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance.doc(assessmentPath).get(),
          builder: (context, assessmentSnap) {
            if (assessmentSnap.connectionState == ConnectionState.waiting) {
              return const _SharedAssessmentSkeleton();
            }

            if (assessmentSnap.hasError) {
              return const _SharedAssessmentStateCard(
                icon: Icons.error_outline,
                title: 'Evaluación compartida',
                message:
                    'No se pudo cargar la evaluación. Revisa permisos o consentimiento.',
              );
            }

            final assessmentData = assessmentSnap.data?.data();

            if (assessmentData == null) {
              return const _SharedAssessmentStateCard(
                icon: Icons.description_outlined,
                title: 'Evaluación compartida',
                message: 'No se encontró el documento de evaluación.',
              );
            }

            return _SharedAssessmentResultCard(
              assessmentData: assessmentData,
              consentData: consentData,
            );
          },
        );
      },
    );
  }
}

class _SharedAssessmentResultCard extends StatelessWidget {
  final Map<String, dynamic> assessmentData;
  final Map<String, dynamic> consentData;

  const _SharedAssessmentResultCard({
    required this.assessmentData,
    required this.consentData,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final phq9 = assessmentData['phq9'] as Map<String, dynamic>? ?? {};
    final gad7 = assessmentData['gad7'] as Map<String, dynamic>? ?? {};

    final phqScore = phq9['score'] ?? 0;
    final gadScore = gad7['score'] ?? 0;

    final phqLabel = (phq9['severityLabelEs'] ?? 'Sin clasificar').toString();
    final gadLabel = (gad7['severityLabelEs'] ?? 'Sin clasificar').toString();

    final completedAtRaw = assessmentData['completedAt'];
    final completedAt =
        completedAtRaw is Timestamp ? completedAtRaw.toDate() : null;

    final grantedAtRaw = consentData['createdAt'];
    final grantedAt = grantedAtRaw is Timestamp ? grantedAtRaw.toDate() : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evaluación inicial compartida',
                  style: TextStyles.textEditar.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'El paciente autorizó compartir estos resultados contigo.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Colors.black54,
              fontFamily: 'Kantumruy Pro',
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _AssessmentMiniScore(
                  title: 'PHQ-9',
                  score: '$phqScore / 27',
                  label: phqLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AssessmentMiniScore(
                  title: 'GAD-7',
                  score: '$gadScore / 21',
                  label: gadLabel,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (completedAt != null)
            _AssessmentInfoLine(
              icon: Icons.event_available_outlined,
              text: 'Realizada el ${_formatDate(completedAt)}',
            ),

          if (grantedAt != null) ...[
            const SizedBox(height: 6),
            _AssessmentInfoLine(
              icon: Icons.lock_open_outlined,
              text: 'Consentimiento otorgado el ${_formatDate(grantedAt)}',
            ),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder:
                      (_) => _AssessmentAnswersDialog(
                        assessmentData: assessmentData,
                      ),
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Ver respuestas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentMiniScore extends StatelessWidget {
  final String title;
  final String score;
  final String label;

  const _AssessmentMiniScore({
    required this.title,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              fontFamily: 'Kantumruy Pro',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            score,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              fontFamily: 'Kantumruy Pro',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w700,
              fontFamily: 'Kantumruy Pro',
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AssessmentInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.black45),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontFamily: 'Kantumruy Pro',
            ),
          ),
        ),
      ],
    );
  }
}

class _AssessmentAnswersDialog extends StatelessWidget {
  final Map<String, dynamic> assessmentData;

  const _AssessmentAnswersDialog({required this.assessmentData});

  static const List<String> _phq9Questions = [
    'Poco interés o placer en hacer cosas',
    'Se ha sentido desanimado/a, deprimido/a o sin esperanzas',
    'Dificultad para conciliar el sueño o quedarse dormido/a, o dormir demasiado',
    'Se ha sentido cansado/a o con poca energía',
    'Poco apetito o comer en exceso',
    'Se ha sentido mal consigo mismo/a o que es un/a fracasado/a',
    'Dificultad para concentrarse',
    'Movimientos o habla lenta, o inquietud/agitación notable',
    'Pensamientos de muerte o de lastimarse',
  ];

  static const List<String> _gad7Questions = [
    'Sentirse nervioso/a, ansioso/a o al límite',
    'No poder parar o controlar la preocupación',
    'Preocuparse demasiado por diferentes cosas',
    'Dificultad para relajarse',
    'Inquietud que dificulta quedarse quieto/a',
    'Enojarse o irritarse fácilmente',
    'Sentir miedo como si algo terrible fuera a pasar',
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
    final phq9 = assessmentData['phq9'] as Map<String, dynamic>? ?? {};
    final gad7 = assessmentData['gad7'] as Map<String, dynamic>? ?? {};

    final phqAnswersRaw = phq9['answers'];
    final gadAnswersRaw = gad7['answers'];

    final phqAnswers = phqAnswersRaw is List ? phqAnswersRaw : const [];
    final gadAnswers = gadAnswersRaw is List ? gadAnswersRaw : const [];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Respuestas de evaluación',
        style: TextStyle(
          fontFamily: 'Kantumruy Pro',
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnswerGroup(
                title: 'PHQ-9',
                questions: _phq9Questions,
                answers: phqAnswers,
                answerLabel: _answerLabel,
              ),
              const SizedBox(height: 18),
              _AnswerGroup(
                title: 'GAD-7',
                questions: _gad7Questions,
                answers: gadAnswers,
                answerLabel: _answerLabel,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _AnswerGroup extends StatelessWidget {
  final String title;
  final List<String> questions;
  final List<dynamic> answers;
  final String Function(dynamic value) answerLabel;

  const _AnswerGroup({
    required this.title,
    required this.questions,
    required this.answers,
    required this.answerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Kantumruy Pro',
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(questions.length, (index) {
          final answer = index < answers.length ? answers[index] : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${questions[index]}',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Colors.black87,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  answerLabel(answer),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SharedAssessmentStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _SharedAssessmentStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black45, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.textEditar.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
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

class _SharedAssessmentSkeleton extends StatelessWidget {
  const _SharedAssessmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 135,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
