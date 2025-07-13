import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
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
                      child: Column(
                        children: [
                          SvgPicture.asset("assets/images/ia/info-circle.svg"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                ContainerC2(
                  width: 320,
                  alignment: Alignment.centerLeft,
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
                  width: 320,
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
                            SvgPicture.asset("assets/images/ia/lamp-charge.svg"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 35, left: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          const SizedBox(width: 40),
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
              padding: const EdgeInsets.only(bottom: 0),
              child: CircularMenu(
                fabIcon: SvgPicture.asset(
                  "assets/images/icon/ia.svg",
                  width: 30,
                  height: 30,
                ),
                items: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/images/icon/psicologos.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DiarioScreen()));
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon/diario.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/images/icon/metas.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPrincipalScreen(),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon/house.svg",
                      width: 30,
                      height: 30,
                    ),
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
