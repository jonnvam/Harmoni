import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';

class PsychologistPatientsScreen extends StatelessWidget {
  const PsychologistPatientsScreen({super.key});

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
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('appointments')
                                      .where('psychId', isEqualTo: uid)
                                      .snapshots(),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final docs = snap.data?.docs ?? [];
                                    if (docs.isEmpty) {
                                      return const Center(child: Text('Sin pacientes aún'));
                                    }
                                    // Agrupar por patientId
                                    final Map<String, Map<String, dynamic>> patients = {};
                                    for (final d in docs) {
                                      final data = d.data() as Map<String, dynamic>? ?? {};
                                      final pid = (data['patientId'] ?? '') as String;
                                      if (pid.isEmpty) continue;
                                      patients.putIfAbsent(pid, () => {
                                            'name': (data['patientName'] ?? 'Paciente') as String,
                                            'count': 0,
                                          });
                                      patients[pid]!['count'] = (patients[pid]!['count'] as int) + 1;
                                    }
                                    final entries = patients.entries.toList();
                                    return ListView.separated(
                                      itemCount: entries.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final e = entries[i];
                                        return _PatientTile(name: e.value['name'] as String, count: e.value['count'] as int);
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
}

class _PatientTile extends StatelessWidget {
  final String name;
  final int count;
  const _PatientTile({required this.name, required this.count});

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
        subtitle: Text('$count citas', style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Kantumruy Pro')),
        leading: const CircleAvatar(child: Icon(Icons.person)),
      ),
    );
  }
}
