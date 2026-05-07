import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/sign_login.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_1/services/user_profile_service.dart';
import 'package:flutter_application_1/services/auth_google.dart';

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
    final providers = _auth.currentUser?.providerData ?? const [];
    return providers.any((provider) => provider.providerId == 'google.com');
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
      final profile = await UserProfileService.instance.loadProfileAfterAuth(
        user.uid,
      );

      if (profile == null || profile.role == null) {
        throw Exception('No se encontró el perfil del usuario.');
      }

      final collectionName = profile.collectionName;

      await _db.collection(collectionName).doc(user.uid).set({
        'nombre': nombre,
        'apellido': apellido,
        'email': user.email,
        'fechaNacimiento': Timestamp.fromDate(fecha),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db
          .collection(UserProfileService.collectionUsuariosIndex)
          .doc(user.uid)
          .set({
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName('$nombre $apellido');

      if (!mounted) return;

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados.')),
      );
    } catch (e) {
      debugPrint('AJUSTES SAVE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron guardar los cambios: $e')),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _auth.currentUser?.email;

    if (email == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enviamos un correo a $email para cambiar tu contraseña.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('PASSWORD RESET ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo de cambio de contraseña.'),
        ),
      );
    }
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';

    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  DateTime? _parseFechaNacimiento(dynamic rawFecha) {
    if (rawFecha is Timestamp) {
      return rawFecha.toDate();
    }

    if (rawFecha is String) {
      return DateTime.tryParse(rawFecha);
    }

    return null;
  }

  Widget _buildProfileContent({
    required User user,
    required Map<String, dynamic> data,
  }) {
    final nombre = (data['nombre'] ?? '').toString();
    final apellido = (data['apellido'] ?? '').toString();
    final email = (data['email'] ?? user.email ?? '').toString();

    final fechaNac = _parseFechaNacimiento(data['fechaNacimiento']);

    if (!_isEditing) {
      _nombreCtrl.text = nombre;
      _apellidoCtrl.text = apellido;
      _emailCtrl.text = email;
      _dob = fechaNac;
      _fechaCtrl.text = _formatFecha(fechaNac);
    }

    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;

    final initials =
        ((nombre.isNotEmpty ? nombre[0] : '') +
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

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black12,
                    backgroundImage: hasPhoto ? NetworkImage(user.photoURL!) : null,
                    child: hasPhoto
                        ? null
                        : Text(
                            initials.isEmpty ? '🙂' : initials,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.black87,
                            ),
                          ),
                  ),

                  const SizedBox(height: 10),

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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

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
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isGoogleProvider ? "Autenticación" : "Contraseña",
                style: TextStyles.textDatos,
              ),
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

          const SizedBox(height: 40),

          Align(
            alignment: Alignment.center,
            child: AuthButton(
              texto: "Cerrar sesión",
              isPressed: true,
              onPressed: () async {
                final nav = Navigator.of(context);

                final confirm =
                    await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirmar salida"),
                        content: const Text(
                          "¿Deseas cerrar tu sesión en Harmoni?",
                        ),
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
                    ) ??
                    false;

                if (!mounted || !confirm) return;

                await AuthService().signOut();

                nav.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const SignLoginScreen(),
                  ),
                  (_) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 200),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const SignLoginScreen();
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FutureBuilder<AuthUserProfile?>(
            future: UserProfileService.instance.loadProfileAfterAuth(user.uid),
            builder: (context, profileSnap) {
              if (profileSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileSnap.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar perfil: ${profileSnap.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final profile = profileSnap.data;

              if (profile == null || profile.role == null) {
                return const Center(
                  child: Text('No se encontró el perfil del usuario.'),
                );
              }

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _db
                    .collection(profile.collectionName)
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar datos: ${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snap.hasData || snap.data?.data() == null) {
                    return const Center(
                      child: Text('No se encontraron datos del perfil.'),
                    );
                  }

                  final data = snap.data!.data()!;

                  return _buildProfileContent(
                    user: user,
                    data: data,
                  );
                },
              );
            },
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
                    MaterialPageRoute(
                      builder: (context) => SecondPrincipalScreen(),
                    ),
                  );
                },
                items: [
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa el test inicial para desbloquear esta sección.',
                          ),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa el test inicial para desbloquear esta sección.',
                          ),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa el test inicial para desbloquear esta sección.',
                          ),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa el test inicial para desbloquear esta sección.',
                          ),
                        ),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Completa el test inicial para desbloquear esta sección.',
                          ),
                        ),
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