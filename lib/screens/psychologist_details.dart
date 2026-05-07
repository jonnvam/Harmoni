import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/services/appointment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // ====== HEADER SECTION ======
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BackButtonCircle(onTap: () => Navigator.pop(context)),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Perfil del psicólogo',
                            style: TextStyles.tituloBienvenida.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                // ====== MAIN PROFILE SECTION ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _ProfileHeaderCard(psychologist: p),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                // ====== DESCRIPTION GROUP ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 14),
                      _InfoSection(
                        title: 'Especialidades',
                        icon: Icons.psychology_rounded,
                        child: _ChipWrap(items: p.specialties),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                // ====== PROFESSIONAL DETAILS GROUP ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _InfoSection(
                        title: 'Modalidades de atención',
                        icon: Icons.video_call_rounded,
                        child: _ChipWrap(items: p.modalidades),
                      ),
                      const SizedBox(height: 14),
                      _InfoSection(
                        title: 'Enfoque terapéutico',
                        icon: Icons.lightbulb_rounded,
                        child: _ChipWrap(items: p.enfoquesTerapia),
                      ),
                      const SizedBox(height: 14),
                      _InfoSection(
                        title: 'Población que atiende',
                        icon: Icons.groups_rounded,
                        child: _ChipWrap(items: p.atiendeA),
                      ),
                      if (p.aniosExperiencia != null) ...[
                        const SizedBox(height: 14),
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
                      ],
                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                // ====== FEE HIGHLIGHT SECTION ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _FeeCard(psychologist: p),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
          // ====== Avatar Section ======
          CircleAvatar(
            radius: isMobile ? 48 : 52,
            backgroundColor: const Color(0xFFF2EEFF),
            backgroundImage: (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                ? NetworkImage(p.avatarUrl!)
                : (p.avatarAsset != null && p.avatarAsset!.isNotEmpty)
                    ? AssetImage(p.avatarAsset!) as ImageProvider
                    : null,
            child: (p.avatarUrl == null &&
                    (p.avatarAsset == null || p.avatarAsset!.isEmpty))
                ? Icon(
                    Icons.person_rounded,
                    size: isMobile ? 48 : 52,
                    color: AppColors.fondo3,
                  )
                : null,
          ),

          const SizedBox(height: 16),

          // ====== Name Section ======
          Text(
            p.name,
            textAlign: TextAlign.center,
            style: TextStyles.tituloBienvenida.copyWith(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 6),

          // ====== Specialties Section ======
          Text(
            p.specialties.isEmpty ? 'Psicología' : p.specialties.join(' • '),
            textAlign: TextAlign.center,
            style: TextStyles.textDicho.copyWith(
              fontSize: 14,
              color: Colors.black54,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // ====== Chips Section (Modalidades + Precio) ======
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...p.modalidades.map((m) => _TagChip(text: m)),
                _TagChip(
                  text: '\$${p.price} ${p.moneda}',
                  color: AppColors.fondo3,
                  bg: const Color(0xFFEEF2FF),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.fondo3.withValues(alpha: 0.08),
            AppColors.fondo3.withValues(alpha: 0.04),
          ],
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.fondo3.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.fondo3.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== Header ======
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.fondo3.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppColors.fondo3,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Honorarios por sesión',
                  style: TextStyles.textDicho.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ====== Price Display ======
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: TextStyles.tituloBienvenida.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fondo3,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    p.price.toString(),
                    style: TextStyles.tituloBienvenida.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.fondo3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                p.moneda,
                style: TextStyles.textDicho.copyWith(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
  bool _isLoading = false;

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con cierre
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reservando cita para',
                    style: TextStyles.textBlackLogin.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
            // Nombre del psicólogo
            Text(
              widget.psychologist.name,
              style: TextStyles.tituloBienvenida.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Día cards - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _DayCard(
                        title: 'Hoy',
                        subtitle: _dayAndMonth(DateTime.now()),
                        slots: 12,
                        selected: _selectedDay == 0,
                        onTap: () => setState(() => _selectedDay = 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DayCard(
                        title: 'Mañana',
                        subtitle: _dayAndMonth(
                          DateTime.now().add(const Duration(days: 1)),
                        ),
                        slots: 9,
                        selected: _selectedDay == 1,
                        onTap: () => setState(() => _selectedDay = 1),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            
            // Elige hora - Responsive
            Text(
              'Elige hora',
              style: TextStyles.textBlackLogin.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 60,
                  child: Text(
                    '8:00 AM',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                const SizedBox(
                  width: 60,
                  child: Text(
                    '8:00 PM',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatHour(_timeValue),
              style: TextStyles.textBlackLogin.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),
            
            // Método de pago
            Text(
              'Método de pago',
              style: TextStyles.textBlackLogin.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _payment,
              items: const [
                DropdownMenuItem(
                  value: 'Debit Card',
                  child: Text('Tarjeta de Débito'),
                ),
                DropdownMenuItem(
                  value: 'Credit Card',
                  child: Text('Tarjeta de Crédito'),
                ),
                DropdownMenuItem(
                  value: 'Cash',
                  child: Text('Efectivo'),
                ),
              ],
              onChanged: (v) => setState(() => _payment = v ?? 'Debit Card'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
            ),

            const SizedBox(height: 16),
            
            // Botón de confirmación
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.fondo3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesion para confirmar.'),
                            ),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        final now = DateTime.now();
                        final base = _selectedDay == 0
                            ? now
                            : now.add(const Duration(days: 1));
                        final hour = 8 + _timeValue.round();
                        final date = DateTime(
                          base.year,
                          base.month,
                          base.day,
                          hour,
                        );

                        try {
                          await AppointmentService.instance.createAppointment(
                            patientId: user.uid,
                            psychologistId: widget.psychologist.id,
                            fecha: date,
                          );

                          if (!mounted) return;

                          final formatted =
                              DateFormat('d MMMM yyyy, HH:mm', 'es_MX')
                                  .format(date);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '¡Cita confirmada! Te esperamos el $formatted',
                                      style: const TextStyle(
                                        fontFamily: 'Kantumruy Pro',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green.shade700,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                            ),
                          );

                          Navigator.pop(context, true);
                        } catch (e) {
                          if (!mounted) return;

                          setState(() => _isLoading = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Error al reservar: ${e.toString()}',
                                      style: const TextStyle(
                                        fontFamily: 'Kantumruy Pro',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'CONFIRMAR',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _dayAndMonth(DateTime d) {
    final formatter = DateFormat('d MMMM', 'es_ES');
    return formatter.format(d);
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
