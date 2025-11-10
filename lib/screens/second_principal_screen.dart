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
import 'package:flutter_application_1/data/diary_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/state/app_state.dart';
=======
>>>>>>> feature/stabilize-before-main

class SecondPrincipalScreen extends StatefulWidget {
  const SecondPrincipalScreen({super.key});

  @override
  State<SecondPrincipalScreen> createState() => _SecondPrincipalScreenState();
}

class _SecondPrincipalScreenState extends State<SecondPrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;
<<<<<<< HEAD

  void _guardedNavigate(Widget screen) {
    if (!AppState.instance.isTestCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openMoodModal(
    BuildContext parentContext,
    String emotionLabel,
    String emotionIconAsset,
  ) async {
    final controller = TextEditingController();
    final titleCtrl = TextEditingController(text: 'Estado de ánimo');
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    emotionIconAsset,
                    width: 36,
                    height: 36,
                  ),
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
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      // Save to EmotionJournal
                      final lower = emotionLabel.toLowerCase();
                      EmotionType? t;
                      if (lower.contains('feliz')) {t = EmotionType.happy;}
                      else if (lower.contains('triste')) {t = EmotionType.sad;}
                      else if (lower.contains('enojad')) {t = EmotionType.angry;} // enojado/enojada
                      else if (lower.contains('sorpres') || lower.contains('sorprendid')) {t = EmotionType.surprised;}
                      else if (lower.contains('miedo')) {t = EmotionType.fear;}
                      if (t != null) {
                        await EmotionJournal.instance.saveEmotion(t);
                      }

                      // Save diary note
                      final id = await DiaryRepo.nextId();
                      final baseText = 'Hoy me sentí $emotionLabel';
                      final extra = controller.text.trim();
                      final fullText = extra.isEmpty ? '$baseText.' : '$baseText: $extra';
                      final note = DiaryNote(
                        id: id,
                        date: DateTime.now(),
                        type: DiaryNoteType.text,
                        title: titleCtrl.text.trim().isEmpty ? 'Estado de ánimo' : titleCtrl.text.trim(),
                        text: fullText,
                        emotionAsset: emotionIconAsset,
                      );
                      await DiaryRepo.instance.addNote(note);

                      if (!mounted) return;
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Estado de ánimo guardado en tu diario.')),
                      );
                      // Navega al diario para ver/editar si el usuario dese
                      await Navigator.push(
                        parentContext,
                        MaterialPageRoute(builder: (_) => const DiarioScreen()),
                      );
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
=======
>>>>>>> feature/stabilize-before-main

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
<<<<<<< HEAD
                          onTap: () => _openMoodModal(context, 'Feliz', 'assets/images/emotions/Feliz.svg'),
=======
                          onTap: () async {
                            await EmotionJournal.instance
                                .saveEmotion(EmotionType.happy);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Feliz')),
                            );
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí Feliz: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiarioScreen()));
                          },
>>>>>>> feature/stabilize-before-main
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Triste",
                          icon: "assets/images/emotions/Triste.svg",
<<<<<<< HEAD
                          onTap: () => _openMoodModal(context, 'Triste', 'assets/images/emotions/Triste.svg'),
=======
                          onTap: () async {
                            await EmotionJournal.instance
                                .saveEmotion(EmotionType.sad);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Triste')),
                            );
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí Triste: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiarioScreen()));
                          },
>>>>>>> feature/stabilize-before-main
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Enojado",
                          icon: "assets/images/emotions/Enojado.svg",
<<<<<<< HEAD
                          onTap: () => _openMoodModal(context, 'Enojado', 'assets/images/emotions/Enojado.svg'),
=======
                          onTap: () async {
                            await EmotionJournal.instance
                                .saveEmotion(EmotionType.angry);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Enojado')),
                            );
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí Enojado: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiarioScreen()));
                          },
>>>>>>> feature/stabilize-before-main
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
<<<<<<< HEAD
                          onTap: () => _openMoodModal(context, 'Sorprendido', 'assets/images/emotions/Sorpresa.svg'),
=======
                          onTap: () async {
                            await EmotionJournal.instance
                                .saveEmotion(EmotionType.surprised);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Sorpresa')),
                            );
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí Sorprendido: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiarioScreen()));
                          },
>>>>>>> feature/stabilize-before-main
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Miedo",
                          icon: "assets/images/emotions/Miedo.svg",
<<<<<<< HEAD
                          onTap: () => _openMoodModal(context, 'Miedo', 'assets/images/emotions/Miedo.svg'),
=======
                          onTap: () async {
                            await EmotionJournal.instance
                                .saveEmotion(EmotionType.fear);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Miedo')),
                            );
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí con Miedo: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiarioScreen()));
                          },
>>>>>>> feature/stabilize-before-main
                        ),
                      ],
                    ),
                  ],
                ),

                if (showStep3) const SizedBox(height: 70),
<<<<<<< HEAD
                const _FirestoreFlowerProgress(),
=======
                const AnimatedFlower(
                  assetPath: 'assets/animations/flower.json',
                  showOverlayRing: true,
                  segments: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                ),
>>>>>>> feature/stabilize-before-main
                const SizedBox(height: 70),

                ContainerC1(
                  width: 300,
                  alignment: Alignment.centerLeft,
                  height: 170,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 8),
                            child: Text(
                              "Proxima Cita",
                              style: TextStyle(
                                fontFamily: 'Kantumruy Pro',
                                fontSize: 24,
                                fontWeight: FontWeight.w200,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Hoy \n13:00-13:30",
                                style: TextStyles.textHora,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 25),
                        child: Column(
                          children: [
                            Container(
                              height: 117,
                              width: 110,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 3,
                                    color: Color(0xFF6366F1),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/carousel/psicologo.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

<<<<<<< HEAD
                const SizedBox(height: 18),

                // ====== Carousel de temas recomendados (Depresión, Ansiedad, etc.) ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 8),
                        child: Text('Temas recomendados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const SizedBox(width: 6),
                            _TopicCard(
                              title: 'Depresión',
                              subtitle: 'Síntomas, señales y cuándo pedir ayuda',
                              onTap: () => _guardedNavigate(IaScreen(initialTopic: 'Depresión')),
                            ),
                            const SizedBox(width: 10),
                            _TopicCard(
                              title: 'Ansiedad',
                              subtitle: 'Técnicas para calmar y manejar ataques',
                              onTap: () => _guardedNavigate(IaScreen(initialTopic: 'Ansiedad')),
                            ),
                            const SizedBox(width: 10),
                            _TopicCard(
                              title: 'Insomnio',
                              subtitle: 'Rutinas y hábitos para mejorar el sueño',
                              onTap: () => _guardedNavigate(IaScreen(initialTopic: 'Insomnio')),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

=======
>>>>>>> feature/stabilize-before-main
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
<<<<<<< HEAD
                      onTap: () => _guardedNavigate(const DiarioScreen()),
=======
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiarioScreen(),
                          ),
                        );
                      },
>>>>>>> feature/stabilize-before-main
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/ia.svg",
                      onTap: () => _guardedNavigate(IaScreen()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/metas.svg",
<<<<<<< HEAD
                      onTap: () => _guardedNavigate(const MetasScreen()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/progreso.svg",
                      onTap: () => _guardedNavigate(const Progreso()),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/psicologos.svg",
                      onTap: () => _guardedNavigate(const Psicologos()),
=======
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MetasScreen()),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/progreso.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Progreso()),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/psicologos.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Psicologos()),
                        );
                      },
>>>>>>> feature/stabilize-before-main
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
<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final query = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('metas')
        .where('estado', isEqualTo: 'en_progreso')
        .orderBy('creada', descending: true);

    return StreamBuilder<QuerySnapshot>(
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
              final d = doc.data() as Map<String, dynamic>? ?? {};
              final titulo = (d['titulo'] ?? '').toString();
              final descripcion = (d['descripcion'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                    trailing: IconButton(
                      tooltip: 'Marcar como completada',
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await doc.reference.update({'estado': 'completada'});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Meta completada!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
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
      // Sin sesión: flor en 0
      return const AnimatedFlower(
        assetPath: 'assets/animations/flower.json',
        showOverlayRing: true,
        segments: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        fractionOverride: 0.0,
        segmentsCountOverride: 6,
      );
    }

    final metasCol = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('metas');

    // Un solo stream a toda la colección; contamos en memoria.
    return StreamBuilder<QuerySnapshot>(
      stream: metasCol.snapshots(),
      builder: (context, snap) {
        double fraction = 0.0;
        if (snap.hasData) {
          final all = snap.data!.docs;
          final total = all.length;
          if (total > 0) {
            final completed = all.where((d) {
              final m = d.data() as Map<String, dynamic>? ?? {};
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

  const _TopicCard({required this.title, required this.subtitle, required this.onTap});

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
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w300),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('Ver', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
=======
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final query = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('metas')
        .where('estado', isEqualTo: 'en_progreso')
        .orderBy('creada', descending: true);

    return StreamBuilder<QuerySnapshot>(
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
>>>>>>> feature/stabilize-before-main
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>? ?? {};
              final titulo = (d['titulo'] ?? '').toString();
              final descripcion = (d['descripcion'] ?? '').toString();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                    trailing: IconButton(
                      tooltip: 'Marcar como completada',
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await doc.reference.update({'estado': 'completada'});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Meta completada!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
<<<<<<< HEAD
        ),
      ),
=======
        );
      },
>>>>>>> feature/stabilize-before-main
    );
  }
}
