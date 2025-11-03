import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/assessment/phq_gad_test_screen.dart';
//import 'package:carousel_slider/carousel_slider.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool showStep2 = false;
  bool showStep3 = false;
  bool showStep4 = false;

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
                const Padding(padding: EdgeInsets.only(top: 60)),
                Carousel(),
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
                    onTap: () => _guardedNavigate(Container()),
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () => _guardedNavigate(Container()),
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
