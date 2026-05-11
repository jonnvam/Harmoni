import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentAccessCard extends StatelessWidget {
  final String modalidad;
  final String estado;
  final String? meetUrl;
  final String? ubicacion;

  const AppointmentAccessCard({
    super.key,
    required this.modalidad,
    required this.estado,
    this.meetUrl,
    this.ubicacion,
  });

  bool get _isOnline => modalidad.toLowerCase() == 'online';
  bool get _isPresencial => modalidad.toLowerCase() == 'presencial';
  bool get _isConfirmed => estado.toLowerCase() == 'confirmada';

  Future<void> _openMeet(BuildContext context) async {
    final url = (meetUrl ?? '').trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aún no hay enlace de videollamada para esta cita.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El enlace de la cita no es válido.'),
        ),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace de la cita.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConfirmed) {
      return _AccessInfoBox(
        icon: Icons.info_outline_rounded,
        title: 'Acceso pendiente',
        message: 'El acceso a la cita estará disponible cuando sea confirmada.',
      );
    }

    if (_isOnline) {
      final hasMeetUrl = (meetUrl ?? '').trim().isNotEmpty;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E7FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: Color(0xFF6366F1),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cita en línea',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              hasMeetUrl
                  ? 'Usa este enlace para entrar a la videollamada.'
                  : 'El enlace aún no está disponible.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                fontFamily: 'Kantumruy Pro',
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasMeetUrl ? () => _openMeet(context) : null,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Unirse a la cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isPresencial) {
      final locationText = (ubicacion ?? '').trim();

      return _AccessInfoBox(
        icon: Icons.location_on_outlined,
        title: 'Cita presencial',
        message: locationText.isEmpty
            ? 'La ubicación aún no fue especificada.'
            : locationText,
      );
    }

    return _AccessInfoBox(
      icon: Icons.help_outline_rounded,
      title: 'Modalidad no especificada',
      message: 'Revisa los detalles de la cita.',
    );
  }
}

class _AccessInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AccessInfoBox({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontFamily: 'Kantumruy Pro',
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}