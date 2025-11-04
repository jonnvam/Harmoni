import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/data/goals_manager.dart';

/// AnimatedFlower mejorada: ahora anima suavemente (tween) el incremento del
/// progreso de la flor y del anillo por etapas, evitando saltos bruscos.
/// Además hace un pequeño pulso + glow cuando se completa una nueva etapa.
class AnimatedFlower extends StatefulWidget {
  final String assetPath;
  final List<double>? segments; // mapeo opcional de rangos en la animación Lottie
  final double size;
  final bool showOverlayRing;
  final Duration progressDuration; // duración de la animación suave de llenado
  final Curve progressCurve;
  final bool pulseOnStageIncrement;
  final Duration pulseDuration;
  final double? fractionOverride;         // 0..1 si quieres forzar el avance
  final int? segmentsCountOverride; 

  const AnimatedFlower({
    super.key,
    required this.assetPath,
    this.segments,
    this.size = 220,
    this.showOverlayRing = false,
    this.progressDuration = const Duration(milliseconds: 900),
    this.progressCurve = Curves.easeInOutCubic,
    this.pulseOnStageIncrement = true,
    this.pulseDuration = const Duration(milliseconds: 420),
    this.fractionOverride,          
    this.segmentsCountOverride,
  });

  @override
  State<AnimatedFlower> createState() => _AnimatedFlowerState();
}

class _AnimatedFlowerState extends State<AnimatedFlower> with SingleTickerProviderStateMixin {
  double _prevFraction = 0; // fracción anterior (0..1)
  double _targetFraction = 0; // fracción objetivo (0..1)
  int _lastStage = 0;

  late final AnimationController _pulseController;
  bool _listeningGoalsManager = false;

  @override
  void initState() {
    super.initState();
    final gm = GoalsManager.instance;
    if (widget.fractionOverride != null) {
      _targetFraction = widget.fractionOverride!.clamp(0.0, 1.0);
      _prevFraction = _targetFraction;
      _lastStage = ( _targetFraction * (widget.segmentsCountOverride ?? gm.totalStages) ).floor();
      _listeningGoalsManager = false;
    } else {
      _targetFraction = gm.progressFraction;
      _prevFraction = _targetFraction;
      _lastStage = gm.currentStage;
      gm.addListener(_onGoalsChanged);
      _listeningGoalsManager = true;
    }

    _pulseController = AnimationController(vsync: this, duration: widget.pulseDuration);
  }

  @override
  void didUpdateWidget(covariant AnimatedFlower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseDuration != widget.pulseDuration) {
      _pulseController.duration = widget.pulseDuration;
    }

    if (widget.fractionOverride != null) {
      final newFrac = widget.fractionOverride!.clamp(0.0, 1.0);
      if (newFrac != _targetFraction) {
        setState(() {
          _prevFraction = _animatedValue;
          _targetFraction = newFrac;
        });
      }
      // Si antes escuchábamos al GM, dejamos de hacerlo (una sola vez).
      if (_listeningGoalsManager) {
        GoalsManager.instance.removeListener(_onGoalsChanged);
        _listeningGoalsManager = false;
      }
    } else {
      // Volvemos a GoalsManager si no hay override.
      if (!_listeningGoalsManager) {
        GoalsManager.instance.addListener(_onGoalsChanged);
        _listeningGoalsManager = true;
      }
    }
  }

  @override
  void dispose() {
    if (_listeningGoalsManager) {
      GoalsManager.instance.removeListener(_onGoalsChanged);
    }
    _pulseController.dispose();
    super.dispose();
  }

  void _onGoalsChanged() {
    if (widget.fractionOverride != null) return; // si hay override, ignoramos
    final gm = GoalsManager.instance;
    final newFraction = gm.progressFraction;
    if (newFraction == _targetFraction) return;
    setState(() {
      _prevFraction = _animatedValue;
      _targetFraction = newFraction;
      final newStage = gm.currentStage;
      if (widget.pulseOnStageIncrement && newStage > _lastStage) {
        _pulseController.forward(from: 0);
      }
      _lastStage = newStage;
    });
  }

  double get _animatedValue {
    // Si no se está tweening (p.ej. primer build), devolvemos target.
    // El TweenAnimationBuilder recompone valor actual.
    return _currentTweenValue ?? _targetFraction;
  }

  double? _currentTweenValue; // valor intermedio provisto por TweenAnimationBuilder

  double _mapFraction(double fraction) {
    final segments = widget.segments;
    if (segments == null || segments.length < 2) return fraction.clamp(0, 1);
    for (int i = 0; i < segments.length - 1; i++) {
      final start = segments[i];
      final end = segments[i + 1];
      final globalStartFrac = i / (segments.length - 1);
      final globalEndFrac = (i + 1) / (segments.length - 1);
      if (fraction >= globalStartFrac && fraction <= globalEndFrac) {
        final localT = (fraction - globalStartFrac) / (globalEndFrac - globalStartFrac);
        return start + (end - start) * localT;
      }
    }
    return fraction;
  }

  @override
  Widget build(BuildContext context) {
    final gm = GoalsManager.instance;
    final totalStages = widget.fractionOverride != null
        ? (widget.segmentsCountOverride ?? 6)
        : gm.totalStages;
    final stageNow = widget.fractionOverride != null
        ? (_targetFraction * totalStages).floor()
        : gm.currentStage;

    return TweenAnimationBuilder<double>(
      key: ValueKey(_targetFraction),
      tween: Tween(begin: _prevFraction, end: _targetFraction),
      duration: widget.progressDuration,
      curve: widget.progressCurve,
      onEnd: () {
        // Al terminar fijamos prev = target para siguientes animaciones encadenadas.
        _prevFraction = _targetFraction;
        _currentTweenValue = _targetFraction;
      },
      builder: (context, value, child) {
        _currentTweenValue = value;
        final lottieProgress = _mapFraction(value);
        final pulse = _pulseController.value;
        // Scale con curva simétrica (pulso): 0 -> 1 -> 0 => usar sin/cos custom
        final pulseScale = 1 + (pulse > 0 ? (0.07 * (1 - (2 * (pulse - 0.5)).abs())) : 0);

        return SizedBox(
          width: widget.size,
            height: widget.size,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              return Transform.scale(
                scale: pulseScale.toDouble(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lottie en modo "scrub" con el valor animado
                    Lottie.asset(
                      widget.assetPath,
                      frameRate: FrameRate.max,
                      repeat: false,
                      animate: false,
                      controller: AlwaysStoppedAnimation(lottieProgress),
                    ),
                    if (widget.showOverlayRing)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _ProgressSegmentsPainter(
                              fraction: value,
                              segments: totalStages,
                              activeColor: const Color.fromRGBO(217, 87, 230, 0.92),
                              inactiveColor: const Color.fromRGBO(240, 232, 241, 0.4),
                              glow: true,
                              highlightSegment: value < 1 ? (value * totalStages).floor() : totalStages - 1,
                              stage: stageNow,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProgressSegmentsPainter extends CustomPainter {
  final double fraction; // 0..1 animada
  final int segments;
  final Color activeColor;
  final Color inactiveColor;
  final bool glow;
  final int highlightSegment; // índice del segmento actual en llenado
  final int stage; // etapa actual (entera)

  _ProgressSegmentsPainter({
    required this.fraction,
    required this.segments,
    required this.activeColor,
    required this.inactiveColor,
    required this.glow,
    required this.highlightSegment,
    required this.stage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 12.0;
    final radius = (size.width / 2) - strokeWidth / 2 - 4;
    final segAngle = (2 * 3.141592653589793) / segments;
    final startAngle = -3.141592653589793 / 2;
    final full = fraction * segments;
    final fullSegments = full.floor();
    final partial = full - fullSegments;

    final inactivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = inactiveColor;

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = activeColor;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
  ..color = activeColor.withValues(alpha: 0.35)
      ..maskFilter = glow ? const MaskFilter.blur(BlurStyle.normal, 6) : null;

    // Inactivos primero
    for (int i = 0; i < segments; i++) {
      final a1 = startAngle + i * segAngle + 0.11;
      final usable = segAngle - 0.22;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), a1, usable, false, inactivePaint);
    }

    // Segmentos completos
    for (int i = 0; i < fullSegments; i++) {
      final a1 = startAngle + i * segAngle + 0.11;
      final usable = segAngle - 0.22;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), a1, usable, false, activePaint);
    }

    // Segmento parcial (en progreso)
    if (partial > 0 && fullSegments < segments) {
      final a1 = startAngle + fullSegments * segAngle + 0.11;
      final usable = segAngle - 0.22;
      final arc = usable * partial;
      // Glow debajo
      if (glow) {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), a1, arc, false, glowPaint);
      }
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        a1,
        arc,
        false,
  activePaint..color = activeColor.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressSegmentsPainter old) {
    return old.fraction != fraction ||
        old.segments != segments ||
        old.stage != stage;
  }
}
