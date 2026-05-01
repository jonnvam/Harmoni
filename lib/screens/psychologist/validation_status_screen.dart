import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ValidationStatusScreen extends StatelessWidget {
  const ValidationStatusScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'PREVALIDADO':
        return Colors.blue;
      case 'PENDIENTE_VALIDACION_OFICIAL':
        return Colors.orange;
      case 'VALIDADO_OFICIAL':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _estadoTexto(String estado) {
    switch (estado) {
      case 'PREVALIDADO':
        return 'Prevalidado';
      case 'PENDIENTE_VALIDACION_OFICIAL':
        return 'Pendiente de revisión oficial';
      case 'VALIDADO_OFICIAL':
        return 'Validado oficialmente';
      case 'RECHAZADO':
        return 'Rechazado';
      default:
        return 'Sin verificar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Inicia sesión para ver tu estado.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Estado de validación'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verificacionesProfesionales')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Aún no has enviado tu verificación.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final estado = data['estadoValidacion'] ?? 'SIN_VERIFICAR';
          final puedeEjercer = data['puedeEjercer'] ?? false;
          final nombre = data['nombreCompletoIne'] ?? '';
          final cedula = data['cedulaIngresada'] ?? '';
          final carrera = data['carreraBuholegal'] ?? '';
          final motivo = data['motivoRechazo'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _estadoColor(estado).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _estadoColor(estado)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _estadoTexto(estado),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _estadoColor(estado),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        puedeEjercer
                            ? 'Puedes ejercer dentro de la app.'
                            : 'Aún no puedes ejercer dentro de la app.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Nombre INE: $nombre'),
                const SizedBox(height: 8),
                Text('Cédula detectada: $cedula'),
                const SizedBox(height: 8),
                Text('Carrera Búho Legal: $carrera'),
                if (motivo.toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Motivo: $motivo',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}