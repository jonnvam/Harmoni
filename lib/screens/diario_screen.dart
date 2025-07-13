import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM', 'es_MX').format(DateTime.now()),
                            style: TextStyle(
                              fontFamily: 'Kantumruy Pro',
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SevenDayCalendar(currentDate: DateTime.now()),

                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  top: 25,
                                ),
                                child: Text(
                                  "Hola Tyler",
                                  style: TextStyles.textDiario,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  top: 5,
                                ),
                                child: Text(
                                  "Tus pensamientos importan, regístralos aquí",
                                  style: TextStyles.textDiario2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 45),
                      Column(
                        children: [
                          Row(
                            children: [
                              ContainerC2(
                                width: 275,
                                height: 95,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "¿Cómo te sientes hoy?",
                                            style: TextStyles.textDiario3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Registra tus emociones y pensamientos \npara seguir tu bienestar",
                                            style: TextStyles.textDiario4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              ContainerC1(
                                width: 45,
                                height: 120,
                                child: SizedBox(
                                  width: 45,
                                  height: 120,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(height: 5),
                                      safeSvg(
                                        "assets/images/diario/edit.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                     safeSvg(
                                        "assets/images/diario/microphone-2.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                      safeSvg(
                                        "assets/images/diario/gallery.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ContainerC2(
                            height: 100,
                            width: 300,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                safeSvg(
                                  "assets/images/diario/edit.svg",
                                  width: 30,
                                  height: 30,
                                ),
                                safeSvg(
                                  "assets/images/diario/microphone-2.svg",
                                  width: 30,
                                  height: 30,
                                ),
                                safeSvg(
                                  "assets/images/diario/gallery.svg",
                                  width: 30,
                                  height: 30,
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                          // Row(children: [Column()]),
                        ],
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
              padding: const EdgeInsets.only(bottom: 0),
              child: CircularMenu(
                fabIcon: SvgPicture.asset(
                  "assets/images/icon/diario.svg",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IaScreen()),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon/ia.svg",
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
Widget safeSvg(String path, {double? width, double? height}) {
  try {
    return SvgPicture.asset(path, width: width, height: height);
  } catch (e) {
    return Icon(Icons.error, color: Colors.red);
  }
}
