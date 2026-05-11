import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patient_detail_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_application_1/services/psychologist_patients_service.dart';

class PsychologistPatientsScreen extends StatelessWidget {
  const PsychologistPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            'Listado de pacientes vinculados contigo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Kantumruy Pro',
                            ),
                          ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: StreamBuilder<List<LinkedPatientModel>>(
                              stream:
                                  PsychologistPatientsService.instance
                                      .watchMyLinkedPatients(),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const _PatientSkeletonList();
                                }

                                if (snap.hasError) {
                                  return _StateMessage(
                                    icon: Icons.error_outline,
                                    title:
                                        'No se pudieron cargar tus pacientes',
                                    message:
                                        'Revisa tu conexión e inténtalo de nuevo.',
                                    actionText: 'Reintentar',
                                    onAction: () {},
                                  );
                                }

                                final patients = snap.data ?? [];

                                if (patients.isEmpty) {
                                  return const _StateMessage(
                                    icon: Icons.groups_outlined,
                                    title: 'Sin pacientes aún',
                                    message:
                                        'Cuando confirmes una cita, el paciente aparecerá aquí.',
                                    actionText: 'Actualizar',
                                    onAction: null,
                                  );
                                }

                                return ListView.separated(
                                  itemCount: patients.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, i) {
                                    final patient = patients[i];

                                    return _PatientTile(
                                      name: patient.patientName,
                                      count: null,
                                      patientId: patient.patientUid,
                                      photoUrl: null,
                                      linkedAt: patient.createdAt,
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
                      onTap:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const PsychologistAppointmentsScreen(),
                            ),
                          ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/house.svg",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PsychologistHomeScreen(),
                            ),
                          ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/disponi.svg",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const PsychologistAvailabilityScreen(),
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

class _PatientTile extends StatelessWidget {
  final String name;
  final int? count;
  final String patientId;
  final String? photoUrl;
  final DateTime? linkedAt;

  const _PatientTile({
    required this.name,
    required this.count,
    required this.patientId,
    this.photoUrl,
    this.linkedAt,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle =
        linkedAt == null
            ? 'Paciente activo'
            : 'Paciente activo · Vinculado el ${_formatDate(linkedAt!)}';

    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Kantumruy Pro',
          ),
        ),
        subtitle: Text(
          count == null ? subtitle : '$count citas',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Kantumruy Pro',
          ),
        ),
        leading: _PatientAvatar(photoUrl: photoUrl, name: name),
        trailing: const Icon(
          Icons.chevron_right,
          size: 18,
          color: Colors.black38,
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PatientDetailScreen(
                      patientId: patientId,
                      patientName: name,
                    ),
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

    return CircleAvatar(backgroundImage: CachedNetworkImageProvider(url));
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
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionText,
    this.onAction,
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
            if (onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}
