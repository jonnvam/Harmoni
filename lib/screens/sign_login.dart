import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';

class SignLoginScreen extends StatefulWidget {
  const SignLoginScreen({super.key});

  @override
  State<SignLoginScreen> createState() => _SignLoginScreenState();
}

class _SignLoginScreenState extends State<SignLoginScreen> {
  bool isSignUpScreen = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Texto superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,

            child:
                isSignUpScreen
                    ? TitleSection(texto: "Cuidar de ti también es importante")
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        //Bienvenidoa
                        Bienvenida(),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Aquí comienza tu espacio seguro",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Kantumruy Pro',
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                      ],
                    ),
          ),

          // Contenedor animado que engloba todo SignUp/Login
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: isSignUpScreen ? 155 : 165,
            bottom: 0,
            right: 0,
            left: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: screenWidth,
              height: isSignUpScreen ? 520 : 350,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  // Switch buttons
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borde3),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isSignUpScreen = true),
                            child: Container(
                              height: fifty,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    isSignUpScreen
                                        ? AppColors.fondo3
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Text(
                                'Sign Up',
                                style: TextStyles.textoSingLogin.copyWith(
                                  color:
                                      isSignUpScreen
                                          ? const Color(0xFFF0EDE8)
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isSignUpScreen = false),
                            child: Container(
                              height: fifty,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    !isSignUpScreen
                                        ? AppColors.fondo3
                                        : const Color.fromARGB(0, 0, 0, 0),
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Text(
                                'Login',
                                style: TextStyles.textoSingLogin.copyWith(
                                  color:
                                      !isSignUpScreen
                                          ? const Color(0xFFF0EDE8)
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Formulario dinámico
                  Expanded(
                    //esto es para que se pueda hacer scroll, ya si no caben los elementos en el scrollview
                    child: SingleChildScrollView(
                      //Es un if el ? es que se muestra el signUpForm o el loginForm el : es el else
                      child:
                          isSignUpScreen
                              ? _buildSignUpForm()
                              : _buildLoginForm(),
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

  //Este es el signUpForm que se muestra cuando se toca el signUpButton es todo lo que se engloba
  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Nombre'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Apellido'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Email'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Contraseña'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '••••••••',
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 70, top: 30),
          child: AuthButton(
            
            texto: 'Sign Up',
            isPressed: true,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  //El Formulario de Login
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          //Par que el texto no este muy pegado a la izquierda
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Email'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Contraseña'),
        ),
        const SizedBox(height: 0),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '••••••••',
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    "Recordarme",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      "Olvide mi contraseña",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 70, top: 30),
          child: AuthButton(
            
            texto: 'Login',
            isPressed: true,
            onPressed: () {
              //Aqui debe ir lalogica de la conexion a la base de datos y validacion de datos y el navigator push
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrincipalScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

const double fifty = 50;//Tamaño del boton
