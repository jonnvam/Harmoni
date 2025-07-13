import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    precacheImage(AssetImage("assets/images/flores/flor1.png"), context);
    precacheImage(AssetImage("assets/images/flores/flor2.png"), context);
    precacheImage(AssetImage("assets/images/flores/flor3.png"), context);
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
                          onTap: () {},
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
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Enojado",
                          icon: "assets/images/emotions/Enojado.svg",
                          onTap: () {},
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
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(width: 14),
                    Column(
                      children: [
                        EmotionButton(
                          text: "Miedo",
                          icon: "assets/images/emotions/Miedo.svg",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                if (showStep3) //ProgressBar
                  SizedBox(height: 70),
                FlowerProgress(progress: 0.5),
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
                                "assets/images/carousel/156.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          if (showStep4) //Menu Circular
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: CircularMenu(
                  fabIcon: SvgPicture.asset(
                    "assets/images/house.svg",
                    width: 30,
                    height: 30,
                  ),
                  items: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/images/psicologos.svg",
                        width: 30,
                        height: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/images/diario.svg",
                        width: 30,
                        height: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/images/metas.svg",
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
                        "assets/images/ia.svg",
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
