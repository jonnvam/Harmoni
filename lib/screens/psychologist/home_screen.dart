import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/services/psychologist_public_profile_service.dart';

class PsychologistHomeScreen extends StatelessWidget {
  const PsychologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const DropMenu(),
                  MaxWidthContainer(
                    child: _ProfessionalProfileGate(),
                  ),
                ],
              ),
            ),
            // Menú circular inferior con las 3 opciones principales
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SemiCircularRadialMenu(
                  currentIconAsset: "assets/images/icon/house.svg",
                  ringColor: Colors.transparent,
                  items: [
                    // Home
                    
                    // Citas
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/agenda.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistAppointmentsScreen()),
                      ),
                    ),
                    // Pacientes
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/pacientes.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistPatientsScreen()),
                      ),
                    ),
                    // Disponibilidad
                    RadialMenuItem(
                      iconAsset: "assets/images/icon/disponi.svg",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PsychologistAvailabilityScreen()),
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

class _ProfessionalProfileGate extends StatelessWidget {
  const _ProfessionalProfileGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PsychologistPublicProfileModel?>(
      stream: PsychologistPublicProfileService.instance.publicProfileStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar tu perfil profesional.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null || !profile.isComplete) {
          return const _ProfessionalProfileForm();
        }

        return _DashboardContent();
      },
    );
  }
}

class _ProfessionalProfileForm extends StatefulWidget {
  const _ProfessionalProfileForm();

  @override
  State<_ProfessionalProfileForm> createState() =>
      _ProfessionalProfileFormState();
}

class _ProfessionalProfileFormState extends State<_ProfessionalProfileForm> {
  final _honorariosCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _aniosCtrl = TextEditingController();

  final Set<String> _especialidades = {};
  final Set<String> _modalidades = {};
  final Set<String> _enfoques = {};
  final Set<String> _atiendeA = {};

  bool _saving = false;

  static const Map<String, String> _especialidadesDisponibles = {
    'ansiedad': 'Ansiedad',
    'depresion': 'Depresión',
    'estres': 'Estrés',
    'adicciones': 'Adicciones',
    'duelo': 'Duelo',
    'autoestima': 'Autoestima',
    'relaciones': 'Relaciones',
    'crisis_emocional': 'Crisis emocional',
    'trastornos_alimentarios': 'Trastornos alimentarios',
    'orientacion_vocacional': 'Orientación vocacional',
  };

  static const Map<String, String> _modalidadesDisponibles = {
    'online': 'En línea',
    'presencial': 'Presencial',
  };

  static const Map<String, String> _enfoquesDisponibles = {
    'cognitivo_conductual': 'Cognitivo-conductual',
    'humanista': 'Humanista',
    'sistemico': 'Sistémico',
    'psicoeducativo': 'Psicoeducativo',
    'integrativo': 'Integrativo',
  };

  static const Map<String, String> _atiendeADisponibles = {
    'adolescentes': 'Adolescentes',
    'adultos': 'Adultos',
    'parejas': 'Parejas',
    'familias': 'Familias',
  };

  @override
  void dispose() {
    _honorariosCtrl.dispose();
    _descripcionCtrl.dispose();
    _aniosCtrl.dispose();
    super.dispose();
  }

  void _toggle(Set<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  Future<void> _save() async {
    final honorarios = int.tryParse(_honorariosCtrl.text.trim()) ?? 0;
    final aniosText = _aniosCtrl.text.trim();
    final anios = aniosText.isEmpty ? null : int.tryParse(aniosText);

    setState(() => _saving = true);

    try {
      await PsychologistPublicProfileService.instance.savePublicProfile(
        especialidades: _especialidades.toList(),
        modalidades: _modalidades.toList(),
        honorariosSesion: honorarios,
        descripcionProfesional: _descripcionCtrl.text,
        enfoquesTerapia: _enfoques.toList(),
        atiendeA: _atiendeA.toList(),
        aniosExperiencia: anios,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil profesional publicado correctamente.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleSection(
            texto: 'Completa tu perfil profesional',
            maxLines: 2,
            padding: EdgeInsets.zero,
          ),

          const SizedBox(height: 8),

          const Text(
            'Estos datos se mostrarán a los pacientes para que puedan conocerte y agendar una cita contigo.',
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              fontFamily: 'Kantumruy Pro',
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          _ProfileFormCard(
            title: 'Especialidades',
            subtitle: 'Selecciona una o varias áreas de atención.',
            child: _ChipGroup(
              options: _especialidadesDisponibles,
              selected: _especialidades,
              onTap: (value) => _toggle(_especialidades, value),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Modalidades',
            subtitle: 'Indica cómo puedes atender a tus pacientes.',
            child: _ChipGroup(
              options: _modalidadesDisponibles,
              selected: _modalidades,
              onTap: (value) => _toggle(_modalidades, value),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Honorarios',
            subtitle: 'Costo por sesión en pesos mexicanos.',
            child: TextField(
              controller: _honorariosCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                suffixText: 'MXN',
                hintText: 'Ej. 650',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Descripción profesional',
            subtitle:
                'Escribe una breve presentación. Mínimo 80 caracteres.',
            child: TextField(
              controller: _descripcionCtrl,
              maxLines: 5,
              maxLength: 600,
              decoration: InputDecoration(
                hintText:
                    'Ej. Soy psicóloga clínica con experiencia en acompañamiento emocional...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Enfoque terapéutico',
            subtitle: 'Opcional, pero ayuda a orientar al paciente.',
            child: _ChipGroup(
              options: _enfoquesDisponibles,
              selected: _enfoques,
              onTap: (value) => _toggle(_enfoques, value),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Población que atiendes',
            subtitle: 'Opcional. Selecciona a quiénes puedes atender.',
            child: _ChipGroup(
              options: _atiendeADisponibles,
              selected: _atiendeA,
              onTap: (value) => _toggle(_atiendeA, value),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Años de experiencia',
            subtitle: 'Opcional.',
            child: TextField(
              controller: _aniosCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ej. 3',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _saving ? 'Guardando...' : 'Publicar perfil',
                style: const TextStyle(
                  fontFamily: 'Kantumruy Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('Inicia sesión para ver tu panel')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const TitleSection(
          texto: 'Inicio',
          maxLines: 2,
          padding: EdgeInsets.only(top: 32),
        ),
        const SizedBox(height: 8),
        Text(
          'Resumen del día',
          style: TextStyles.textDicho.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('psychId', isEqualTo: uid)
              .orderBy('dateTime')
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final docs = snap.data?.docs ?? [];
            final now = DateTime.now();
            final startOfDay = DateTime(now.year, now.month, now.day);
            final endOfDay = startOfDay.add(const Duration(days: 1));

            final all = docs.map((e) => (e.data() as Map<String, dynamic>? ?? {})).toList();
            // Próximas confirmadas de hoy
            final todaysConfirmed = all
                .where((d) {
                  final ts = d['dateTime'];
                  if (ts is! Timestamp) return false;
                  final dt = ts.toDate();
                  final status = (d['status'] ?? '').toString();
                  return dt.isAfter(startOfDay) && dt.isBefore(endOfDay) && status == 'confirmada';
                })
                .toList()
              ..sort((a, b) => (a['dateTime'] as Timestamp).toDate().compareTo((b['dateTime'] as Timestamp).toDate()));

            // Solicitudes pendientes (sin restricción de día)
            final pending = all.where((d) => (d['status'] ?? '').toString() == 'pendiente').toList()
              ..sort((a, b) => (a['dateTime'] as Timestamp).toDate().compareTo((b['dateTime'] as Timestamp).toDate()));

            return Column(
              children: [
                _InfoCard(
                  title: 'Próximas citas de hoy',
                  emptyText: 'No hay citas confirmadas para hoy',
                  items: todaysConfirmed.take(3).map((d) {
                    final name = (d['patientName'] ?? 'Paciente').toString();
                    final dt = (d['dateTime'] as Timestamp).toDate();
                    final hour = dt.hour.toString().padLeft(2, '0');
                    final min = dt.minute.toString().padLeft(2, '0');
                    return '$hour:$min · $name';
                  }).toList(),
                  trailing: todaysConfirmed.isNotEmpty
                      ? Text('${todaysConfirmed.length} en total', style: const TextStyle(fontSize: 12, color: Colors.black54))
                      : null,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Solicitudes pendientes',
                  emptyText: 'Sin solicitudes por ahora',
                  items: pending.take(3).map((d) {
                    final name = (d['patientName'] ?? 'Paciente').toString();
                    return name;
                  }).toList(),
                  trailing: pending.isNotEmpty
                      ? Text('${pending.length} pendientes', style: const TextStyle(fontSize: 12, color: Colors.black54))
                      : null,
                ),
                const SizedBox(height: 120),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final String emptyText;
  final Widget? trailing;

  const _InfoCard({required this.title, required this.items, required this.emptyText, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(emptyText, style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Kantumruy Pro'))
            else
              Column(
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                          const SizedBox(width: 6),
                          Expanded(child: Text(it, style: const TextStyle(fontSize: 14, fontFamily: 'Kantumruy Pro'))),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ProfileFormCard({
    required this.title,
    required this.subtitle,
    required this.child,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Kantumruy Pro',
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Kantumruy Pro',
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final Map<String, String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = selected.contains(entry.key);

        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          selectedColor: const Color(0xFFEEF2FF),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontFamily: 'Kantumruy Pro',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFE2E8F0),
          ),
          onSelected: (_) => onTap(entry.key),
        );
      }).toList(),
    );
  }
}