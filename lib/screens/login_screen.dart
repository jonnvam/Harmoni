import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
//import 'package:flutter_application_1/core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Bienvenida(),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 20, right: 20),
              child: Row(
                children: [
                  Text(
                    "Aqui comienaza tu espacio seguro",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Kantumruy Pro',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
              child: ContainerLogin(
                width: 365,
                height: 69,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.5, left: 7),
                        child: AuthButton(
                          
                          texto: 'Sign Up',
                          isPressed: isLoginPressed,
                          onPressed: () {
                            setState(() => isLoginPressed = !isLoginPressed);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.5, right: 7),
                        child: BotonLogin(
                          height: 53,
                          width: 170,
                          texto: 'Login',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
