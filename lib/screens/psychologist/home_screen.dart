import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';

class PsychologistHomeScreen extends StatelessWidget {
  const PsychologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const DropMenu(),
                  MaxWidthContainer(
                    child: _DashboardContent(),
                  ),
                ],
              ),
            ),
            // Menú circular inferior con las 3 opciones principales
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SemiCircularRadialMenu(
                  currentIconAsset: "assets/images/icon/house.svg",
                  ringColor: Colors.transparent,
                  items: [
                    // Home
                    
                    // Citas
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/agenda.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistAppointmentsScreen()),
                      ),
                    ),
                    // Pacientes
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/pacientes.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistPatientsScreen()),
                      ),
                    ),
                    // Disponibilidad
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
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('Inicia sesión para ver tu panel')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TitleSection(
          texto: 'Inicio',
          maxLines: 2,
          padding: EdgeInsets.only(top: 32),
        ),
        const SizedBox(height: 8),
        Text(
          'Resumen del día',
          style: TextStyles.textDicho.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('psychId', isEqualTo: uid)
              .orderBy('dateTime')
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data?.docs ?? [];
            final now = DateTime.now();
            final startOfDay = DateTime(now.year, now.month, now.day);
            final endOfDay = startOfDay.add(const Duration(days: 1));

            final all = docs.map((e) => (e.data() as Map<String, dynamic>? ?? {})).toList();
            // Próximas confirmadas de hoy
            final todaysConfirmed = all
                .where((d) {
                  final ts = d['dateTime'];
                  if (ts is! Timestamp) return false;
                  final dt = ts.toDate();
                  final status = (d['status'] ?? '').toString();
                  return dt.isAfter(startOfDay) && dt.isBefore(endOfDay) && status == 'confirmada';
                })
                .toList()
              ..sort((a, b) => (a['dateTime'] as Timestamp).toDate().compareTo((b['dateTime'] as Timestamp).toDate()));

            // Solicitudes pendientes (sin restricción de día)
            final pending = all.where((d) => (d['status'] ?? '').toString() == 'pendiente').toList()
              ..sort((a, b) => (a['dateTime'] as Timestamp).toDate().compareTo((b['dateTime'] as Timestamp).toDate()));

            return Column(
              children: [
                _InfoCard(
                  title: 'Próximas citas de hoy',
                  emptyText: 'No hay citas confirmadas para hoy',
                  items: todaysConfirmed.take(3).map((d) {
                    final name = (d['patientName'] ?? 'Paciente').toString();
                    final dt = (d['dateTime'] as Timestamp).toDate();
                    final hour = dt.hour.toString().padLeft(2, '0');
                    final min = dt.minute.toString().padLeft(2, '0');
                    return '$hour:$min · $name';
                  }).toList(),
                  trailing: todaysConfirmed.isNotEmpty
                      ? Text('${todaysConfirmed.length} en total', style: const TextStyle(fontSize: 12, color: Colors.black54))
                      : null,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Solicitudes pendientes',
                  emptyText: 'Sin solicitudes por ahora',
                  items: pending.take(3).map((d) {
                    final name = (d['patientName'] ?? 'Paciente').toString();
                    return name;
                  }).toList(),
                  trailing: pending.isNotEmpty
                      ? Text('${pending.length} pendientes', style: const TextStyle(fontSize: 12, color: Colors.black54))
                      : null,
                ),
                const SizedBox(height: 120),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final String emptyText;
  final Widget? trailing;

  const _InfoCard({required this.title, required this.items, required this.emptyText, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(emptyText, style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Kantumruy Pro'))
            else
              Column(
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                          const SizedBox(width: 6),
                          Expanded(child: Text(it, style: const TextStyle(fontSize: 14, fontFamily: 'Kantumruy Pro'))),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
