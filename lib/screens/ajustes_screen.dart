import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';

class AjustesPerfil extends StatefulWidget {
  const AjustesPerfil({super.key});

  @override
  State<AjustesPerfil> createState() => _AjustesPerfilState();
}

class _AjustesPerfilState extends State<AjustesPerfil> {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 55, right: 15),
                      child: SettingButton(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 30),
                      child: Text("Ajustes", style: TextStyles.textAjuste),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [AvatarTop()],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text("Nombre ", style: TextStyles.textDatos),
                        ),
                        ContainerLogin(
                          width: 160,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text("Apellido", style: TextStyles.textDatos),
                        ),
                        ContainerLogin(
                          width: 160,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Empieza Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Text("Email", style: TextStyles.textDatos),
                        ),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //Fecha de nacimiento
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            "Fecha de nacimiento",
                            style: TextStyles.textDatos,
                          ),
                        ),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Contraseña
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Contraseña",
                            style: TextStyles.textDatos,
                          ),
                        ),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '••••••••',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Numero de tarjeta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: Text(
                            "Numero de tarjeta",
                            style: TextStyles.textDatos,
                          ),
                        ),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            "Fecha de Expiración",
                            style: TextStyles.textDatos,
                          ),
                        ),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 55, right: 15),
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(224, 231, 255, 0.85),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            "Guardar",
                            style: TextStyles.textEditar,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 200),
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
                    MaterialPageRoute(builder: (context) => SecondPrincipalScreen()),
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
                      Navigator.push(context, MaterialPageRoute(builder:(context) => DiarioScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder:(context) => MetasScreen()));
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
