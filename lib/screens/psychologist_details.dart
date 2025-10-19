import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/psychologist.dart';

class PsychologistDetailsScreen extends StatelessWidget {
  final Psychologist psychologist;
  const PsychologistDetailsScreen({super.key, required this.psychologist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(psychologist.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calificación: ${psychologist.rating.toStringAsFixed(1)} ★', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Precio: ${psychologist.price} MXN', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Especialidades: ${psychologist.specialties.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
