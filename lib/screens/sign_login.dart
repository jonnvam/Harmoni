import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/principal_screen.dart';
import 'package:flutter_application_1/services/auth_google.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/screens/restCodigo.dart';
=======
import 'package:flutter_application_1/services/auth_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/verificacion_signup.dart';
>>>>>>> origin/cambiosJacque

class SignLoginScreen extends StatefulWidget {
  const SignLoginScreen({super.key});

  @override
  State<SignLoginScreen> createState() => _SignLoginScreenState();
}

class _SignLoginScreenState extends State<SignLoginScreen> {
  bool isSignUpScreen = true;

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailUpCtrl = TextEditingController();
  final _passUpCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  final _fechaCtrl = TextEditingController();

  final _emailInCtrl = TextEditingController();
  final _passInCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailUpCtrl.dispose();
    _passUpCtrl.dispose();
    _fechaCtrl.dispose();
    _emailInCtrl.dispose();
    _passInCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaNacimiento(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day); // sugerir 18+
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaCtrl.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

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
                  const SizedBox(height: 10),

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

  int _calcularEdad(DateTime dob) {
    final hoy = DateTime.now();
    int edad = hoy.year - dob.year;
    final cumpleEsteAnio = DateTime(hoy.year, dob.month, dob.day);
    if (hoy.isBefore(cumpleEsteAnio)) edad--;
    return edad;
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
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Apellido'),
        ),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _apellidoCtrl,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Email'),
        ),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _emailUpCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Contraseña'),
        ),
        ContainerLogin(
          width: double.infinity,
          height: 53,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _passUpCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '••••••••',
              ),
            ),
          ),
        ),
<<<<<<< HEAD
        const SizedBox(height: 10),
=======
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextoDatos(texto: 'Fecha de nacimiento'),
        ),
        GestureDetector(
          onTap: () => _pickFechaNacimiento(context),
          child: AbsorbPointer(
            child: ContainerLogin(
              width: double.infinity,
              height: 53,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TextField(
                  controller: _fechaCtrl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'DD/MM/AAAA',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
>>>>>>> origin/cambiosJacque
        // Mantener el mismo espacio vertical: antes había un top:30 en el padding del botón
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: AuthButton(
            texto: 'Sign Up',
            isPressed: true,
            onPressed: () async {
              final nombre = _nombreCtrl.text.trim();
              final apellido = _apellidoCtrl.text.trim();
              final email = _emailUpCtrl.text.trim();
              final pass = _passUpCtrl.text;
              final dob = _fechaNacimiento;

              if (nombre.isEmpty ||
                  apellido.isEmpty ||
                  email.isEmpty ||
                  pass.length < 6 ||
                  dob == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Completa todos los campos (contraseña ≥ 6 y fecha).',
                    ),
                  ),
                );
                return;
              }
              final edad = _calcularEdad(dob);
              if (edad < 18) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Debes ser mayor de 18 años para registrarte.',
                    ),
                  ),
                );
                return;
              }
              try {
                await EmailAuthService().signUp(
                  nombre: nombre,
                  apellido: apellido,
                  email: email,
                  password: pass,
                  fechaNacimiento: dob,
                );

                if (!mounted) return;
                // Lleva a una pantalla que explique “te enviamos un correo”
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerificacionScreen(email: email),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.message ?? 'Error al registrarte')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error inesperado al registrarte.'),
                  ),
                );
              }
            },
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
                if (!mounted) return;
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
                // TODO: Implementar registro con Apple
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
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _emailInCtrl,
              keyboardType: TextInputType.emailAddress,
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
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: TextField(
              controller: _passInCtrl,
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RestCodigoScreen()),
                  );
                },
                child: const Text(
                  "Olvide mi contraseña",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                  ),
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
            onPressed: () async {
              final email = _emailInCtrl.text.trim();
              final pass = _passInCtrl.text;
              if (email.isEmpty || pass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa email y contraseña.')),
                );
                return;
              }

              try {
                final user = await EmailAuthService().login(
                  email: email,
                  password: pass,
                );
                if (!mounted) return;
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PrincipalScreen()),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'email-not-verified') {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificacionScreen(email: email),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'No se pudo iniciar sesión'),
                    ),
                  );
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error inesperado al iniciar sesión.'),
                  ),
                );
              }
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
                if (!mounted) return;
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
                // TODO: Implementar inicio de sesión con Apple
              },
            ),
          ],
        ),
      ],
    );
  }
}

const double fifty = 50; //Tamaño del boton
