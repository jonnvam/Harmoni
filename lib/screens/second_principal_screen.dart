import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/data/goals_manager.dart';
import 'package:flutter_application_1/components/animated_flower.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/data/emotion_journal.dart';
import 'package:flutter_application_1/data/diary_repo.dart';

class SecondPrincipalScreen extends StatefulWidget {
  const SecondPrincipalScreen({super.key});

  @override
  State<SecondPrincipalScreen> createState() => _SecondPrincipalScreenState();
}

class _SecondPrincipalScreenState extends State<SecondPrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;
  String currentScreen = "second";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //tuve que haer esto para que las imagenes se precarguen
    precacheImage(AssetImage("assets/images/flores/flor2.png"), context);
    precacheImage(AssetImage("assets/images/flores/flor3.png"), context);
    precacheImage(AssetImage("assets/images/flores/flor4.png"), context);
    precacheImage(AssetImage("assets/images/carousel/t1.jpg"), context);
    // Paso 2: mostrar parte media después de 300ms
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) setState(() => showStep2 = true);
    });
    // Paso 3: mostrar ProgressBar
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) setState(() => showStep3 = true);
    });
    //Paso 4 menu circular
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) setState(() => showStep4 = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalsManager = GoalsManager.instance;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                //TopUserHeader(
                DropMenu(),
                //TopFeeling(),
                if (showStep2) //Contenido Medio
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [TopFeeling()],
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        //esto es el boton de emociobes
                        EmotionButton(
                          text: "Feliz",
                          icon: "assets/images/emotions/Feliz.svg",
                          onTap: () async {
                            await EmotionJournal.instance.saveEmotion(EmotionType.happy);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Guardado: Feliz')),
                            );
                            // Create a diary note draft and navigate to Diario to edit
                            final id = await DiaryRepo.nextId();
                            final note = DiaryNote(
                              id: id,
                              date: DateTime.now(),
                              type: DiaryNoteType.text,
                              text: 'Hoy me sentí Feliz: ',
                            );
                            await DiaryRepo.instance.addNote(note);
                            if (!mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiarioScreen()));
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 6),
                      child: Column(
                        children: [
                          EmotionButton(
                            text: "Triste",
                            icon: "assets/images/emotions/Triste.svg",
                            onTap: () async {
                              await EmotionJournal.instance.saveEmotion(EmotionType.sad);
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
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DiarioScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Enojado",
                          icon: "assets/images/emotions/Enojado.svg",
                          onTap: () async {
                            await EmotionJournal.instance.saveEmotion(EmotionType.angry);
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiarioScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        EmotionButton(
                          text: "Sorpresa",
                          icon: "assets/images/emotions/Sorpresa.svg",
                          onTap: () async {
                            await EmotionJournal.instance.saveEmotion(EmotionType.surprised);
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiarioScreen()));
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: 14),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Miedo",
                          icon: "assets/images/emotions/Miedo.svg",
                          onTap: () async {
                            await EmotionJournal.instance.saveEmotion(EmotionType.fear);
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiarioScreen()));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (showStep3) //ProgressBar
                  SizedBox(height: 70),
                // Nueva animación Lottie de la flor (coloca tu JSON en assets/animations/flower.json)
                const AnimatedFlower(
                  assetPath: 'assets/animations/flower.json',
                  showOverlayRing: true,
                  segments: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                ),
                SizedBox(height: 70),
                ContainerC1(
                  width: 300,
                  alignment: Alignment.centerLeft,
                  height: 170,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 8),
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
                          SizedBox(height: 10),
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
                                  side: BorderSide(
                                    width: 3,
                                    color: const Color(0xFF6366F1),
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
                // Metas en progreso
                ValueListenableBuilder(
                  valueListenable: goalsManager,
                  builder: (_, __, ___) {
                    final inProgress = goalsManager.inProgressGoals;
                    if (inProgress.isEmpty) {
                      return const SizedBox.shrink();
                    }
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
                        ...inProgress
                            .map((g) => _InProgressGoalTile(goal: g))
                            .toList(),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          if (showStep4) //Menu Semi-circular nuevo
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
                            builder: (context) => DiarioScreen(),
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
                          MaterialPageRoute(
                            builder: (context) => MetasScreen(),
                          ),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/progreso.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Progreso(),
                          ),
                        );
                      },
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/psicologos.svg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Psicologos()),
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

class _InProgressGoalTile extends StatelessWidget {
  final Goal goal;
  const _InProgressGoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    final manager = GoalsManager.instance;
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
            goal.titulo,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            goal.descripcion,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w300,
            ),
          ),
          trailing: IconButton(
            tooltip: 'Marcar como completada',
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () {
              manager.completeGoal(goal);
            },
          ),
        ),
      ),
    );
  }
}
