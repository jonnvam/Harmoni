import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patient_detail_screen.dart';
import 'package:flutter_application_1/services/appointment_service.dart';
import 'package:shimmer/shimmer.dart';

class PsychologistPatientsScreen extends StatefulWidget {
  const PsychologistPatientsScreen({super.key});

  @override
  State<PsychologistPatientsScreen> createState() =>
      _PsychologistPatientsScreenState();
}

class _PsychologistPatientsScreenState extends State<PsychologistPatientsScreen> {
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>>? _patientsStream;

  void _loadStream(String uid) {
    _patientsStream =
        AppointmentService.instance.getAssignedPatients(uid);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _patientsStream == null) {
      _loadStream(uid);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const DropMenu(),
                Expanded(
                  child: MaxWidthContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Pacientes',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Kantumruy Pro',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Listado de pacientes con citas reservadas',
                          style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Kantumruy Pro'),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: uid == null
                              ? const Center(child: Text('Inicia sesión para ver tus pacientes'))
                              : StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                                  stream: _patientsStream,
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return const _PatientSkeletonList();
                                    }
                                    if (snap.hasError) {
                                      return _StateMessage(
                                        icon: Icons.error_outline,
                                        title: 'No se pudieron cargar tus pacientes',
                                        message: 'Revisa tu conexión e inténtalo de nuevo.',
                                        actionText: 'Reintentar',
                                        onAction: () {
                                          setState(() {
                                            _loadStream(uid);
                                          });
                                        },
                                      );
                                    }
                                    final docs = snap.data ?? [];
                                    if (docs.isEmpty) {
                                      return _StateMessage(
                                        icon: Icons.groups_outlined,
                                        title: 'Sin pacientes aún',
                                        message: 'Cuando tengas citas activas verás a tus pacientes aquí.',
                                        actionText: 'Actualizar',
                                        onAction: () {
                                          setState(() {
                                            _loadStream(uid);
                                          });
                                        },
                                      );
                                    }
                                    return ListView.separated(
                                      itemCount: docs.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final doc = docs[i];
                                        final data = doc.data() ?? {};
                                        final name = _patientNameFrom(data);
                                        final photoUrl = _patientPhotoFrom(data);
                                        return _PatientTile(
                                          name: name,
                                          count: null,
                                          patientId: doc.id,
                                          photoUrl: photoUrl,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SemiCircularRadialMenu(
                  currentIconAsset: "assets/images/icon/pacientes.svg",
                  ringColor: Colors.transparent,
                  items: [
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/agenda.svg",
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistAppointmentsScreen()),
                      ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/house.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistHomeScreen()),
                      ),
                    ),
                    
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/disponi.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistAvailabilityScreen()),
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

  String _patientNameFrom(Map<String, dynamic> data) {
    final displayName = (data['displayName'] ?? '').toString().trim();
    final nombre = (data['nombre'] ?? '').toString().trim();
    final apellido = (data['apellido'] ?? '').toString().trim();
    final full = [nombre, apellido]
        .where((value) => value.isNotEmpty)
        .join(' ')
        .trim();
    return displayName.isNotEmpty
        ? displayName
        : (full.isNotEmpty ? full : 'Paciente');
  }

  String _patientPhotoFrom(Map<String, dynamic> data) {
    return (data['photoUrl'] ?? data['foto'] ?? data['fotoUrl'])
        .toString()
        .trim();
  }
}

class _PatientTile extends StatelessWidget {
  final String name;
  final int? count;
  final String patientId;
  final String? photoUrl;
  const _PatientTile({
    required this.name,
    required this.count,
    required this.patientId,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
        subtitle: Text(
          count == null ? 'Paciente activo' : '$count citas',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Kantumruy Pro',
          ),
        ),
        leading: _PatientAvatar(photoUrl: photoUrl, name: name),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patientId: patientId, patientName: name),
          ),
        ),
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _PatientAvatar({required this.photoUrl, required this.name});

  String _initialsFrom(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 'P';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = (photoUrl ?? '').trim();
    if (url.isEmpty) {
      return CircleAvatar(child: Text(_initialsFrom(name)));
    }

    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(url),
    );
  }
}

class _PatientSkeletonList extends StatelessWidget {
  const _PatientSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.black38),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Kantumruy Pro',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontFamily: 'Kantumruy Pro',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
