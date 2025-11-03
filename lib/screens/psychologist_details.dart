import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';

class PsychologistDetailsScreen extends StatelessWidget {
  final Psychologist psychologist;
  const PsychologistDetailsScreen({super.key, required this.psychologist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBookingSheet(context, psychologist),
        backgroundColor: AppColors.fondo3,
        label: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // back button con margen superior cómodo
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header card moderno
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar grande
                    Builder(builder: (_) {
                      if (psychologist.avatarUrl != null && psychologist.avatarUrl!.isNotEmpty) {
                        return CircleAvatar(radius: 48, backgroundImage: NetworkImage(psychologist.avatarUrl!));
                      }
                      if (psychologist.avatarAsset != null && psychologist.avatarAsset!.isNotEmpty) {
                        return CircleAvatar(radius: 48, backgroundImage: AssetImage(psychologist.avatarAsset!));
                      }
                      return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48));
                    }),
                    const SizedBox(height: 12),
                    Text(
                      psychologist.name,
                      textAlign: TextAlign.center,
                      style: TextStyles.tituloBienvenida.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      psychologist.specialties.join(' • '),
                      textAlign: TextAlign.center,
                      style: TextStyles.textDicho.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    // Estrellas + reseñas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StarRow(rating: psychologist.rating),
                        const SizedBox(width: 8),
                        Text('${psychologist.rating.toStringAsFixed(1)} (2,100 reseñas)', style: TextStyles.textDicho.copyWith(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _TagChip(text: 'Online'),
                        if (psychologist.isAvailable) _TagChip(text: 'Disponible Hoy', color: Colors.green.shade600, bg: Colors.green.shade50),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text('Acerca de', style: TextStyles.tituloBienvenida.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Profesional con experiencia en ${psychologist.specialties.isNotEmpty ? psychologist.specialties.first.toLowerCase() : 'salud mental'}. Enfoque empático y basado en evidencia para acompañarte en tus objetivos.',
                style: const TextStyle(fontSize: 15, height: 1.35),
              ),

              const SizedBox(height: 24),

            // Fees block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Honorarios por sesión', style: TextStyles.textDicho.copyWith(fontSize: 14)),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Text(
                    '\$${psychologist.price}',
                    style: TextStyles.tituloBienvenida.copyWith(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Servicios', style: TextStyles.tituloBienvenida.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...psychologist.specialties.map((s) => _BulletTile(text: s)).toList(),

            const SizedBox(height: 120), // espacio para el FAB
          ],
        ),
      ),
    ));
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

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star, color: Colors.amber, size: 18);
        if (i == full && half) return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }
}

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

class _BulletTile extends StatelessWidget {
  final String text;
  const _BulletTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
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
              onPressed: () {
                // Aquí iría la lógica real de reserva/pago
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
