import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/components/animated_flower.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/data/emotion_journal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';
import 'package:flutter_application_1/screens/assessment/assessment_detail_screen.dart';
import 'package:flutter_application_1/services/goals_firestore_service.dart';
import 'package:flutter_application_1/services/diary_firestore_service.dart';
import 'package:flutter_application_1/screens/mis_citas_screen.dart';

class SecondPrincipalScreen extends StatefulWidget {
  const SecondPrincipalScreen({super.key});

  @override
  State<SecondPrincipalScreen> createState() => _SecondPrincipalScreenState();
}

class _SecondPrincipalScreenState extends State<SecondPrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;

  void _guardedNavigate(Widget screen) {
    if (!AppState.instance.isTestCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el test inicial para desbloquear esta sección.',
          ),
        ),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  CollectionReference<Map<String, dynamic>>? _notesCol() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    return DiaryFirestoreService.instance.notesCol(uid);
  }

  Future<void> _openMoodModal(
    BuildContext parentContext,
    String emotionLabel,
    String emotionIconAsset,
  ) async {
    final controller = TextEditingController(); // lo que le causó esa emoción
    final titleCtrl = TextEditingController(
      text: emotionLabel,
    ); // título por defecto = emoción

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ponle un nombre a tu nota',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(emotionIconAsset, width: 36, height: 36),
                  const SizedBox(width: 12),
                  Text(
                    '¿Qué te hizo sentir $emotionLabel?',
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe aquí (opcional)...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ///cambio en estilo de boton
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final lower = emotionLabel.toLowerCase();

                      EmotionType? t;

                      if (lower.contains('feliz')) {
                        t = EmotionType.happy;
                      } else if (lower.contains('triste')) {
                        t = EmotionType.sad;
                      } else if (lower.contains('enojad')) {
                        t = EmotionType.angry;
                      } else if (lower.contains('sorpres') ||
                          lower.contains('sorprendid')) {
                        t = EmotionType.surprised;
                      } else if (lower.contains('miedo')) {
                        t = EmotionType.fear;
                      }

                      if (t != null) {
                        await EmotionJournal.instance.saveEmotion(t);
                      }

                      final titulo =
                          titleCtrl.text.trim().isEmpty
                              ? emotionLabel
                              : titleCtrl.text.trim();

                      final causa = controller.text.trim();

                      final texto =
                          causa.isEmpty
                              ? 'Hoy me sentí $emotionLabel.'
                              : 'Hoy me sentí $emotionLabel: $causa';

                      try {
                        await DiaryFirestoreService.instance.addTextNote(
                          titulo: titulo,
                          texto: texto,
                          emocion: emotionLabel,
                          icono: emotionIconAsset,
                        );

                        if (!parentContext.mounted) return;

                        Navigator.of(ctx).pop();

                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Estado de ánimo guardado.'),
                          ),
                        );

                        await Navigator.push(
                          parentContext,
                          MaterialPageRoute(
                            builder: (_) => const DiarioScreen(),
                          ),
                        );
                      } catch (e) {
                        if (!parentContext.mounted) return;

                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(content: Text('No se pudo guardar: $e')),
                        );
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/images/flores/flor2.png"), context);
    precacheImage(const AssetImage("assets/images/flores/flor3.png"), context);
    precacheImage(const AssetImage("assets/images/flores/flor4.png"), context);
    precacheImage(const AssetImage("assets/images/carousel/t1.jpg"), context);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => showStep2 = true);
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => showStep3 = true);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => showStep4 = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const DropMenu(),
                if (showStep2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [TopFeeling()],
                  ),
                const SizedBox(height: 20),

                // ====== Emojis rápidas (sin cambios) ======
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        EmotionButton(
                          text: "Feliz",
                          icon: "assets/images/emotions/Feliz.svg",
                          onTap:
                              () => _openMoodModal(
                                context,
                                'Feliz',
                                'assets/images/emotions/Feliz.svg',
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Triste",
                          icon: "assets/images/emotions/Triste.svg",
                          onTap:
                              () => _openMoodModal(
                                context,
                                'Triste',
                                'assets/images/emotions/Triste.svg',
                              ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Enojado",
                          icon: "assets/images/emotions/Enojado.svg",
                          onTap:
                              () => _openMoodModal(
                                context,
                                'Enojado',
                                'assets/images/emotions/Enojado.svg',
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        EmotionButton(
                          text: "Sorpresa",
                          icon: "assets/images/emotions/Sorpresa.svg",
                          onTap:
                              () => _openMoodModal(
                                context,
                                'Sorprendido',
                                'assets/images/emotions/Sorpresa.svg',
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Miedo",
                          icon: "assets/images/emotions/Miedo.svg",
                          onTap:
                              () => _openMoodModal(
                                context,
                                'Miedo',
                                'assets/images/emotions/Miedo.svg',
                              ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (showStep3) const SizedBox(height: 70),
                const _FirestoreFlowerProgress(),
                const SizedBox(height: 70),

                /// es esta parte esta el enlace a las citas del paciente

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _QuickAppointmentCard(),
                ),

                const SizedBox(height: 22),

                // ====== Carousel de temas recomendados (Depresión, Ansiedad, etc.) ======
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          'Temas recomendados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const SizedBox(width: 6),
                            _TopicCard(
                              title: 'Depresión',
                              subtitle:
                                  'Síntomas, señales y cuándo pedir ayuda',
                              onTap:
                                  () => _guardedNavigate(
                                    IaScreen(initialTopic: 'Depresión'),
                                  ),
                            ),
                            const SizedBox(width: 10),
                            _TopicCard(
                              title: 'Ansiedad',
                              subtitle:
                                  'Técnicas para calmar y manejar ataques',
                              onTap:
                                  () => _guardedNavigate(
                                    IaScreen(initialTopic: 'Ansiedad'),
                                  ),
                            ),
                            const SizedBox(width: 10),
                            _TopicCard(
                              title: 'Insomnio',
                              subtitle:
                                  'Rutinas y hábitos para mejorar el sueño',
                              onTap:
                                  () => _guardedNavigate(
                                    IaScreen(initialTopic: 'Insomnio'),
                                  ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                // ====== Resultado de cuestionario inicial (si ya lo hizo) ======
                const _AssessmentSummaryCard(),

                const SizedBox(height: 30),

                // ====== Metas en progreso (desde Firestore) ======
                _FirestoreInProgressList(),

                const SizedBox(height: 80),
              ],
            ),
          ),

          if (showStep4)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SemiCircularRadialMenu(
                  currentIconAsset: "assets/images/icon/house.svg",
                  ringColor: Colors.transparent,
                  items: [
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/diario.svg",
                      onTap: () => _guardedNavigate(const DiarioScreen()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/ia.svg",
                      onTap: () => _guardedNavigate(IaScreen()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/metas.svg",
                      onTap: () => _guardedNavigate(const MetasScreen()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/progreso.svg",
                      onTap: () => _guardedNavigate(const Progreso()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/psicologos.svg",
                      onTap: () => _guardedNavigate(const Psicologos()),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ====== LISTA Firestore “en progreso” con botón de completar ======
class _FirestoreInProgressList extends StatelessWidget {
  const _FirestoreInProgressList();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const SizedBox.shrink();

    final query = GoalsFirestoreService.instance.metasPorEstadoQuery(
      uid: uid,
      estado: 'en_progreso',
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error al cargar metas en progreso.'),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Metas en progreso',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),

            ...docs.map((doc) {
              final d = doc.data();

              final titulo = (d['titulo'] ?? '').toString();
              final descripcion = (d['descripcion'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 130,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            await GoalsFirestoreService.instance.completeGoal(
                              goalRef: doc.reference,
                            );

                            if (!context.mounted) return;

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('¡Meta completada!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No se pudo completar la meta: $e',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Completar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _FirestoreFlowerProgress extends StatelessWidget {
  const _FirestoreFlowerProgress();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const AnimatedFlower(
        assetPath: 'assets/animations/flower.json',
        showOverlayRing: true,
        segments: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        fractionOverride: 0.0,
        segmentsCountOverride: 6,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: GoalsFirestoreService.instance.allGoalsStream(uid),
      builder: (context, snap) {
        double fraction = 0.0;

        if (snap.hasData) {
          final all = snap.data!.docs;
          final total = all.length;

          if (total > 0) {
            final completed =
                all.where((d) {
                  final m = d.data();
                  return (m['estado'] ?? '') == 'completada';
                }).length;

            fraction = completed / total;
          }
        }

        return AnimatedFlower(
          assetPath: 'assets/animations/flower.json',
          showOverlayRing: true,
          segments: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
          fractionOverride: fraction.clamp(0.0, 1.0),
          segmentsCountOverride: 6,
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Ver',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///widget para el resumen de evaluación inicial (PHQ-9 y GAD-7)
class _AssessmentSummaryCard extends StatelessWidget {
  const _AssessmentSummaryCard();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final patientRef = FirebaseFirestore.instance
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: patientRef.get(),
      builder: (context, patientSnap) {
        if (patientSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (patientSnap.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No se pudieron cargar tus resultados.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final patientData = patientSnap.data?.data();

        if (patientData == null) {
          return const SizedBox.shrink();
        }

        final initialAssessment = patientData['initialAssessment'];

        if (initialAssessment is! Map ||
            initialAssessment['completed'] != true ||
            initialAssessment['latestAssessmentId'] == null) {
          return const SizedBox.shrink();
        }

        final assessmentId = initialAssessment['latestAssessmentId'].toString();

        final assessmentRef = patientRef
            .collection('assessments')
            .doc(assessmentId);

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: assessmentRef.get(),
          builder: (context, assessmentSnap) {
            if (assessmentSnap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (assessmentSnap.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No se pudieron cargar los detalles de tu evaluación.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final data = assessmentSnap.data?.data();

            if (data == null) {
              return const SizedBox.shrink();
            }

            final phq9 = data['phq9'] as Map<String, dynamic>? ?? {};
            final gad7 = data['gad7'] as Map<String, dynamic>? ?? {};

            final phqScore = phq9['score'] ?? 0;
            final gadScore = gad7['score'] ?? 0;

            final phqLabel =
                (phq9['severityLabelEs'] ?? 'Sin clasificar').toString();
            final gadLabel =
                (gad7['severityLabelEs'] ?? 'Sin clasificar').toString();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu evaluación inicial',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Resumen privado de tus resultados PHQ-9 y GAD-7.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kantumruy Pro',
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _AssessmentScoreBox(
                            title: 'PHQ-9',
                            score: '$phqScore / 27',
                            label: phqLabel,
                            subtitle: 'Depresión',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AssessmentScoreBox(
                            title: 'GAD-7',
                            score: '$gadScore / 21',
                            label: gadLabel,
                            subtitle: 'Ansiedad',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Estos resultados son privados. Solo se compartirán con un psicólogo si das tu consentimiento explícito.',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Kantumruy Pro',
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AssessmentDetailScreen(
                                    assessmentId: assessmentId,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Ver detalles'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AssessmentScoreBox extends StatelessWidget {
  final String title;
  final String score;
  final String label;
  final String subtitle;

  const _AssessmentScoreBox({
    required this.title,
    required this.score,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // clave
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Kantumruy Pro',
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 18), // reemplaza al Spacer
          Text(
            score,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAppointmentCard extends StatelessWidget {
  const _QuickAppointmentCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MisCitasScreen()),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDCE4FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: AppColors.fondo3,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis citas',
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Revisa tus solicitudes y citas confirmadas.',
                    style: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontSize: 12.5,
                      height: 1.25,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.fondo3,
            ),
          ],
        ),
      ),
    );
  }
}
