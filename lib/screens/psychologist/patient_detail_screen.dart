import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/text_styles.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({super.key, required this.patientId, required this.patientName});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del paciente'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(patientName, style: TextStyles.textEditar.copyWith(fontSize: 24)),
              const SizedBox(height: 6),
              Text('Historial de citas', style: TextStyles.textDicho.copyWith(color: Colors.black54)),
              const SizedBox(height: 12),
              if (uid == null)
                const Center(child: Text('Inicia sesión para ver el historial'))
              else
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('psychId', isEqualTo: uid)
                        .where('patientId', isEqualTo: patientId)
                        .orderBy('dateTime', descending: true)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('Sin historial aún'));
                      }

                      final lastConfirmed = docs
                          .map((d) => d.data() as Map<String, dynamic>? ?? {})
                          .where((d) => (d['status'] ?? '').toString() == 'confirmada')
                          .map((d) => d['dateTime'])
                          .whereType<Timestamp>()
                          .map((t) => t.toDate())
                          .fold<DateTime?>(null, (prev, cur) => prev == null || cur.isAfter(prev) ? cur : prev);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoCard(
                            title: 'Última sesión',
                            value: lastConfirmed == null
                                ? 'Sin sesiones confirmadas'
                                : _formatDateTime(lastConfirmed),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final data = docs[i].data() as Map<String, dynamic>? ?? {};
                                final date = (data['dateTime'] as Timestamp?)?.toDate();
                                final status = (data['status'] ?? 'pendiente').toString();
                                return _AppointmentRow(
                                  date: date,
                                  status: status,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month ${dt.year} · $hour:$minute';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.textDicho.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: TextStyles.textBlackLogin.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final DateTime? date;
  final String status;

  const _AppointmentRow({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final dateStr = date == null
        ? 'Sin fecha'
        : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')} ${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}';
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
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
        subtitle: Text('Estado: $status', style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Kantumruy Pro')),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Kantumruy Pro')),
        ),
      ),
    );
  }
}
