import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/screens/sign_login.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjustesPerfil extends StatefulWidget {
  const AjustesPerfil({super.key});

  @override
  State<AjustesPerfil> createState() => _AjustesPerfilState();
}

class _AjustesPerfilState extends State<AjustesPerfil> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _isEditing = false;

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  DateTime? _dob;

  bool get _isGoogleProvider {
    final p = _auth.currentUser?.providerData ?? const [];
    return p.any((e) => e.providerId == 'google.com');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _fechaCtrl.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final nombre = _nombreCtrl.text.trim();
    final apellido = _apellidoCtrl.text.trim();
    final fecha = _dob;

    if (nombre.isEmpty || apellido.isEmpty || fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, apellido y fecha.')),
      );
      return;
    }

    try {
      // Firestore
      await _db.collection('usuarios').doc(user.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'email': user.email,
        'fechaNacimiento': Timestamp.fromDate(fecha),
      }, SetOptions(merge: true));

      // FirebaseAuth displayName
      await user.updateDisplayName('$nombre $apellido');

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron guardar los cambios.')),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _auth.currentUser?.email;
    if (email == null) return;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviamos un correo a $email para cambiar tu contraseña.')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el correo de cambio de contraseña.')),
      );
    }
  }

  String _formatFecha(DateTime? d) {
    if (d == null) return '';
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      // Si no hay sesión, regresa al login
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignLoginScreen()),
          (_) => false,
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
<<<<<<< HEAD
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

                const SizedBox(height: 40),
=======
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _db.collection('usuarios').doc(user.uid).snapshots(),
            builder: (context, snap) {
              // Esperando data
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
>>>>>>> origin/cambiosJacque

              final data = snap.data?.data() ?? {};
              final nombre = (data['nombre'] ?? '').toString();
              final apellido = (data['apellido'] ?? '').toString();
              final email = user.email ?? (data['email'] ?? '').toString();
              final ts = data['fechaNacimiento'];
              final fechaNac = (ts is Timestamp) ? ts.toDate() : null;

              // Inicializa controllers solo cuando NO estamos editando (para no pisar cambios en vivo)
              if (!_isEditing) {
                _nombreCtrl.text = nombre;
                _apellidoCtrl.text = apellido;
                _emailCtrl.text = email;
                _dob = fechaNac;
                _fechaCtrl.text = _formatFecha(fechaNac);
              }

              final hasPhoto = (user.photoURL != null && user.photoURL!.isNotEmpty);
              final initials = ((nombre.isNotEmpty ? nombre[0] : '') +
                      (apellido.isNotEmpty ? apellido[0] : ''))
                  .toUpperCase();

              return SingleChildScrollView(
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

                    // Avatar + Editar
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.black12,
                              backgroundImage: hasPhoto ? NetworkImage(user.photoURL!) : null,
                              child: hasPhoto
                                  ? null
                                  : Text(
                                      initials.isEmpty ? '🙂' : initials,
                                      style: const TextStyle(fontSize: 32, color: Colors.black87),
                                    ),
                            ),
                            const SizedBox(height: 10),
                            // Botón Editar / Guardar
                            InkWell(
                              onTap: () async {
                                if (_isEditing) {
                                  await _saveChanges();
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: ContainerAjustes(
                                width: 120,
                                height: 36,
                                child: Center(
                                  child: Text(
                                    _isEditing ? "Guardar" : "Editar",
                                    style: TextStyles.textEditar,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nombre y Apellido
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nombre", style: TextStyles.textDatos),
                            const SizedBox(height: 6),
                            ContainerLogin(
                              width: 160,
                              height: 53,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  controller: _nombreCtrl,
                                  enabled: _isEditing,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Apellido", style: TextStyles.textDatos),
                            const SizedBox(height: 6),
                            ContainerLogin(
                              width: 160,
                              height: 53,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  controller: _apellidoCtrl,
                                  enabled: _isEditing,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Email (solo lectura)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email", style: TextStyles.textDatos),
                        const SizedBox(height: 6),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _emailCtrl,
                              enabled: false,
                              decoration: const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Fecha de nacimiento (editable solo en modo edición)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha de nacimiento", style: TextStyles.textDatos),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _isEditing ? _pickFechaNacimiento : null,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: ContainerLogin(
                              width: 340,
                              height: 53,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
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
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Contraseña o Google vinculado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isGoogleProvider ? "Autenticación" : "Contraseña", style: TextStyles.textDatos),
                        const SizedBox(height: 6),
                        ContainerLogin(
                          width: 340,
                          height: 53,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _isGoogleProvider
                                        ? "Cuenta de Google vinculada"
                                        : "••••••••",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                if (!_isGoogleProvider)
                                  TextButton(
                                    onPressed: _sendPasswordReset,
                                    child: const Text("Cambiar"),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Si NO estamos editando, no mostramos "Guardar" adicional (ya está bajo el avatar).
                    // Aquí puedes añadir más campos cuando quieras (teléfono, bio, etc.)

                    const SizedBox(height: 40),

                    // Cerrar sesión
                    Align(
                      alignment: Alignment.center,
                      child: AuthButton(
                        texto: "Cerrar sesión",
                        isPressed: true,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirmar salida"),
                              content: const Text("¿Deseas cerrar tu sesión en Harmoni?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Cerrar sesión"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const SignLoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 200),
                  ],
                ),
<<<<<<< HEAD

                const SizedBox(height: 200),

              ],
            ),
=======
              );
            },
>>>>>>> origin/cambiosJacque
          ),

          // Menú radial inferior (igual que el tuyo)
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MetasScreen()),
                      );
                    },
                  ),
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
