import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/services/patient_appointments_service.dart';
import 'package:flutter_application_1/components/appointment_access_card.dart';
import 'package:flutter_application_1/components/appointment_access_card.dart';

class MisCitasScreen extends StatelessWidget {
  const MisCitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
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
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mis citas',
                      style: TextStyles.tituloBienvenida.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Consulta el estado de tus solicitudes y citas confirmadas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: StreamBuilder<List<PatientAppointmentModel>>(
                stream:
                    PatientAppointmentsService.instance.watchMyAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const _EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'No se pudieron cargar tus citas',
                      message: 'Revisa tu conexión o intenta nuevamente.',
                    );
                  }

                  final citas = snapshot.data ?? [];

                  if (citas.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'Aún no tienes citas',
                      message:
                          'Cuando solicites una cita con un psicólogo, aparecerá aquí.',
                    );
                  }

                  final solicitadas =
                      citas
                          .where((cita) => cita.estado == 'solicitada')
                          .toList();

                  final confirmadas =
                      citas
                          .where((cita) => cita.estado == 'confirmada')
                          .toList();

                  final historial =
                      citas
                          .where(
                            (cita) =>
                                cita.estado != 'solicitada' &&
                                cita.estado != 'confirmada',
                          )
                          .toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      if (solicitadas.isNotEmpty) ...[
                        const _SectionTitle(text: 'Solicitudes pendientes'),
                        const SizedBox(height: 10),
                        ...solicitadas.map(
                          (cita) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PatientAppointmentCard(cita: cita),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (confirmadas.isNotEmpty) ...[
                        const _SectionTitle(text: 'Citas confirmadas'),
                        const SizedBox(height: 10),
                        ...confirmadas.map(
                          (cita) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PatientAppointmentCard(cita: cita),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      if (historial.isNotEmpty) ...[
                        const _SectionTitle(text: 'Historial'),
                        const SizedBox(height: 10),
                        ...historial.map(
                          (cita) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PatientAppointmentCard(cita: cita),
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
    );
  }
}

class _PatientAppointmentCard extends StatelessWidget {
  final PatientAppointmentModel cita;

  const _PatientAppointmentCard({required this.cita});

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

  String _statusLabel(String status) {
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
        return 'Cancelada por ti';
      case 'completada':
        return 'Completada';
      case 'no_asistio':
        return 'No asistió';
      case 'solicitada':
      default:
        return 'Solicitada';
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

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(cita.estado);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _showDetails(context),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
                  radius: 21,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: AppColors.fondo3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cita.psychologistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(text: _statusLabel(cita.estado), color: color),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${_formatDate(cita.fechaInicio)} · '
              '${_formatHour(cita.fechaInicio)} - ${_formatHour(cita.fechaFin)}',
              style: const TextStyle(
                fontFamily: 'Kantumruy Pro',
                color: Colors.black54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniChip(
                  icon: Icons.video_call_rounded,
                  text: _modalidadLabel(cita.modalidad),
                ),
                _MiniChip(
                  icon: Icons.payments_rounded,
                  text: _paymentLabel(cita.metodoPago),
                ),
                _MiniChip(
                  icon: Icons.attach_money_rounded,
                  text: '\$${cita.precio} ${cita.moneda}',
                ),
              ],
            ),

            if (cita.estado == 'confirmada') ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  'Tu cita fue confirmada. Ya existe un vínculo activo con este psicólogo.',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AppointmentAccessCard(
                modalidad: cita.modalidad,
                estado: cita.estado,
                meetUrl: cita.meetUrl,
                ubicacion: '',
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancel(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar cita'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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

  Future<void> _cancel(BuildContext context) async {
    final reason = await _askCancelReason(context);

    if (reason == null) return;

    try {
      await PatientAppointmentsService.instance.cancelAppointment(
        appointment: cita,
        reason: reason,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cita cancelada.')));
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
                  icon: Icons.psychology_rounded,
                  label: 'Psicólogo',
                  value: cita.psychologistName,
                ),

                _DetailRow(
                  icon: Icons.calendar_month_rounded,
                  label: 'Fecha',
                  value: _formatDate(cita.fechaInicio),
                ),

                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Horario',
                  value:
                      '${_formatHour(cita.fechaInicio)} - ${_formatHour(cita.fechaFin)}',
                ),

                _DetailRow(
                  icon: Icons.video_call_rounded,
                  label: 'Modalidad',
                  value: _modalidadLabel(cita.modalidad),
                ),

                const SizedBox(height: 10),

                AppointmentAccessCard(
                  modalidad: cita.modalidad,
                  estado: cita.estado,
                  meetUrl: cita.meetUrl,
                  ubicacion: '',
                ),

                AppointmentAccessCard(
                  modalidad: cita.modalidad,
                  estado: cita.estado,
                  meetUrl: cita.meetUrl,
                  ubicacion: '',
                ),

                _DetailRow(
                  icon: Icons.payments_rounded,
                  label: 'Pago',
                  value:
                      '${_paymentLabel(cita.metodoPago)} · ${cita.pagoEstado}',
                ),

                _DetailRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Estado',
                  value: _statusLabel(cita.estado),
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
                    cita.motivoConsulta.isEmpty
                        ? 'Sin motivo especificado.'
                        : cita.motivoConsulta,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      height: 1.35,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (cita.estado == 'confirmada') ...[
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _cancel(context);
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar cita'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

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

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({required this.icon, required this.text});

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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
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
      ),
    );
  }
}
