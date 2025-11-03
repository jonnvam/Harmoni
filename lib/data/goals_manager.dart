import 'package:flutter/foundation.dart';

/// Estado de una meta.
enum GoalStatus { active, inProgress, completed }

class Goal {
  final String id;
  final String titulo;
  final String descripcion;
  GoalStatus status;
  final DateTime creada;
  DateTime? iniciada;
  DateTime? completada;

  Goal({
    required this.id,
    required this.titulo,
    required this.descripcion,
    this.status = GoalStatus.active,
    DateTime? creada,
  }) : creada = creada ?? DateTime.now();
}

/// Gestor global temporal (sin persistencia todavía)
class GoalsManager extends ValueNotifier<int> {
  GoalsManager._internal() : super(0);
  static final GoalsManager instance = GoalsManager._internal();

  final List<Goal> _goals = [
    Goal(
      id: '1',
      titulo: 'Beber agua 8 vasos',
      descripcion: 'Hidratarme durante el día para sentirme mejor',
    ),
    Goal(
      id: '2',
      titulo: 'Escribir en el diario',
      descripcion: 'Registrar emociones y pensamientos (5 mins)',
    ),
    Goal(
      id: '3',
      titulo: 'Caminar 15 minutos',
      descripcion: 'Mover el cuerpo y despejar la mente',
    ),
    Goal(
      id: '4',
      titulo: 'Respiración consciente',
      descripcion: '3 rondas de respiración profunda',
    ),
    Goal(
      id: '5',
      titulo: 'Agradecimientos',
      descripcion: 'Escribir 3 cosas por las que estoy agradecid@',
    ),
    Goal(
      id: '6',
      titulo: 'Respiración profunda',
      descripcion: 'Respirar 5 minutos',
    ),
  ];

  List<Goal> get activeGoals => _goals.where((g) => g.status == GoalStatus.active).toList();
  List<Goal> get inProgressGoals => _goals.where((g) => g.status == GoalStatus.inProgress).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.status == GoalStatus.completed).toList();

  // Número total de etapas (5) basado en metas completadas (simple: proporción completadas / 5).
  int get totalStages => 5;
  int get completedCount => completedGoals.length;
  // Ticks manuales para reflejar progresos desde Firestore/app sin acoplar a la lista interna
  int _manualProgress = 0;
  // Valor 0..1 para la flor (combinando completadas internas + ticks manuales)
  double get progressFraction => ((completedCount + _manualProgress) / totalStages).clamp(0, 1);
  // Etapa visual 0..5
  int get currentStage => (progressFraction * totalStages).floor().clamp(0, totalStages);

  bool startGoal(Goal goal) {
    if (goal.status != GoalStatus.active) return false;
    goal.status = GoalStatus.inProgress;
    goal.iniciada = DateTime.now();
    value++; // notificar
    return true;
  }

  bool completeGoal(Goal goal) {
    if (goal.status != GoalStatus.inProgress) return false;
    goal.status = GoalStatus.completed;
    goal.completada = DateTime.now();
    value++;
    return true;
  }

  void resetAllForDebug() {
    for (final g in _goals) {
      g.status = GoalStatus.active;
      g.iniciada = null;
      g.completada = null;
    }
    _manualProgress = 0;
    value++;
  }

  /// Mueve una meta activa al final del orden de metas activas (antes de las que no son activas
  /// en el orden filtrado). Por simplicidad, la enviamos al final de la lista global; como el
  /// filtrado conserva orden relativo, aparecerá al final del subconjunto de activas.
  void moveActiveGoalToEnd(Goal goal) {
    if (goal.status != GoalStatus.active) return;
    // Si ya está al final, nada.
    if (_goals.isNotEmpty && _goals.last == goal) return;
    _goals.remove(goal);
    _goals.add(goal);
    value++;
  }

  // Incrementa el progreso manual (máximo totalStages)
  void incrementProgressTick() {
    if (completedCount + _manualProgress < totalStages) {
      _manualProgress++;
      value++;
    }
  }
}
