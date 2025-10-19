import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/data/goals_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Ahora usamos el GoalsManager global; esta pantalla no define modelo propio.

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final GoalsManager _manager = GoalsManager.instance;
  double _dragDx = 0.0; // para navegar lateral (explorar)
  double _dragDy = 0.0; // para detectar swipe vertical (iniciar)
  bool _swipingHorizontally = false; // bloquea interacciones mientras animamos salida
  bool _horizontalExitLeft = false; // dirección de salida

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onGoalsChanged);
  }

  void _onGoalsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _manager.removeListener(_onGoalsChanged);
    super.dispose();
  }

  void _resetDrag() {
    _dragDx = 0;
    _dragDy = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDx += details.delta.dx;
      _dragDy += details.delta.dy;
    });
  }

  void _onDragEnd(DragEndDetails details, Goal topGoal) {
    // Si el gesto fue principalmente hacia arriba (dy negativo) y superó umbral, iniciamos meta.
    const verticalThreshold = -120; // mover >= 120px hacia arriba
    if (_dragDy < verticalThreshold) {
      _startGoal(topGoal);
    }
    // Para navegación lateral (solo "explorar" visual): si se movió suficiente, saltamos a la siguiente carta lógicamente rotando lista.
    else if (_dragDx.abs() > 140) {
      // Disparar animación de salida horizontal y luego mover meta al final
      if (!_swipingHorizontally) {
        _horizontalExitLeft = _dragDx < 0;
        setState(() => _swipingHorizontally = true);
        Future.delayed(const Duration(milliseconds: 180), () {
          // Reordenar
          _manager.moveActiveGoalToEnd(topGoal);
          if (mounted) {
            setState(() {
              _swipingHorizontally = false;
              _horizontalExitLeft = false;
            });
          }
        });
      }
    }
    setState(_resetDrag);
  }

  void _startGoal(Goal goal) {
    final ok = _manager.startGoal(goal);
    if (ok) {
      // Podríamos disparar animación / feedback aquí.
      _showStartedMessage(goal.titulo);
    }
  }

  void _showStartedMessage(String titulo) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Meta en progreso: $titulo',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Kantumruy Pro',
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildDeck() {
    final active = _manager.activeGoals;
    if (active.isEmpty) {
      return Container(
        height: 340,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reemplazado icono por SVG 'direct'
            SizedBox(
              height: 40,
              width: 40, 
              
                child: SvgPicture.asset(
                  'assets/images/metas/direct.svg',
                  fit: BoxFit.contain,
                ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay metas recomendadas ahora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Las metas aparecerán aquí cuando tu psicólog@ o el sistema te las asigne. Próxima integración con base de datos :)).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.black54),
              ),
            )
          ],
        ),
      );
    }

    // Tomamos hasta las primeras 4 para mostrar en la pila (0 = top lógica)
    final visible = active.take(4).toList();

    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        // Dibujamos de atrás hacia adelante: los índices mayores (más lejos de 0) primero
        children: List.generate(visible.length, (paintIndex) {
          // paintIndex 0 -> fondo; necesitamos mapear a índice lógico
          final logicalIndex = visible.length - 1 - paintIndex; // 0 es top lógica
          final goal = visible[logicalIndex];
          final isTop = logicalIndex == 0;
          final depth = logicalIndex; // profundidad relativa (0 top)

          // Rotación base pseudo-aleatoria ligera
          final baseRotation = (goal.id.hashCode % 7 - 3) * 0.003; // -0.009..0.012
          final depthRotation = depth * 0.012; // más profunda, un pelín más rotación
          final rotation = baseRotation + depthRotation;

          // Offset vertical según profundidad
            final depthOffset = depth * 14.0;
          final scale = 1.0 - depth * 0.05; // escalado incremental

          // Arrastre sólo para la carta superior
          double dragPercent = (_dragDx / 240).clamp(-1.0, 1.0);
          final dragRotation = isTop ? dragPercent * 0.12 : 0.0;
          final dragTranslationX = isTop ? _dragDx : 0.0;
          // Permitimos que suba más (hasta -320px) para que se sienta libre y no “bloqueada”.
          final dragTranslationY = isTop ? _dragDy.clamp(-320.0, 0.0) : 0.0;
          // Progreso de inicio (0..1) según qué tanto subió la carta.
          final startProgress = isTop ? (-dragTranslationY / 320.0).clamp(0.0, 1.0) : 0.0;
          // Escala ligera al subir (reduce hasta 90%).
          final topScaleAdj = isTop ? (1 - (startProgress * 0.1)) : 1.0;

          Widget card = _GoalCard(
            goal: goal,
            isTop: isTop,
            hint: isTop ? 'Izq/Dcha explora  •  Arriba inicia' : null,
          );

          if (isTop) {
            Widget gestureWrapped = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: _swipingHorizontally ? null : _onDragUpdate,
              onPanEnd: (d) => _onDragEnd(d, goal),
              child: card,
            );
            // Animación de salida horizontal
            if (_swipingHorizontally) {
              final exitOffset = _horizontalExitLeft ? -MediaQuery.of(context).size.width : MediaQuery.of(context).size.width;
              gestureWrapped = AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: Offset(exitOffset / MediaQuery.of(context).size.width, 0),
                curve: Curves.easeIn,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: 0,
                  child: gestureWrapped,
                ),
              );
            }
            card = gestureWrapped;
          }

          return Positioned(
            top: depthOffset,
            child: Transform.translate(
              offset: Offset(dragTranslationX, dragTranslationY),
              child: Transform.scale(
                scale: scale * topScaleAdj,
                child: Opacity(
                  // Disminuye un poco la opacidad mientras sube (hasta 70%).
                  opacity: isTop ? (1 - startProgress * 0.3) : 1,
                  child: Transform.rotate(
                    angle: rotation + dragRotation,
                    child: card,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompleted() {
    final completed = _manager.completedGoals;
    if (completed.isEmpty) return const SizedBox.shrink();
    final recientes = completed.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, bottom: 8, top: 8),
          child: Text(
            'Completados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: recientes.map((g) => _CompletedChip(goal: g)).toList(),
          ),
        ),
        if (completed.length > 3)
          TextButton(
            onPressed: _showAllCompleted,
            child: Text('Ver todos (${completed.length})'),
          ),
      ],
    );
  }

  void _showAllCompleted() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metas completadas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: _manager.completedGoals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final g = _manager.completedGoals[i];
                      return _CompletedRow(goal: g.titulo, descripcion: g.descripcion, creada: g.creada);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const DropMenu(),
                const SizedBox(height: 10),
                const TitleSection(
                  texto: 'Tus metas de hoy',
                  maxLines: 2,
                  padding: EdgeInsets.only(top: 40, left: 24, right: 24),
                ),
                const SizedBox(height: 10),
                // Deck de metas
                _buildDeck(),
                const SizedBox(height: 10),
                _buildCompleted(),
                const SizedBox(height: 130), // espacio para el menú radial
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/metas.svg",
                ringColor: Colors.transparent,
                items: [
                  // IA (left)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IaScreen()),
                      );
                    },
                  ),
                  // Metas
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                   
                  ),
                  // Home (center of ring)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/house.svg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondPrincipalScreen(),
                        ),
                      );
                    },
                  ),
                  // Progreso
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {},
                  ),
                  // Psicólogos (right)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}

// --------- Widgets auxiliares ---------

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isTop;
  final String? hint;

  const _GoalCard({required this.goal, required this.isTop, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 330,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Fondo suave con gradiente
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE0E7FF),
                      const Color(0xFFFFFFFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          goal.titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Kantumruy Pro',
                          ),
                        ),
                      ),
                      if (isTop)
                        const SizedBox(width: 28), // reserva de espacio
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    goal.descripcion,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),
                  const Spacer(),
                  if (isTop && hint != null)
                    Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  final Goal goal;
  const _CompletedChip({required this.goal});

  @override
  Widget build(BuildContext context) {
    // Círculo grande tipo canica que contiene el texto (título) reducido.
    final title = goal.titulo.trim();
    int length = title.length;
    double fontSize;
    if (length <= 10) {
      fontSize = 14;
    } else if (length <= 16) {
      fontSize = 12;
    } else if (length <= 24) {
      fontSize = 11;
    } else {
      fontSize = 10; // muy largo
    }

    return Tooltip(
      message: title,
      triggerMode: TooltipTriggerMode.longPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: 92,
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFDCE4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: 'Kantumruy Pro',
            height: 1.1,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  final String goal;
  final String descripcion;
  final DateTime creada;
  const _CompletedRow({required this.goal, required this.descripcion, required this.creada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Kantumruy Pro',
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(creada),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
