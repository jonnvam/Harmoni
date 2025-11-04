import 'package:flutter/material.dart';

class PsychologistHomeScreen extends StatelessWidget {
  const PsychologistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Psicólogo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CardNav(
            icon: Icons.calendar_today,
            title: 'Citas / Agenda',
            subtitle: 'Gestiona tus turnos y disponibilidad',
            onTap: () {
              // TODO: Navegar a pantalla de Citas
            },
          ),
          const SizedBox(height: 12),
          _CardNav(
            icon: Icons.group,
            title: 'Pacientes',
            subtitle: 'Revisa y administra tus pacientes',
            onTap: () {
              // TODO: Navegar a pantalla de Pacientes
            },
          ),
          const SizedBox(height: 12),
          _CardNav(
            icon: Icons.person_outline,
            title: 'Perfil Profesional',
            subtitle: 'Edita tu información y especialidades',
            onTap: () {
              // TODO: Navegar a editor de perfil
            },
          ),
          const SizedBox(height: 12),
          _CardNav(
            icon: Icons.schedule,
            title: 'Disponibilidad',
            subtitle: 'Configura horarios y días',
            onTap: () {
              // TODO: Navegar a disponibilidad
            },
          ),
        ],
      ),
    );
  }
}

class _CardNav extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CardNav({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(icon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
