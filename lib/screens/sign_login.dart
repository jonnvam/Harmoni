import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';
import 'package:flutter_application_1/services/auth_google.dart';

class SignLoginScreen extends StatefulWidget {
  const SignLoginScreen({super.key});

  @override
  State<SignLoginScreen> createState() => _SignLoginScreenState();
}

class _SignLoginScreenState extends State<SignLoginScreen> {
  bool isSignUpScreen = true;
  //final AuthGoogle _authGoogle = AuthGoogle();

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
                    ? const TitleSection(
                      texto: "Cuidar de ti también es importante",
                      maxLines: 3,
                      textAlign: TextAlign.left,
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        //Bienvenidoa
                        Bienvenida(),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: 32),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
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
        // Mantener el mismo espacio vertical: antes había un top:30 en el padding del botón
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: AuthButton(
            texto: 'Sign Up',
            isPressed: true,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: Text(
            "Registrarse con",
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Kantumruy Pro',
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthIconButton(
              iconPath: "assets/images/icon/google.svg",
              onPressed: () async {
                final user = await AuthService().signInWithGoogle(context);
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PrincipalScreen()),
                  );
                }
              },
            ),
            const SizedBox(width: 16),
            AuthIconButton(
              iconPath: "assets/images/icon/apple.svg",
              onPressed: () {
                print("Registrarse con Apple");
              },
            ),
          ],
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
            // Mantiene el inicio (left:12) del primer texto
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "Recordarme",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            // Simetría: alineamos el segundo texto al borde derecho con un padding similar
            const Padding(
              padding: EdgeInsets.only(right: 12),
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
        const SizedBox(height: 24),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.center,
          child: AuthButton(
            texto: 'Login',
            isPressed: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrincipalScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Text(
            "Iniciar Sesión con",
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Kantumruy Pro',
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthIconButton(
              iconPath: "assets/images/icon/google.svg",
              onPressed: () async {
                final user = await AuthService().signUpWithGoogle(context);
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PrincipalScreen()),
                  );
                }
              },
            ),

            const SizedBox(width: 16),
            AuthIconButton(
              iconPath: "assets/images/icon/apple.svg",
              onPressed: () {
                print("Iniciar sesión con Apple");
              },
            ),
          ],
        ),
      ],
    );
  }
}

const double fifty = 50; //Tamaño del boton
