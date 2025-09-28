import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 45),
                      child: Column(
                        children: [
                          Text(
                            "Hola Alvarito",
                            style: TextStyles.textInicioName,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15),
                      child: InfoBubbleButton(
                        message:
                            "Aquí podrás acceder a recursos y tips personalizados sobre bienestar emocional.",
                        autoHideDuration: const Duration(seconds: 4),
                        iconSize: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                ContainerC2(
                  width: 350,
                  alignment: Alignment.center,
                  height: 80,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Compartir Paginas del Diario",
                              style: TextStyles.textDLogin,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Row(
                            children: [
                              SvgPicture.asset("assets/images/ia/copy.svg"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                ContainerC1(
                  height: 145,
                  width: 350,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Text(
                              "Entendiendo la ansiedad",
                              style: TextStyles.textDLogin,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 45),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/images/ia/lamp-charge.svg",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 35,
                        left: 35,
                        right: 20,
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ContainerC1(
                                width: 140,
                                height: 145,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Habitos \nSaludables",
                                  style: TextStyles.textDLogin,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 60),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ContainerC1(
                                alignment: Alignment.center,
                                width: 140,
                                height: 145,
                                child: const Text(
                                  "Identificar \nsíntomas de\nestres",
                                  style: TextStyles.textDLogin,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerC2(
                      width: 330,
                      height: 70,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Compartir alguna idea',
                                  hintStyle: TextStyles.textDLogin,
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/ia/level.svg"),
                            SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/ia.svg",
                ringColor: Colors.transparent,
                items: [
                  // Diario (left)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                  ),
                  // Metas
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
                    iconAsset: "assets/images/icon/house.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPrincipalScreen(),
                        ),
                      );
                    },
                  ),
                  // Progreso
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {},
                  ),
                  // Psicólogos (right)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {},
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
