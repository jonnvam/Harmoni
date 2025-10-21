import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';

class EmergenciaScreen extends StatefulWidget {
  const EmergenciaScreen({super.key});

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen> {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ContainerC1(
                      width: 334,
                      height: 511,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 28,
                              left: 25,
                              right: 40,
                            ),
                            child: Text(
                              "¿Te sientes en crisis o en peligro?",
                              style: TextStyles.textBlackLogin,
                            ),
                          ),
                          SizedBox(
                            height: 70,
                            width: 270,
                            child: Text(
                              'Tu bienestar es lo más importante. No estás solo.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Kantumruy Pro',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 290,
                            height: 35,
                            child: Text(
                              "Contactos de Emergencia",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontFamily: 'Mandali',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                onCenterDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondPrincipalScreen(),
                    ),
                  );
                },
                items: [
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Psicologos()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MetasScreen()),
                      );
                    },
                  ),

                  // Home (center of ring)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {},
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
