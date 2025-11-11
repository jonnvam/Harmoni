import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';

class PsychologistAppointmentsScreen extends StatelessWidget {
  const PsychologistAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
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
                          'Citas / Agenda',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Kantumruy Pro',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aquí verás las reservas de tus pacientes',
                          style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Kantumruy Pro'),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: uid == null
                              ? const Center(child: Text('Inicia sesión para ver tus citas'))
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('appointments')
                                      .where('psychId', isEqualTo: uid)
                                      .orderBy('dateTime')
                                      .snapshots(),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final docs = snap.data?.docs ?? [];
                                    if (docs.isEmpty) {
                                      return const Center(child: Text('Aún no tienes citas'));
                                    }
                                    return ListView.separated(
                                      itemCount: docs.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final d = docs[i].data() as Map<String, dynamic>? ?? {};
                                        final patientName = (d['patientName'] ?? 'Paciente').toString();
                                        final date = (d['dateTime'] as Timestamp?)?.toDate();
                                        final status = (d['status'] ?? 'pendiente').toString();
                                        final patientId = (d['patientId'] ?? '').toString();
                                        return _AppointmentTile(
                                          title: patientName,
                                          date: date,
                                          status: status,
                                          docRef: docs[i].reference,
                                          patientId: patientId,
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
            // Menú radial persistente
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SemiCircularRadialMenu(
                  currentIconAsset: "assets/images/icon/agenda.svg",
                  ringColor: Colors.transparent,
                  items: [
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/pacientes.svg",
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistPatientsScreen()),
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
}

class _AppointmentTile extends StatelessWidget {
  final String title;
  final DateTime? date;
  final String status;
  final DocumentReference docRef;
  final String patientId;
  const _AppointmentTile({required this.title, required this.date, required this.status, required this.docRef, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final dateStr = date != null ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')} ${date!.hour.toString().padLeft(2, '0')}:00' : '—';
    final color = status == 'confirmada'
        ? const Color(0xFF22C55E)
        : status == 'cancelada'
            ? const Color(0xFFEF4444)
            : const Color(0xFF6366F1);
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
        subtitle: Text('Fecha: $dateStr', style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Kantumruy Pro')),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
        ),
        onTap: () => _showActions(context),
      ),
    );
  }

  void _showActions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Acciones de la cita', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await docRef.update({'status': 'confirmada'});
                        if (patientId.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(patientId)
                              .collection('notifications')
                              .add({
                            'type': 'appointment',
                            'message': 'Tu cita fue confirmada',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita confirmada')));
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await docRef.update({'status': 'cancelada'});
                        if (patientId.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(patientId)
                              .collection('notifications')
                              .add({
                            'type': 'appointment',
                            'message': 'Tu cita fue cancelada',
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita cancelada')));
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Toca fuera para cerrar', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }
}
