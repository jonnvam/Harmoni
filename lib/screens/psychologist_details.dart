import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsychologistDetailsScreen extends StatelessWidget {
  final Psychologist psychologist;
  const PsychologistDetailsScreen({super.key, required this.psychologist});

  @override
Widget build(BuildContext context) {
  final p = psychologist;

  return Scaffold(
    backgroundColor: Colors.white,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openBookingSheet(context, p),
      backgroundColor: AppColors.fondo3,
      label: const Text(
        'Reservar',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'Kantumruy Pro',
        ),
      ),
      icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButtonCircle(onTap: () => Navigator.pop(context)),

            const SizedBox(height: 16),

            _ProfileHeaderCard(psychologist: p),

            const SizedBox(height: 18),

            _InfoSection(
              title: 'Descripción profesional',
              icon: Icons.description_rounded,
              child: Text(
                p.descripcionProfesional.trim().isEmpty
                    ? 'Este profesional aún no agregó una descripción.'
                    : p.descripcionProfesional,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.black87,
                  fontFamily: 'Kantumruy Pro',
                ),
              ),
            ),

            _InfoSection(
              title: 'Especialidades',
              icon: Icons.psychology_rounded,
              child: _ChipWrap(items: p.specialties),
            ),

            _InfoSection(
              title: 'Modalidades de atención',
              icon: Icons.video_call_rounded,
              child: _ChipWrap(items: p.modalidades),
            ),

            _InfoSection(
              title: 'Enfoque terapéutico',
              icon: Icons.lightbulb_rounded,
              child: _ChipWrap(items: p.enfoquesTerapia),
            ),

            _InfoSection(
              title: 'Población que atiende',
              icon: Icons.groups_rounded,
              child: _ChipWrap(items: p.atiendeA),
            ),

            if (p.aniosExperiencia != null)
              _InfoSection(
                title: 'Experiencia',
                icon: Icons.workspace_premium_rounded,
                child: Text(
                  p.aniosExperiencia == 1
                      ? '1 año de experiencia'
                      : '${p.aniosExperiencia} años de experiencia',
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Kantumruy Pro',
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            _FeeCard(psychologist: p),

            const SizedBox(height: 120),
          ],
        ),
      ),
    ),
  );
}

  void _openBookingSheet(BuildContext context, Psychologist p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BookingSheet(psychologist: p),
    );
  }
}

// Eliminado: _AvatarBlock ya no es necesario con el header card centrado.


class _TagChip extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? bg;
  const _TagChip({required this.text, this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
  border: Border.all(color: (color ?? const Color(0xFF6B7280)).withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color ?? const Color(0xFF374151), fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}


class _BackButtonCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButtonCircle({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final Psychologist psychologist;

  const _ProfileHeaderCard({
    required this.psychologist,
  });

  @override
  Widget build(BuildContext context) {
    final p = psychologist;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFF2EEFF),
            backgroundImage: (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                ? NetworkImage(p.avatarUrl!)
                : (p.avatarAsset != null && p.avatarAsset!.isNotEmpty)
                    ? AssetImage(p.avatarAsset!) as ImageProvider
                    : null,
            child: (p.avatarUrl == null &&
                    (p.avatarAsset == null || p.avatarAsset!.isEmpty))
                ? const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppColors.fondo3,
                  )
                : null,
          ),

          const SizedBox(height: 14),

          Text(
            p.name,
            textAlign: TextAlign.center,
            style: TextStyles.tituloBienvenida.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            p.specialties.isEmpty ? 'Psicología' : p.specialties.join(' • '),
            textAlign: TextAlign.center,
            style: TextStyles.textDicho.copyWith(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ...p.modalidades.map((m) => _TagChip(text: m)),
              _TagChip(
                text: '\$${p.price} ${p.moneda} / sesión',
                color: AppColors.fondo3,
                bg: const Color(0xFFEEF2FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.fondo3, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final List<String> items;

  const _ChipWrap({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'No especificado',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Kantumruy Pro',
          color: Colors.black54,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFDCE4FF)),
          ),
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
              color: AppColors.fondo3,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final Psychologist psychologist;

  const _FeeCard({
    required this.psychologist,
  });

  @override
  Widget build(BuildContext context) {
    final p = psychologist;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_rounded,
            color: AppColors.fondo3,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Honorarios por sesión',
              style: TextStyles.textDicho.copyWith(fontSize: 14),
            ),
          ),
          Text(
            '\$${p.price} ${p.moneda}',
            style: TextStyles.tituloBienvenida.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSheet extends StatefulWidget {
  final Psychologist psychologist;
  const BookingSheet({super.key, required this.psychologist});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  int _selectedDay = 0; // 0 = hoy, 1 = mañana
  double _timeValue = 10; // hora base 8..20 → 10 ~ 10am
  String _payment = 'Debit Card';

  String _formatHour(double v) {
    final hour = 8 + v.round();
    final isPM = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h12.toString().padLeft(2, '0')}:00 ${isPM ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Reservando cita para', style: TextStyles.textBlackLogin.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(widget.psychologist.name, style: TextStyles.tituloBienvenida.copyWith(fontSize: 22, fontWeight: FontWeight.w900)),

          const SizedBox(height: 16),

          // Día cards
          Row(
            children: [
              _DayCard(
                title: 'Hoy',
                subtitle: _dayAndMonth(DateTime.now()),
                slots: 12,
                selected: _selectedDay == 0,
                onTap: () => setState(() => _selectedDay = 0),
              ),
              const SizedBox(width: 12),
              _DayCard(
                title: 'Mañana',
                subtitle: _dayAndMonth(DateTime.now().add(const Duration(days: 1))),
                slots: 9,
                selected: _selectedDay == 1,
                onTap: () => setState(() => _selectedDay = 1),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text('Elige hora', style: TextStyles.textBlackLogin.copyWith(fontWeight: FontWeight.w700)),
          Row(
            children: [
              const Text('8:00 AM'),
              Expanded(
                child: Slider(
                  min: 0,
                  max: 12,
                  divisions: 12,
                  value: _timeValue,
                  activeColor: AppColors.fondo3,
                  onChanged: (v) => setState(() => _timeValue = v),
                ),
              ),
              const Text('8:00 PM'),
            ],
          ),
          Text(_formatHour(_timeValue), style: TextStyles.textBlackLogin.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),

          const SizedBox(height: 16),
          Text('Método de pago', style: TextStyles.textBlackLogin.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _payment,
            items: const [
              DropdownMenuItem(value: 'Debit Card', child: Text('Tarjeta de Débito')),
              DropdownMenuItem(value: 'Credit Card', child: Text('Tarjeta de Crédito')),
              DropdownMenuItem(value: 'Cash', child: Text('Efectivo')),
            ],
            onChanged: (v) => setState(() => _payment = v ?? 'Debit Card'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.fondo3,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                // Persistir la cita básica para conectar con panel del psicólogo
                final user = FirebaseAuth.instance.currentUser;
                final now = DateTime.now();
                final base = _selectedDay == 0 ? now : now.add(const Duration(days: 1));
                final hour = 8 + _timeValue.round();
                final date = DateTime(base.year, base.month, base.day, hour);
                await FirebaseFirestore.instance.collection('appointments').add({
                  'psychId': widget.psychologist.id,
                  'psychName': widget.psychologist.name,
                  'patientId': user?.uid,
                  'patientName': user?.displayName ?? 'Paciente',
                  'dateTime': Timestamp.fromDate(date),
                  'status': 'pendiente',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reserva confirmada')),
                );
              },
              child: const Text('CONFIRMAR', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _dayAndMonth(DateTime d) {
    const months = [
      'January','February','March','April','May','June','July','August','September','October','November','December'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _DayCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int slots;
  final bool selected;
  final VoidCallback onTap;
  const _DayCard({required this.title, required this.subtitle, required this.slots, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB);
    final bg = selected ? const Color(0xFFEFF6FF) : Colors.white;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? const Color(0xFF111827) : Colors.black87)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text('$slots Espacios disponibles', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
