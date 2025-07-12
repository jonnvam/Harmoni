import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TitleSection(texto: "Cuidar de ti también es importante"),

            // Botones Sign Up y Login
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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

            // Nombre y Apellido
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextoDatos(texto: "Nombre"),
                        const SizedBox(height: 8),
                        ContainerLogin(
                          width: double.infinity,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextoDatos(texto: "Apellido"),
                        const SizedBox(height: 8),
                        ContainerLogin(
                          width: double.infinity,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoDatos(texto: "Email"),
                  const SizedBox(height: 8),
                  ContainerLogin(
                    width: double.infinity,
                    height: 53,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fecha de Nacimiento
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoDatos(texto: "Fecha de Nacimiento"),
                  const SizedBox(height: 8),
                  ContainerLogin(
                    width: double.infinity,
                    height: 53,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contraseña y Confirmar Contraseña
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextoDatos(texto: "Contraseña"),
                        const SizedBox(height: 8),
                        ContainerLogin(
                          width: double.infinity,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextoDatos(texto: "Confirmar Contraseña"),
                        const SizedBox(height: 8),
                        ContainerLogin(
                          width: double.infinity,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botón Final Sign Up
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 90, right: 90),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.5, left: 7),
                      child: BotonLogin(
                        height: 53,
                        width: 170,
                        texto: "Sign Up",
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
          ],
        ),
      ),
    );
  }
}