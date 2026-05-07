import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/services/psychologist_availability_service.dart';

class PsychologistAvailabilityScreen extends StatefulWidget {
  const PsychologistAvailabilityScreen({super.key});

  @override
  State<PsychologistAvailabilityScreen> createState() =>
      _PsychologistAvailabilityScreenState();
}

class _PsychologistAvailabilityScreenState
    extends State<PsychologistAvailabilityScreen> {
  List<DayAvailability>? _availability;

  int _sessionDurationMinutes = 60;
  bool _initialized = false;
  bool _saving = false;

  static const Map<String, String> _modalidadLabels = {
    'online': 'En línea',
    'presencial': 'Presencial',
  };

  String _prettyTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final isPM = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }

  String _timeOfDayToStorage(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _storageToTimeOfDay(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  void _toggleDayActive(int index, bool active) {
    final current = _availability;
    if (current == null) return;

    final day = current[index];

    final defaultBlocks = day.bloques.isEmpty
        ? const [
            AvailabilityBlock(inicio: '09:00', fin: '13:00'),
          ]
        : day.bloques;

    final updated = day.copyWith(
      activo: active,
      bloques: active ? defaultBlocks : day.bloques,
    );

    setState(() {
      _availability = [
        ...current,
      ]..[index] = updated;
    });
  }

  void _toggleModalidad(int dayIndex, String modalidad) {
    final current = _availability;
    if (current == null) return;

    final day = current[dayIndex];
    final modalidades = [...day.modalidades];

    if (modalidades.contains(modalidad)) {
      modalidades.remove(modalidad);
    } else {
      modalidades.add(modalidad);
    }

    if (modalidades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una modalidad.'),
        ),
      );
      return;
    }

    setState(() {
      _availability = [
        ...current,
      ]..[dayIndex] = day.copyWith(modalidades: modalidades);
    });
  }

  Future<void> _openBlockSheet({
    required int dayIndex,
    int? blockIndex,
  }) async {
    final current = _availability;
    if (current == null) return;

    final day = current[dayIndex];

    final existing = blockIndex == null ? null : day.bloques[blockIndex];

    TimeOfDay start = existing == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : _storageToTimeOfDay(existing.inicio);

    TimeOfDay end = existing == null
        ? const TimeOfDay(hour: 13, minute: 0)
        : _storageToTimeOfDay(existing.fin);

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final startText = _timeOfDayToStorage(start);
            final endText = _timeOfDayToStorage(end);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blockIndex == null
                        ? 'Agregar bloque horario'
                        : 'Editar bloque horario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    day.diaNombre,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _TimePickCard(
                          label: 'Inicio',
                          value: _prettyTime(startText),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: start,
                            );

                            if (picked == null) return;

                            setModalState(() {
                              start = picked;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimePickCard(
                          label: 'Fin',
                          value: _prettyTime(endText),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: end,
                            );

                            if (picked == null) return;

                            setModalState(() {
                              end = picked;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.fondo3,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final inicio = _timeOfDayToStorage(start);
                        final fin = _timeOfDayToStorage(end);

                        if (_timeToMinutes(inicio) >= _timeToMinutes(fin)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La hora final debe ser mayor que la inicial.',
                              ),
                            ),
                          );
                          return;
                        }

                        final duration =
                            _timeToMinutes(fin) - _timeToMinutes(inicio);

                        if (duration < _sessionDurationMinutes) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El bloque debe cubrir al menos una sesión.',
                              ),
                            ),
                          );
                          return;
                        }

                        final newBlock = AvailabilityBlock(
                          inicio: inicio,
                          fin: fin,
                        );

                        final blocks = [...day.bloques];

                        if (blockIndex == null) {
                          blocks.add(newBlock);
                        } else {
                          blocks[blockIndex] = newBlock;
                        }

                        blocks.sort(
                          (a, b) => _timeToMinutes(a.inicio)
                              .compareTo(_timeToMinutes(b.inicio)),
                        );

                        setState(() {
                          _availability = [
                            ...current,
                          ]..[dayIndex] = day.copyWith(
                              activo: true,
                              bloques: blocks,
                            );
                        });

                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Guardar bloque',
                        style: TextStyle(
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteBlock({
    required int dayIndex,
    required int blockIndex,
  }) {
    final current = _availability;
    if (current == null) return;

    final day = current[dayIndex];
    final blocks = [...day.bloques]..removeAt(blockIndex);

    setState(() {
      _availability = [
        ...current,
      ]..[dayIndex] = day.copyWith(bloques: blocks);
    });
  }

  Future<void> _save() async {
  final availability = _availability;

  if (availability == null) return;

  setState(() => _saving = true);

  try {
    await PsychologistAvailabilityService.instance.saveAvailability(
      availability: availability,
      sessionDurationMinutes: _sessionDurationMinutes,
    );

    if (!mounted) return;

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
          duration: const Duration(seconds: 3),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Disponibilidad guardada correctamente.',
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

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 95),
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(
            'No se pudo guardar la disponibilidad: $e',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  } finally {
    if (mounted) {
      setState(() => _saving = false);
    }
  }
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
                    child: StreamBuilder<List<DayAvailability>>(
                      stream: PsychologistAvailabilityService.instance
                          .watchMyAvailability(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !_initialized) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No se pudo cargar la disponibilidad.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        if (!_initialized && snapshot.hasData) {
                          _availability = snapshot.data!;
                          _initialized = true;
                        }

                        final availability = _availability;

                        if (availability == null) {
                          return const Center(
                            child: Text('Sin disponibilidad cargada.'),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                'Configura los días, horarios y modalidad en que puedes atender.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontFamily: 'Kantumruy Pro',
                                ),
                              ),

                              const SizedBox(height: 18),

                              _DurationCard(
                                value: _sessionDurationMinutes,
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    _sessionDurationMinutes = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              for (int i = 0; i < availability.length; i++) ...[
                                _DayAvailabilityCard(
                                  day: availability[i],
                                  modalidadLabels: _modalidadLabels,
                                  prettyTime: _prettyTime,
                                  onToggleActive: (active) =>
                                      _toggleDayActive(i, active),
                                  onToggleModalidad: (modalidad) =>
                                      _toggleModalidad(i, modalidad),
                                  onAddBlock: () =>
                                      _openBlockSheet(dayIndex: i),
                                  onEditBlock: (blockIndex) =>
                                      _openBlockSheet(
                                    dayIndex: i,
                                    blockIndex: blockIndex,
                                  ),
                                  onDeleteBlock: (blockIndex) => _deleteBlock(
                                    dayIndex: i,
                                    blockIndex: blockIndex,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              const SizedBox(height: 8),

                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.fondo3,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _saving ? null : _save,
                                  child: Text(
                                    _saving
                                        ? 'Guardando...'
                                        : 'Guardar disponibilidad',
                                    style: const TextStyle(
                                      fontFamily: 'Kantumruy Pro',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                        MaterialPageRoute(
                          builder: (_) =>
                              const PsychologistAppointmentsScreen(),
                        ),
                      ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/house.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PsychologistHomeScreen(),
                        ),
                      ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/pacientes.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PsychologistPatientsScreen(),
                        ),
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

class _DurationCard extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;

  const _DurationCard({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_rounded,
            color: AppColors.fondo3,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Duración de sesión',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          DropdownButton<int>(
            value: value,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 30, child: Text('30 min')),
              DropdownMenuItem(value: 45, child: Text('45 min')),
              DropdownMenuItem(value: 50, child: Text('50 min')),
              DropdownMenuItem(value: 60, child: Text('60 min')),
              DropdownMenuItem(value: 90, child: Text('90 min')),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DayAvailabilityCard extends StatelessWidget {
  final DayAvailability day;
  final Map<String, String> modalidadLabels;
  final String Function(String value) prettyTime;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<String> onToggleModalidad;
  final VoidCallback onAddBlock;
  final ValueChanged<int> onEditBlock;
  final ValueChanged<int> onDeleteBlock;

  const _DayAvailabilityCard({
    required this.day,
    required this.modalidadLabels,
    required this.prettyTime,
    required this.onToggleActive,
    required this.onToggleModalidad,
    required this.onAddBlock,
    required this.onEditBlock,
    required this.onDeleteBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: day.activo ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: day.activo ? const Color(0xFFDCE4FF) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.diaNombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(
                value: day.activo,
                activeColor: AppColors.fondo3,
                onChanged: onToggleActive,
              ),
            ],
          ),

          if (day.activo) ...[
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: modalidadLabels.entries.map((entry) {
                  final selected = day.modalidades.contains(entry.key);

                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? AppColors.fondo3
                          : const Color(0xFFE2E8F0),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.fondo3 : Colors.black54,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (_) => onToggleModalidad(entry.key),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            if (day.bloques.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Aún no hay bloques horarios para este día.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < day.bloques.length; i++)
                    _BlockTile(
                      block: day.bloques[i],
                      prettyTime: prettyTime,
                      onEdit: () => onEditBlock(i),
                      onDelete: () => onDeleteBlock(i),
                    ),
                ],
              ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddBlock,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar bloque'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.fondo3,
                  side: const BorderSide(color: Color(0xFFDCE4FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  final AvailabilityBlock block;
  final String Function(String value) prettyTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BlockTile({
    required this.block,
    required this.prettyTime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE4FF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 18,
            color: AppColors.fondo3,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${prettyTime(block.inicio)} - ${prettyTime(block.fin)}',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w800,
                color: AppColors.fondo3,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 19),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontFamily: 'Kantumruy Pro',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}