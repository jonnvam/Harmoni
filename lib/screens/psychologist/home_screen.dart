import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/psychologist/appointments_screen.dart';
import 'package:flutter_application_1/screens/psychologist/patients_screen.dart';
import 'package:flutter_application_1/screens/psychologist/availability_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/services/psychologist_public_profile_service.dart';
import 'package:shimmer/shimmer.dart';

class PsychologistHomeScreen extends StatelessWidget {
  const PsychologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                DropMenu(
                  avatarBuilder: (_) => const _PsychologistHeaderAvatar(),
                ),
                MaxWidthContainer(child: _ProfessionalProfileGate()),
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
                  // Citas
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/agenda.svg",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const PsychologistAppointmentsScreen(),
                          ),
                        ),
                  ),
                  // Pacientes
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/pacientes.svg",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PsychologistPatientsScreen(),
                          ),
                        ),
                  ),
                  // Disponibilidad
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
    );
  }
}

class _PsychologistHeaderAvatar extends StatelessWidget {
  const _PsychologistHeaderAvatar();

  String _initialsFrom(String? name) {
    final clean = (name ?? '').trim();
    if (clean.isEmpty) return 'P';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Color.fromARGB(255, 224, 224, 224),
        child: Text(
          'P',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 27, 25, 25),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('usuariosPsicologos')
              .doc(user.uid)
              .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
            ),
          );
        }

        if (snap.hasError) {
          return const CircleAvatar(
            radius: 30,
            backgroundColor: Color.fromARGB(255, 224, 224, 224),
            child: Icon(Icons.error_outline, color: Colors.black54),
          );
        }

        final data = snap.data?.data() ?? {};
        final displayName = (data['displayName'] ?? '').toString().trim();
        final photoUrl = (data['photoUrl'] ?? '').toString().trim();

        if (photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: 30,
            backgroundColor: const Color.fromARGB(255, 224, 224, 224),
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          );
        }

        final initials = _initialsFrom(
          displayName.isNotEmpty ? displayName : user.displayName,
        );

        return CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromARGB(255, 224, 224, 224),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 27, 25, 25),
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
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

        return _DashboardContent(profile: profile);
      },
    );
  }
}

class _ProfessionalProfileForm extends StatefulWidget {
  final PsychologistPublicProfileModel? initialProfile;
  final bool isEditing;

  const _ProfessionalProfileForm({this.initialProfile, this.isEditing = false});

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

  static const Map<String, String> especialidadesDisponiblesPublic = {
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

  static const Map<String, String> modalidadesDisponiblesPublic = {
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
  void initState() {
    super.initState();

    final profile = widget.initialProfile;

    if (profile != null) {
      _honorariosCtrl.text = profile.honorariosSesion.toString();
      _descripcionCtrl.text = profile.descripcionProfesional;

      if (profile.aniosExperiencia != null) {
        _aniosCtrl.text = profile.aniosExperiencia.toString();
      }

      _especialidades.addAll(profile.especialidades);
      _modalidades.addAll(profile.modalidades);
      _enfoques.addAll(profile.enfoquesTerapia);
      _atiendeA.addAll(profile.atiendeA);
    }
  }

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
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Perfil profesional actualizado correctamente.'
                : 'Perfil profesional publicado correctamente.',
          ),
        ),
      );

      if (widget.isEditing && mounted) {
        Navigator.pop(context);
      }
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
              options: especialidadesDisponiblesPublic,
              selected: _especialidades,
              onTap: (value) => _toggle(_especialidades, value),
            ),
          ),

          const SizedBox(height: 14),

          _ProfileFormCard(
            title: 'Modalidades',
            subtitle: 'Indica cómo puedes atender a tus pacientes.',
            child: _ChipGroup(
              options: modalidadesDisponiblesPublic,
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
            subtitle: 'Escribe una breve presentación. Mínimo 80 caracteres.',
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
                _saving
                    ? 'Guardando...'
                    : widget.isEditing
                    ? 'Guardar cambios'
                    : 'Publicar perfil',
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
  final PsychologistPublicProfileModel profile;

  const _DashboardContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('Inicia sesión para ver tu panel')),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 130),
      child: Column(
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
            'Resumen de tu actividad profesional',
            style: TextStyles.textDicho.copyWith(fontSize: 14),
          ),

          const SizedBox(height: 16),

          _ProfessionalProfileSummaryCard(profile: profile),

          const SizedBox(height: 14),

          _TodayAppointmentsCard(psychologistUid: uid),

          const SizedBox(height: 14),

          _PendingRequestsCard(psychologistUid: uid),
        ],
      ),
    );
  }
}

class _ProfessionalProfileSummaryCard extends StatelessWidget {
  final PsychologistPublicProfileModel profile;

  const _ProfessionalProfileSummaryCard({required this.profile});

  String _joinLabels(List<String> values, Map<String, String> labels) {
    if (values.isEmpty) return 'Sin datos';
    return values.map((v) => labels[v] ?? v).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final especialidades = _joinLabels(
      profile.especialidades,
      _ProfessionalProfileFormState.especialidadesDisponiblesPublic,
    );

    final modalidades = _joinLabels(
      profile.modalidades,
      _ProfessionalProfileFormState.modalidadesDisponiblesPublic,
    );

    return Ink(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.badge_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perfil profesional',
                    style: TextStyles.textEditar.copyWith(fontSize: 18),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => _ProfessionalProfileEditScreen(
                              profile: profile,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              profile.descripcionProfesional,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.black54,
                fontFamily: 'Kantumruy Pro',
              ),
            ),

            const SizedBox(height: 14),

            _ProfileMiniRow(
              icon: Icons.psychology_outlined,
              title: 'Especialidades',
              value: especialidades,
            ),

            const SizedBox(height: 8),

            _ProfileMiniRow(
              icon: Icons.videocam_outlined,
              title: 'Modalidades',
              value: modalidades,
            ),

            const SizedBox(height: 8),

            _ProfileMiniRow(
              icon: Icons.payments_outlined,
              title: 'Honorarios',
              value: '\$${profile.honorariosSesion} MXN por sesión',
            ),

            if (profile.aniosExperiencia != null) ...[
              const SizedBox(height: 8),
              _ProfileMiniRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Experiencia',
                value: '${profile.aniosExperiencia} años',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileMiniRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileMiniRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black45),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'Kantumruy Pro',
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfessionalProfileEditScreen extends StatelessWidget {
  final PsychologistPublicProfileModel profile;

  const _ProfessionalProfileEditScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar perfil profesional'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MaxWidthContainer(
            child: _ProfessionalProfileForm(
              initialProfile: profile,
              isEditing: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleDashboardCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final String emptyText;
  final Widget? trailing;

  const _SimpleDashboardCard({
    required this.title,
    required this.items,
    required this.emptyText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
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
              Text(
                emptyText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontFamily: 'Kantumruy Pro',
                ),
              )
            else
              Column(
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              it,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Kantumruy Pro',
                              ),
                            ),
                          ),
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

class _DashboardCardSkeleton extends StatelessWidget {
  const _DashboardCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
      children:
          options.entries.map((entry) {
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
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
              onSelected: (_) => onTap(entry.key),
            );
          }).toList(),
    );
  }
}

class _TodayAppointmentsCard extends StatelessWidget {
  final String psychologistUid;

  const _TodayAppointmentsCard({
    required this.psychologistUid,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('citas')
          .where('psychologistUid', isEqualTo: psychologistUid)
          .where('estado', isEqualTo: 'confirmada')
          .where(
            'fechaInicio',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'fechaInicio',
            isLessThan: Timestamp.fromDate(endOfDay),
          )
          .orderBy('fechaInicio')
          .limit(3)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _DashboardCardSkeleton();
        }

        if (snap.hasError) {
          return const _SimpleDashboardCard(
            title: 'Próximas citas de hoy',
            emptyText: 'No se pudieron cargar tus próximas citas.',
            items: [],
          );
        }

        final docs = snap.data?.docs ?? [];

        final items = docs.map((doc) {
          final data = doc.data();
          final patientName = (data['patientName'] ?? 'Paciente').toString();
          final modalidad = (data['modalidad'] ?? '').toString();
          final fecha = (data['fechaInicio'] as Timestamp?)?.toDate();

          if (fecha == null) return patientName;

          final hour = fecha.hour.toString().padLeft(2, '0');
          final minute = fecha.minute.toString().padLeft(2, '0');

          return '$hour:$minute · $patientName${modalidad.isNotEmpty ? ' · $modalidad' : ''}';
        }).toList();

        return _SimpleDashboardCard(
          title: 'Próximas citas de hoy',
          emptyText: 'No hay citas confirmadas para hoy',
          items: items,
          trailing: docs.isNotEmpty
              ? Text(
                  '${docs.length} próximas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _PendingRequestsCard extends StatelessWidget {
  final String psychologistUid;

  const _PendingRequestsCard({
    required this.psychologistUid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('citas')
          .where('psychologistUid', isEqualTo: psychologistUid)
          .where('estado', isEqualTo: 'solicitada')
          .orderBy('fechaInicio')
          .limit(3)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _DashboardCardSkeleton();
        }

        if (snap.hasError) {
          return const _SimpleDashboardCard(
            title: 'Solicitudes pendientes',
            emptyText: 'No se pudieron cargar las solicitudes.',
            items: [],
          );
        }

        final docs = snap.data?.docs ?? [];

        final items = docs.map((doc) {
          final data = doc.data();
          final patientName = (data['patientName'] ?? 'Paciente').toString();
          final motivo = (data['motivoConsulta'] ?? '').toString();
          final fecha = (data['fechaInicio'] as Timestamp?)?.toDate();

          String dateText = '';

          if (fecha != null) {
            final day = fecha.day.toString().padLeft(2, '0');
            final month = fecha.month.toString().padLeft(2, '0');
            final hour = fecha.hour.toString().padLeft(2, '0');
            final minute = fecha.minute.toString().padLeft(2, '0');
            dateText = '$day/$month · $hour:$minute';
          }

          if (motivo.isEmpty) {
            return '$patientName${dateText.isNotEmpty ? ' · $dateText' : ''}';
          }

          return '$patientName · $dateText · $motivo';
        }).toList();

        return _SimpleDashboardCard(
          title: 'Solicitudes pendientes',
          emptyText: 'Sin solicitudes por ahora',
          items: items,
          trailing: docs.isNotEmpty
              ? Text(
                  '${docs.length} pendientes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontFamily: 'Kantumruy Pro',
                  ),
                )
              : null,
        );
      },
    );
  }
}