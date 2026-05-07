import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:shimmer/shimmer.dart';

class PsychologistAppointmentsScreen extends StatefulWidget {
  const PsychologistAppointmentsScreen({super.key});

  @override
  State<PsychologistAppointmentsScreen> createState() => _PsychologistAppointmentsScreenState();
}

class _PsychologistAppointmentsScreenState extends State<PsychologistAppointmentsScreen> {
  String _filter = 'hoy';

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
                        Wrap(
                          spacing: 8,
                          children: [
                            _FilterChip(
                              label: 'Hoy',
                              selected: _filter == 'hoy',
                              onSelected: () => setState(() => _filter = 'hoy'),
                            ),
                            _FilterChip(
                              label: 'Pendientes',
                              selected: _filter == 'pendiente',
                              onSelected: () => setState(() => _filter = 'pendiente'),
                            ),
                            _FilterChip(
                              label: 'Confirmadas',
                              selected: _filter == 'confirmada',
                              onSelected: () => setState(() => _filter = 'confirmada'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: uid == null
                              ? const Center(child: Text('Inicia sesión para ver tus citas'))
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('citas')
                                      .where('psicologoId', isEqualTo: uid)
                                      .orderBy('fecha')
                                      .snapshots(),
                                  builder: (context, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return const _AppointmentsSkeleton();
                                    }
                                    if (snap.hasError) {
                                      return _AppointmentsStateMessage(
                                        icon: Icons.error_outline,
                                        title: 'No se pudieron cargar tus citas',
                                        message: 'Intenta nuevamente en unos segundos.',
                                        actionText: 'Reintentar',
                                        onAction: () => setState(() {}),
                                      );
                                    }
                                    final docs = snap.data?.docs ?? [];
                                    if (docs.isEmpty) {
                                      return _AppointmentsStateMessage(
                                        icon: Icons.event_busy,
                                        title: 'Aún no tienes citas',
                                        message: 'Cuando un paciente reserve, aparecerá aquí.',
                                        actionText: 'Actualizar',
                                        onAction: () => setState(() {}),
                                      );
                                    }
                                    final now = DateTime.now();
                                    final startOfDay = DateTime(now.year, now.month, now.day);
                                    final endOfDay = startOfDay.add(const Duration(days: 1));

                                    final filtered = docs.where((doc) {
                                      final d = doc.data() as Map<String, dynamic>? ?? {};
                                      final status = (d['estado'] ?? 'pendiente').toString();
                                      final date = (d['fecha'] as Timestamp?)?.toDate();
                                      if (_filter == 'pendiente') return status == 'pendiente';
                                      if (_filter == 'confirmada') return status == 'confirmada';
                                      if (date == null) return false;
                                      return date.isAfter(startOfDay) && date.isBefore(endOfDay);
                                    }).toList();

                                    if (filtered.isEmpty) {
                                      return _AppointmentsStateMessage(
                                        icon: Icons.event_note,
                                        title: 'Sin citas para este filtro',
                                        message: 'Prueba con otro filtro para ver mas resultados.',
                                        actionText: 'Ver todo',
                                        onAction: () => setState(() => _filter = 'hoy'),
                                      );
                                    }

                                    return ListView.separated(
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final d = filtered[i].data() as Map<String, dynamic>? ?? {};
                                        final patientName = (d['patientName'] ?? 'Paciente').toString();
                                        final date = (d['fecha'] as Timestamp?)?.toDate();
                                        final status = (d['estado'] ?? 'pendiente').toString();
                                        final patientId = (d['pacienteId'] ?? '').toString();
                                        return _AppointmentTile(
                                          title: patientName,
                                          date: date,
                                          status: status,
                                          docRef: filtered[i].reference,
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _reprogram(context, ctx),
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Reprogramar'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await docRef.update({'estado': 'confirmada'});
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
                        await docRef.update({'estado': 'cancelada'});
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

  Future<void> _reprogram(BuildContext context, BuildContext sheetContext) async {
    final initialDate = date ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (pickedTime == null) return;

    final newDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    await docRef.update({'dateTime': Timestamp.fromDate(newDate)});
    if (!sheetContext.mounted) return;
    Navigator.pop(sheetContext);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita reprogramada')));
  }
}

class _AppointmentsSkeleton extends StatelessWidget {
  const _AppointmentsSkeleton();

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
            height: 74,
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

class _AppointmentsStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onAction;

  const _AppointmentsStateMessage({
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.fondo3,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.borde3 : const Color(0xFFE5E7EB)),
    );
  }
}
