import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';

class PsychologistAvailabilityScreen extends StatefulWidget {
  const PsychologistAvailabilityScreen({super.key});

  @override
  State<PsychologistAvailabilityScreen> createState() => _PsychologistAvailabilityScreenState();
}

class _PsychologistAvailabilityScreenState extends State<PsychologistAvailabilityScreen> {
  final days = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
  final Set<int> selectedDays = {0,1,2,3,4};
  double startHour = 9; // 9am
  double endHour = 18;  // 6pm
  bool saving = false;

  String _format(double h) {
    final hour = h.round();
    final isPM = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h12.toString().padLeft(2, '0')}:00 ${isPM ? 'PM' : 'AM'}';
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => saving = true);
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'availability': {
        'days': selectedDays.toList(),
        'startHour': startHour.round(),
        'endHour': endHour.round(),
        'updatedAt': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disponibilidad guardada')));
  }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Disponibilidad',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Kantumruy Pro',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configura tus días y horarios',
                          style: TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Kantumruy Pro'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (int i = 0; i < days.length; i++)
                              ChoiceChip(
                                label: Text(days[i]),
                                selected: selectedDays.contains(i),
                                onSelected: (_) {
                                  setState(() {
                                    if (selectedDays.contains(i)) {
                                      selectedDays.remove(i);
                                    } else {
                                      selectedDays.add(i);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Desde'),
                        Slider(
                          min: 0,
                          max: 23,
                          divisions: 23,
                          value: startHour,
                          label: _format(startHour),
                          onChanged: (v) => setState(() => startHour = v.clamp(0, endHour)),
                        ),
                        Text(_format(startHour), style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Hasta'),
                        Slider(
                          min: 0,
                          max: 23,
                          divisions: 23,
                          value: endHour,
                          label: _format(endHour),
                          onChanged: (v) => setState(() => endHour = v.clamp(startHour, 23)),
                        ),
                        Text(_format(endHour), style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: saving ? null : _save,
                            child: Text(saving ? 'Guardando...' : 'Guardar'),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                  currentIconAsset: "assets/images/icon/disponi.svg",
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
                      iconAsset: "assets/images/icon/pacientes.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistPatientsScreen()),
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
