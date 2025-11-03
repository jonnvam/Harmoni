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

class SecondPrincipalScreen extends StatefulWidget {
  const SecondPrincipalScreen({super.key});

  @override
  State<SecondPrincipalScreen> createState() => _SecondPrincipalScreenState();
}

class _SecondPrincipalScreenState extends State<SecondPrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;

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
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Triste",
                          icon: "assets/images/emotions/Triste.svg",
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
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Enojado",
                          icon: "assets/images/emotions/Enojado.svg",
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
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Miedo",
                          icon: "assets/images/emotions/Miedo.svg",
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
                        ),
                      ],
                    ),
                  ],
                ),

                if (showStep3) const SizedBox(height: 70),
                const AnimatedFlower(
                  assetPath: 'assets/animations/flower.json',
                  showOverlayRing: true,
                  segments: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                ),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiarioScreen(),
                          ),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/ia.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IaScreen()),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/metas.svg",
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
