import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/psychologist/home_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/services/psychologist_appointments_service.dart';

class PsychologistAppointmentsScreen extends StatefulWidget {
  const PsychologistAppointmentsScreen({super.key});

  @override
  State<PsychologistAppointmentsScreen> createState() => _PsychologistAppointmentsScreenState();
}

class _PsychologistAppointmentsScreenState extends State<PsychologistAppointmentsScreen> {
  String _filter = 'hoy';

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

                          const SizedBox(height: 16),

                          Expanded(
                            child: StreamBuilder<
                                List<PsychologistAppointmentModel>>(
                              stream: PsychologistAppointmentsService.instance
                                  .watchMyAppointments(),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
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

                                final solicitadas = citas
                                    .where((c) => c.estado == 'solicitada')
                                    .toList();

                                final confirmadas = citas
                                    .where((c) => c.estado == 'confirmada')
                                    .toList();

                                final otras = citas
                                    .where(
                                      (c) =>
                                          c.estado != 'solicitada' &&
                                          c.estado != 'confirmada',
                                    )
                                    .toList();

                                return ListView(
                                  children: [
                                    if (solicitadas.isNotEmpty) ...[
                                      const _SectionLabel(
                                        text: 'Solicitudes pendientes',
                                      ),
                                      const SizedBox(height: 8),
                                      ...solicitadas.map(
                                        (cita) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: _AppointmentTile(
                                            appointment: cita,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    if (confirmadas.isNotEmpty) ...[
                                      const _SectionLabel(
                                        text: 'Citas confirmadas',
                                      ),
                                      const SizedBox(height: 8),
                                      ...confirmadas.map(
                                        (cita) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: _AppointmentTile(
                                            appointment: cita,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    if (otras.isNotEmpty) ...[
                                      const _SectionLabel(
                                        text: 'Historial',
                                      ),
                                      const SizedBox(height: 8),
                                      ...otras.map(
                                        (cita) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: _AppointmentTile(
                                            appointment: cita,
                                          ),
                                        ),
                                      ),
                                    ],
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
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PsychologistPatientsScreen(),
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
                      iconAsset: "assets/images/icon/disponi.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PsychologistAvailabilityScreen(),
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

  const _AppointmentTile({
    required this.appointment,
  });

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
        return const Color(0xFFEF4444);
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
      case 'solicitada':
      default:
        return 'Solicitada';
    }
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
    try {
      await PsychologistAppointmentsService.instance.confirmAppointment(
        appointment: appointment,
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
                Text(
                  'Detalle de cita',
                  style: const TextStyle(
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({
    required this.text,
  });

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

  const _StatusBadge({
    required this.text,
    required this.color,
  });

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

  const _MiniInfoChip({
    required this.icon,
    required this.text,
  });

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
