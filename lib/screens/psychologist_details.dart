import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/services/appointments_service.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
        border: Border.all(
          color: (color ?? const Color(0xFF6B7280)).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? const Color(0xFF374151),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BackButtonCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButtonCircle({required this.onTap});

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

  const _ProfileHeaderCard({required this.psychologist});

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
            backgroundImage:
                (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                    ? NetworkImage(p.avatarUrl!)
                    : (p.avatarAsset != null && p.avatarAsset!.isNotEmpty)
                    ? AssetImage(p.avatarAsset!) as ImageProvider
                    : null,
            child:
                (p.avatarUrl == null &&
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

  const _ChipWrap({required this.items});

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
      children:
          items.map((item) {
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

  const _FeeCard({required this.psychologist});

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
          const Icon(Icons.payments_rounded, color: AppColors.fondo3, size: 26),
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
  final _motivoCtrl = TextEditingController();

  List<AppointmentSlot> _slots = [];
  AppointmentSlot? _selectedSlot;
  String? _selectedModalidad;
  String _selectedPaymentMethod = 'transferencia';

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'efectivo':
        return 'Efectivo';
      case 'transferencia':
        return 'Transferencia';
      case 'pago_digital':
        return 'Pago digital';
      default:
        return method;
    }
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final slots = await AppointmentsService.instance.loadAvailableSlots(
        psychologistUid: widget.psychologist.id,
      );

      if (!mounted) return;

      setState(() {
        _slots = slots;
        _selectedSlot = slots.isNotEmpty ? slots.first : null;
        _selectedModalidad =
            slots.isNotEmpty && slots.first.modalidades.isNotEmpty
                ? slots.first.modalidades.first
                : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _dayLabel(DateTime date) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  String _hourLabel(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final isPM = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }

  String _modalidadLabel(String modalidad) {
    switch (modalidad) {
      case 'online':
        return 'En línea';
      case 'presencial':
        return 'Presencial';
      default:
        return modalidad;
    }
  }

  Map<String, List<AppointmentSlot>> _groupSlotsByDay() {
    final grouped = <String, List<AppointmentSlot>>{};

    for (final slot in _slots) {
      final key =
          DateTime(
            slot.inicio.year,
            slot.inicio.month,
            slot.inicio.day,
          ).toIso8601String();

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(slot);
    }

    return grouped;
  }

  Future<void> _requestAppointment() async {
    final slot = _selectedSlot;
    final modalidad = _selectedModalidad;
    final motivo = _motivoCtrl.text.trim();

    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un horario disponible.')),
      );
      return;
    }

    if (modalidad == null || modalidad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una modalidad.')),
      );
      return;
    }

    if (motivo.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un motivo de consulta un poco más claro.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await AppointmentsService.instance.requestAppointment(
        psychologistUid: widget.psychologist.id,
        psychologistName: widget.psychologist.name,
        slot: slot,
        modalidad: modalidad,
        motivoConsulta: motivo,
        precio: widget.psychologist.price,
        moneda: widget.psychologist.moneda,
        metodoPago: _selectedPaymentMethod,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 95),
            backgroundColor: AppColors.fondo3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Solicitud de cita enviada.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo solicitar la cita. Es posible que ese horario ya haya sido tomado.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupSlotsByDay();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reservar cita',
                      style: TextStyles.tituloBienvenida.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                widget.psychologist.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Kantumruy Pro',
                ),
              ),

              const SizedBox(height: 18),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _BookingEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'No se pudo cargar la disponibilidad',
                  message: 'Intenta nuevamente en unos momentos.',
                  actionText: 'Reintentar',
                  onAction: _loadSlots,
                )
              else if (_slots.isEmpty)
                const _BookingEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'Sin horarios disponibles',
                  message:
                      'Este psicólogo aún no tiene horarios disponibles para los próximos días.',
                )
              else ...[
                const _BookingSectionTitle(
                  icon: Icons.schedule_rounded,
                  title: 'Selecciona un horario',
                ),

                const SizedBox(height: 10),

                ...grouped.entries.map((entry) {
                  final slots = entry.value;
                  final day = slots.first.inicio;

                  return _DaySlotsGroup(
                    dayLabel: _dayLabel(day),
                    slots: slots,
                    selectedSlot: _selectedSlot,
                    hourLabel: _hourLabel,
                    onSelect: (slot) {
                      setState(() {
                        _selectedSlot = slot;
                        _selectedModalidad =
                            slot.modalidades.isNotEmpty
                                ? slot.modalidades.first
                                : null;
                      });
                    },
                  );
                }),

                const SizedBox(height: 16),

                const _BookingSectionTitle(
                  icon: Icons.video_call_rounded,
                  title: 'Modalidad',
                ),

                const SizedBox(height: 10),

                if (_selectedSlot != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _selectedSlot!.modalidades.map((modalidad) {
                          final selected = modalidad == _selectedModalidad;

                          return ChoiceChip(
                            label: Text(_modalidadLabel(modalidad)),
                            selected: selected,
                            selectedColor: const Color(0xFFEEF2FF),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color:
                                  selected
                                      ? AppColors.fondo3
                                      : const Color(0xFFE2E8F0),
                            ),
                            labelStyle: TextStyle(
                              color:
                                  selected ? AppColors.fondo3 : Colors.black54,
                              fontFamily: 'Kantumruy Pro',
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w500,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _selectedModalidad = modalidad;
                              });
                            },
                          );
                        }).toList(),
                  ),

                const SizedBox(height: 16),

                const _BookingSectionTitle(
                  icon: Icons.edit_note_rounded,
                  title: 'Motivo de consulta',
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _motivoCtrl,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText:
                        'Describe brevemente el motivo por el que deseas agendar.',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppColors.fondo3),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const _BookingSectionTitle(
                  icon: Icons.payments_rounded,
                  title: 'Método de pago',
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ['transferencia', 'efectivo', 'pago_digital'].map((
                        method,
                      ) {
                        final selected = method == _selectedPaymentMethod;

                        return ChoiceChip(
                          label: Text(_paymentMethodLabel(method)),
                          selected: selected,
                          selectedColor: const Color(0xFFEEF2FF),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                selected
                                    ? AppColors.fondo3
                                    : const Color(0xFFE2E8F0),
                          ),
                          labelStyle: TextStyle(
                            color: selected ? AppColors.fondo3 : Colors.black54,
                            fontFamily: 'Kantumruy Pro',
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                        );
                      }).toList(),
                ),

                const SizedBox(height: 8),

                const Text(
                  'El pago se acordará o confirmará después de que el psicólogo acepte la cita. No ingreses datos bancarios dentro de la app.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.fondo3,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _saving ? null : _requestAppointment,
                    child: Text(
                      _saving ? 'Enviando...' : 'Enviar solicitud',
                      style: const TextStyle(
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BookingSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BookingSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _DaySlotsGroup extends StatelessWidget {
  final String dayLabel;
  final List<AppointmentSlot> slots;
  final AppointmentSlot? selectedSlot;
  final String Function(DateTime date) hourLabel;
  final ValueChanged<AppointmentSlot> onSelect;

  const _DaySlotsGroup({
    required this.dayLabel,
    required this.slots,
    required this.selectedSlot,
    required this.hourLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                slots.map((slot) {
                  final selected =
                      selectedSlot?.inicio == slot.inicio &&
                      selectedSlot?.fin == slot.fin;

                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onSelect(slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              selected
                                  ? AppColors.fondo3
                                  : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        '${hourLabel(slot.inicio)} - ${hourLabel(slot.fin)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w800,
                          color: selected ? AppColors.fondo3 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BookingEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const _BookingEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.black38),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontFamily: 'Kantumruy Pro',
              color: Colors.black54,
            ),
          ),

          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}
