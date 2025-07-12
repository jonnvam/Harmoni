import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';

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
      backgroundColor: AppColors.fondo,
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
                Row(children: [Padding(
                  padding: const EdgeInsets.only(top: 30, left: 30),
                  child: Text("Ajustes", style: TextStyles.textAjuste),
                )]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                 [AvatarTop(

                 )]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
