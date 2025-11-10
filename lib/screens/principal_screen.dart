import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/core/text_styles.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/assessment/phq_gad_test_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
=======
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/assessment/phq_gad_test_screen.dart';
//import 'package:carousel_slider/carousel_slider.dart';
>>>>>>> feature/stabilize-before-main

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;

  void _guardedNavigate(Widget screen) {
    if (!AppState.instance.isTestCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  void initState() {
    super.initState();
    // Enforce initial test completion: send user to the test if not completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AppState.instance.isTestCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PhqGadTestScreen()),
        );
      }
    });
  }

  void _guardedNavigate(Widget screen) {
    if (!AppState.instance.isTestCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
                DropMenu(),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 45),
                  child: Row(
                    children: [
                      HolaNombre(style: TextStyles.textInicioName, prefix: "Hola",),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 31, top: 5),
                  child: Row(
                    children: [
                      Text(
                        "Estamos aquí para ayudarte a cuidar tu \nbienestar mental",
                        style: TextStyles.textDicho,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 31, right: 32),
                  child: ContainerC1(
                    width: 339,
                    height: 125,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 11,
                            top: 6,
                            right: 25,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Comienza tu estudio \ninicial",
                                style: TextStyles.textInicioC1,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 35,
                              child: CircularElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PhqGadTestScreen()),
                                  );
                                },
                                child: SvgPicture.asset(
                                  "assets/images/export.svg",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                  const SizedBox(height: 40),

                  // ====== Carousel de temas recomendados (mejorado diseño + autoplay R->L) ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 6, bottom: 8),
                          child: Text('Temas recomendados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 6),

                        CarouselSlider.builder(
                          itemCount: 4,
                          itemBuilder: (context, index, realIdx) {
                            // build slides: 0=Depresión,1=Ansiedad,2=Insomnio,3=Hora de escribir
                            if (index == 3) {
                              return TopicCard(
                                title: 'Hora de escribir',
                                subtitle: 'Abre tu diario y escribe una nota',
                                icon: Icons.edit,
                                backgroundColor: const Color(0xFFE0E7FF),
                                onTap: () => _guardedNavigate(DiarioScreen()),
                              );
                            }

                            final data = [
                              {
                                'title': 'Depresión',
                                'subtitle': 'Síntomas, señales y cuándo pedir ayuda',
                                'icon': Icons.mood_bad,
                                'color': const Color(0xFFE0E7FF),
                                'topic': 'Depresión'
                              },
                              {
                                'title': 'Ansiedad',
                                'subtitle': 'Técnicas para calmar y manejar ataques',
                                'icon': Icons.self_improvement,
                                'color': const Color(0xFFE0E7FF),
                                'topic': 'Ansiedad'
                              },
                              {
                                'title': 'Insomnio',
                                'subtitle': 'Rutinas y hábitos para mejorar el sueño',
                                'icon': Icons.bedtime,
                                'color': const Color(0xFFE0E7FF),
                                'topic': 'Insomnio'
                              },
                            ];

                            final item = data[index];
                            return TopicCard(
                              title: item['title'] as String,
                              subtitle: item['subtitle'] as String,
                              icon: item['icon'] as IconData,
                              backgroundColor: item['color'] as Color,
                              onTap: () => _guardedNavigate(IaScreen(initialTopic: item['topic'] as String)),
                            );
                          },
                          options: CarouselOptions(
                            height: 140,
                            viewportFraction: 0.8,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayAnimationDuration: const Duration(milliseconds: 700),
                            reverse: true, // move right-to-left
                            enableInfiniteScroll: true,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
                    onTap: () => _guardedNavigate(DiarioScreen()),
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
=======
                    onTap: () => _guardedNavigate(Container()),
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () => _guardedNavigate(Container()),
>>>>>>> feature/stabilize-before-main
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

class TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final IconData? icon;

  const TopicCard({required this.title, required this.subtitle, required this.onTap, this.backgroundColor, this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool colored = backgroundColor != null;
    // Determine if background is light to choose readable foreground colors
    final bool lightBg = colored
        ? (backgroundColor!.computeLuminance() > 0.5)
        : false;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colored ? backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colored && !lightBg ? Colors.white24 : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: colored ? (lightBg ? AppColors.primary : Colors.white) : AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colored ? (lightBg ? Colors.black : Colors.white) : Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: colored ? (lightBg ? Colors.black54 : Colors.white70) : Colors.black54, fontWeight: FontWeight.w300),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('Ver', style: TextStyle(color: colored ? (lightBg ? AppColors.primary : Colors.white) : AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
