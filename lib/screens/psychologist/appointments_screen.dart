import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/services/psychologist_appointments_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_application_1/components/appointment_access_card.dart';

class PsychologistAppointmentsScreen extends StatefulWidget {
  const PsychologistAppointmentsScreen({super.key});

  @override
  State<PsychologistAppointmentsScreen> createState() =>
      _PsychologistAppointmentsScreenState();
}

class _PsychologistAppointmentsScreenState
    extends State<PsychologistAppointmentsScreen> {
  String _filter = 'todas';

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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            'Gestiona las solicitudes de tus pacientes.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Kantumruy Pro',
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: 'Todas',
                                selected: _filter == 'todas',
                                onSelected:
                                    () => setState(() => _filter = 'todas'),
                              ),
                              _FilterChip(
                                label: 'Pendientes',
                                selected: _filter == 'solicitada',
                                onSelected:
                                    () =>
                                        setState(() => _filter = 'solicitada'),
                              ),
                              _FilterChip(
                                label: 'Confirmadas',
                                selected: _filter == 'confirmada',
                                onSelected:
                                    () =>
                                        setState(() => _filter = 'confirmada'),
                              ),
                              _FilterChip(
                                label: 'Historial',
                                selected: _filter == 'historial',
                                onSelected:
                                    () => setState(() => _filter = 'historial'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: StreamBuilder<
                              List<PsychologistAppointmentModel>
                            >(
                              stream:
                                  PsychologistAppointmentsService.instance
                                      .watchMyAppointments(),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const _AppointmentsSkeleton();
                                }

                                if (snap.hasError) {
                                  return _EmptyAppointmentsState(
                                    icon: Icons.error_outline_rounded,
                                    title: 'No se pudieron cargar tus citas',
                                    message:
                                        'Revisa tu conexión o intenta nuevamente.',
                                  );
                                }

                                final citas = snap.data ?? [];

                                if (citas.isEmpty) {
                                  return const _EmptyAppointmentsState(
                                    icon: Icons.event_available_rounded,
                                    title: 'Aún no tienes citas',
                                    message:
                                        'Cuando un paciente solicite una cita, aparecerá aquí.',
                                  );
                                }

                                final solicitadas =
                                    citas
                                        .where((c) => c.estado == 'solicitada')
                                        .toList();

                                final confirmadas =
                                    citas
                                        .where((c) => c.estado == 'confirmada')
                                        .toList();

                                final otras =
                                    citas
                                        .where(
                                          (c) =>
                                              c.estado != 'solicitada' &&
                                              c.estado != 'confirmada',
                                        )
                                        .toList();

                                List<Widget> buildSection({
                                  required String title,
                                  required List<PsychologistAppointmentModel>
                                  items,
                                }) {
                                  if (items.isEmpty) return [];

                                  return [
                                    _SectionLabel(text: title),
                                    const SizedBox(height: 8),
                                    ...items.map(
                                      (cita) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _AppointmentTile(
                                          appointment: cita,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ];
                                }

                                if (_filter == 'solicitada' &&
                                    solicitadas.isEmpty) {
                                  return _AppointmentsStateMessage(
                                    icon: Icons.event_note_rounded,
                                    title: 'Sin solicitudes pendientes',
                                    message:
                                        'Cuando un paciente solicite una cita, aparecerá aquí.',
                                    actionText: 'Ver todas',
                                    onAction:
                                        () => setState(() => _filter = 'todas'),
                                  );
                                }

                                if (_filter == 'confirmada' &&
                                    confirmadas.isEmpty) {
                                  return _AppointmentsStateMessage(
                                    icon: Icons.event_available_rounded,
                                    title: 'Sin citas confirmadas',
                                    message:
                                        'Cuando aceptes una cita, aparecerá en esta sección.',
                                    actionText: 'Ver todas',
                                    onAction:
                                        () => setState(() => _filter = 'todas'),
                                  );
                                }

                                if (_filter == 'historial' && otras.isEmpty) {
                                  return _AppointmentsStateMessage(
                                    icon: Icons.history_rounded,
                                    title: 'Sin historial',
                                    message:
                                        'Las citas rechazadas o canceladas aparecerán aquí.',
                                    actionText: 'Ver todas',
                                    onAction:
                                        () => setState(() => _filter = 'todas'),
                                  );
                                }

                                return ListView(
                                  children: [
                                    if (_filter == 'todas' ||
                                        _filter == 'solicitada')
                                      ...buildSection(
                                        title: 'Solicitudes pendientes',
                                        items: solicitadas,
                                      ),

                                    if (_filter == 'todas' ||
                                        _filter == 'confirmada')
                                      ...buildSection(
                                        title: 'Citas confirmadas',
                                        items: confirmadas,
                                      ),

                                    if (_filter == 'todas' ||
                                        _filter == 'historial')
                                      ...buildSection(
                                        title: 'Historial',
                                        items: otras,
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
                ),
              ],
            ),

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
                      onTap:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const PsychologistPatientsScreen(),
                            ),
                          ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/house.svg",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PsychologistHomeScreen(),
                            ),
                          ),
                    ),
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/disponi.svg",
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const PsychologistAvailabilityScreen(),
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

class _AppointmentTile extends StatelessWidget {
  final PsychologistAppointmentModel appointment;

  const _AppointmentTile({required this.appointment});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatHour(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final isPM = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '${h12.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} '
        '${isPM ? 'PM' : 'AM'}';
  }

  String _modalidadLabel(String value) {
    switch (value) {
      case 'online':
        return 'En línea';
      case 'presencial':
        return 'Presencial';
      default:
        return value;
    }
  }

  String _paymentLabel(String value) {
    switch (value) {
      case 'efectivo':
        return 'Efectivo';
      case 'transferencia':
        return 'Transferencia';
      case 'pago_digital':
        return 'Pago digital';
      default:
        return value;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmada':
        return const Color(0xFF22C55E);
      case 'rechazada':
      case 'cancelada':
      case 'cancelada_por_psicologo':
      case 'cancelada_por_paciente':
        return const Color(0xFFEF4444);
      case 'completada':
        return const Color(0xFF0EA5E9);
      case 'no_asistio':
        return const Color(0xFFF97316);
      case 'solicitada':
      default:
        return AppColors.fondo3;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'confirmada':
        return 'Confirmada';
      case 'rechazada':
        return 'Rechazada';
      case 'cancelada':
        return 'Cancelada';
      case 'cancelada_por_psicologo':
        return 'Cancelada por psicólogo';
      case 'cancelada_por_paciente':
        return 'Cancelada por paciente';
      case 'completada':
        return 'Completada';
      case 'no_asistio':
        return 'No asistió';
      case 'solicitada':
      default:
        return 'Solicitada';
    }
  }

  Future<String?> _askMeetUrl(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://meet.google.com/...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.fondo3,
              ),
              onPressed: () {
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  height: 1.35,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.fondo3,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    confirmText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<String?> _askCancelReason(BuildContext context) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Cancelar cita',
            style: TextStyle(
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Motivo de cancelación opcional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Volver'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text(
                'Cancelar cita',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appointment.estado);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetails(context),
      child: Ink(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.fondo3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatDate(appointment.fechaInicio)} · '
                        '${_formatHour(appointment.fechaInicio)}',
                        style: const TextStyle(
                          fontFamily: 'Kantumruy Pro',
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  text: _statusText(appointment.estado),
                  color: statusColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniInfoChip(
                  icon: Icons.video_call_rounded,
                  text: _modalidadLabel(appointment.modalidad),
                ),
                _MiniInfoChip(
                  icon: Icons.payments_rounded,
                  text: _paymentLabel(appointment.metodoPago),
                ),
                _MiniInfoChip(
                  icon: Icons.attach_money_rounded,
                  text: '\$${appointment.precio} ${appointment.moneda}',
                ),
              ],
            ),

            if (appointment.estado == 'confirmada') ...[
              const SizedBox(height: 12),
              AppointmentAccessCard(
                modalidad: appointment.modalidad,
                estado: appointment.estado,
                meetUrl: appointment.meetUrl,
                ubicacion: '',
              ),
              const SizedBox(height: 12),
              _ConfirmedAppointmentActions(
                isOnline: appointment.modalidad == 'online',
                onEditMeet: () => _editMeetUrl(context),
                onComplete: () => _complete(context),
                onNoShow: () => _markNoShow(context),
                onCancel: () => _cancel(context),
              ),
            ],

            if (appointment.estado == 'solicitada') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reject(context),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _confirm(context),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Aceptar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.fondo3,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    String? meetUrl;

    if (appointment.modalidad == 'online') {
      meetUrl = await _askMeetUrl(
        context,
        title: 'Enlace de videollamada',
        initialValue: appointment.meetUrl,
      );

      if (meetUrl == null) return;

      if (meetUrl.trim().isEmpty) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agrega el enlace de la videollamada.'),
          ),
        );
        return;
      }
    }

    try {
      await PsychologistAppointmentsService.instance.confirmAppointment(
        appointment: appointment,
        meetUrl: meetUrl,
      );

      if (!context.mounted) return;

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
            content: const Text(
              'Cita confirmada. Se creó el vínculo con el paciente.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo confirmar la cita: $e')),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    try {
      await PsychologistAppointmentsService.instance.rejectAppointment(
        appointment: appointment,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita rechazada.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo rechazar la cita: $e')),
      );
    }
  }

  Future<void> _editMeetUrl(BuildContext context) async {
    final meetUrl = await _askMeetUrl(
      context,
      title: 'Editar enlace de videollamada',
      initialValue: appointment.meetUrl,
    );

    if (meetUrl == null) return;

    if (meetUrl.trim().isEmpty) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace no puede estar vacío.')),
      );
      return;
    }

    try {
      await PsychologistAppointmentsService.instance.updateMeetUrl(
        appointment: appointment,
        meetUrl: meetUrl,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace actualizado.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el enlace: $e')),
      );
    }
  }

  Future<void> _complete(BuildContext context) async {
    final confirm = await _confirmAction(
      context,
      title: 'Completar cita',
      message: '¿Deseas marcar esta cita como completada?',
      confirmText: 'Completar',
    );

    if (!confirm) return;

    try {
      await PsychologistAppointmentsService.instance.completeAppointment(
        appointment: appointment,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita marcada como completada.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la cita: $e')),
      );
    }
  }

  Future<void> _markNoShow(BuildContext context) async {
    final confirm = await _confirmAction(
      context,
      title: 'Marcar como no asistió',
      message: '¿Deseas marcar que el paciente no asistió a esta cita?',
      confirmText: 'Marcar',
    );

    if (!confirm) return;

    try {
      await PsychologistAppointmentsService.instance.markNoShow(
        appointment: appointment,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita marcada como no asistió.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la cita: $e')),
      );
    }
  }

  Future<void> _cancel(BuildContext context) async {
    final reason = await _askCancelReason(context);

    if (reason == null) return;

    try {
      await PsychologistAppointmentsService.instance.cancelAppointment(
        appointment: appointment,
        reason: reason,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar la cita: $e')),
      );
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Detalle de cita',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 14),

                _DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Paciente',
                  value: appointment.patientName,
                ),

                _DetailRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'Fecha',
                  value: _formatDate(appointment.fechaInicio),
                ),

                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Horario',
                  value:
                      '${_formatHour(appointment.fechaInicio)} - ${_formatHour(appointment.fechaFin)}',
                ),

                _DetailRow(
                  icon: Icons.video_call_rounded,
                  label: 'Modalidad',
                  value: _modalidadLabel(appointment.modalidad),
                ),

                const SizedBox(height: 10),

                AppointmentAccessCard(
                  modalidad: appointment.modalidad,
                  estado: appointment.estado,
                  meetUrl: appointment.meetUrl,
                  ubicacion: '',
                ),

                const SizedBox(height: 10),

                _DetailRow(
                  icon: Icons.payments_rounded,
                  label: 'Pago',
                  value:
                      '${_paymentLabel(appointment.metodoPago)} · ${appointment.pagoEstado}',
                ),

                const SizedBox(height: 12),

                const Text(
                  'Motivo de consulta',
                  style: TextStyle(
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    appointment.motivoConsulta.isEmpty
                        ? 'Sin motivo especificado.'
                        : appointment.motivoConsulta,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      height: 1.35,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                if (appointment.estado == 'solicitada')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _reject(context);
                          },
                          child: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.fondo3,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirm(context);
                          },
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (appointment.estado == 'confirmada') ...[
                  const SizedBox(height: 16),
                  _ConfirmedAppointmentActions(
                    isOnline: appointment.modalidad == 'online',
                    onEditMeet: () {
                      Navigator.pop(ctx);
                      _editMeetUrl(context);
                    },
                    onComplete: () {
                      Navigator.pop(ctx);
                      _complete(context);
                    },
                    onNoShow: () {
                      Navigator.pop(ctx);
                      _markNoShow(context);
                    },
                    onCancel: () {
                      Navigator.pop(ctx);
                      _cancel(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmedAppointmentActions extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onEditMeet;
  final VoidCallback onComplete;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  const _ConfirmedAppointmentActions({
    required this.isOnline,
    required this.onEditMeet,
    required this.onComplete,
    required this.onNoShow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isOnline)
          OutlinedButton.icon(
            onPressed: onEditMeet,
            icon: const Icon(Icons.link_rounded, size: 18),
            label: const Text('Editar enlace'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.fondo3,
              side: const BorderSide(color: Color(0xFFC7D2FE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Cancelar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Color(0xFFFECACA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        OutlinedButton.icon(
          onPressed: onNoShow,
          icon: const Icon(Icons.person_off_outlined, size: 18),
          label: const Text('No asistió'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFF97316),
            side: const BorderSide(color: Color(0xFFFED7AA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        FilledButton.icon(
          onPressed: onComplete,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text('Completar'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Kantumruy Pro',
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Kantumruy Pro',
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.fondo3),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Kantumruy Pro',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
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
            OutlinedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: AppColors.fondo3, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Kantumruy Pro',
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAppointmentsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyAppointmentsState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.black38),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Kantumruy Pro',
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Kantumruy Pro',
                fontSize: 13,
                color: Colors.black54,
                height: 1.35,
              ),
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

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Kantumruy Pro',
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.fondo3,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? AppColors.fondo3 : const Color(0xFFE5E7EB),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

