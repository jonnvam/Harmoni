import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/core/text_styles.dart';
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
                  padding: const EdgeInsets.only(top: 20, left: 45),
                  child: Row(
                    children: [
                      //en alvarito seria $Name pero eso creo en el json o en la logica
                      Text("Hola Alvarito", style: TextStyles.textInicioName),
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
                                onPressed: () {},
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
              padding: const EdgeInsets.only(bottom: 0),
              child: CircularMenu(
                fabIcon: SvgPicture.asset(
                  "assets/images/icon/house.svg",
                  width: 30,
                  height: 30,
                ),
                items: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon/psicologos.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
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
                        MaterialPageRoute(builder: (context) => IaScreen()),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon/ia.svg",
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
