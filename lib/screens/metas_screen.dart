import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/data/goals_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/state/app_state.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final GoalsManager _manager = GoalsManager.instance;
  double _dragDx = 0.0;
  double _dragDy = 0.0;
  bool _swipingHorizontally = false;
  bool _horizontalExitLeft = false;

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

  Future<void> _startGoal(Goal goal) async {
    _manager.startGoal(goal);
    if (!mounted) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final col = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('metas');

      final docId = goal.titulo.trim().toLowerCase();
      await col.doc(docId).set({
        'titulo': goal.titulo,
        'descripcion': goal.descripcion,
        'estado': 'en_progreso',
        'creada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _showStartedMessage(goal.titulo);
  }

  void _onDragEnd(DragEndDetails details, Goal topGoal) {
    const verticalThreshold = -120; // subir ≥ 120 px
    if (_dragDy < verticalThreshold) {
      _startGoal(topGoal);
    } else if (_dragDx.abs() > 140) {
      if (!_swipingHorizontally) {
        _horizontalExitLeft = _dragDx < 0;
        setState(() => _swipingHorizontally = true);
        Future.delayed(const Duration(milliseconds: 180), () {
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

  void _showStartedMessage(String titulo) {
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
            SizedBox(
              height: 40,
              width: 40,
              child: SvgPicture.asset('assets/images/metas/direct.svg',
                  fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            const Text('No hay metas recomendadas ahora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Las metas aparecerán aquí cuando tu psicólog@ te las asigne.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final visible = active.take(4).toList();

    return SizedBox(
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(visible.length, (paintIndex) {
          final logicalIndex = visible.length - 1 - paintIndex;
          final goal = visible[logicalIndex];
          final isTop = logicalIndex == 0;
          final depth = logicalIndex;

          final baseRotation = (goal.id.hashCode % 7 - 3) * 0.003;
          final depthRotation = depth * 0.012;
          final rotation = baseRotation + depthRotation;

          final depthOffset = depth * 14.0;
          final scale = 1.0 - depth * 0.05;

          double dragPercent = (_dragDx / 240).clamp(-1.0, 1.0);
          final dragRotation = isTop ? dragPercent * 0.12 : 0.0;
          final dragTranslationX = isTop ? _dragDx : 0.0;
          final dragTranslationY = isTop ? _dragDy.clamp(-320.0, 0.0) : 0.0;
          final startProgress =
              isTop ? (-dragTranslationY / 320.0).clamp(0.0, 1.0) : 0.0;
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

            if (_swipingHorizontally) {
              final exitOffset = _horizontalExitLeft
                  ? -MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width;
              gestureWrapped = AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: Offset(
                    exitOffset / MediaQuery.of(context).size.width, 0),
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
                  opacity: isTop ? (1 - startProgress * 0.3) : 1,
                  child: Transform.rotate(angle: rotation + dragRotation, child: card),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotesList() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text('Inicia sesión para ver tus metas.'),
      );
    }

    final query = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('metas')
        .where('estado', isEqualTo: 'pendiente')
        .orderBy('creada', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Error al cargar metas.'),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Aún no tienes metas por completar.'),
          );
        }

                return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>? ?? {};
            final titulo = (d['titulo'] ?? '').toString();
            final descripcion = (d['descripcion'] ?? '').toString();

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 130,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  await docs[i].reference.update({'estado': 'completada'});
                                  // Avanza flor: tick manual
                                  GoalsManager.instance.incrementProgressTick();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meta marcada como completada'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                label: const Text('Completar', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedChips() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final query = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('metas')
        .where('estado', isEqualTo: 'completada')
        .orderBy('creada', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || (snap.data?.docs ?? []).isEmpty) {
          return const SizedBox.shrink();
        }
        final docs = snap.data!.docs;
        // mostramos últimas 3 como chips (igual que tu look)
        final recent = docs.take(3).toList();

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
                children: recent.map((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  final titulo = (data['titulo'] ?? '').toString();
                  return _CompletedCircleChip(title: titulo);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---- BottomSheet agregar nota ----
  void _showAddNoteSheet() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Debes iniciar sesión.')));
      return;
    }

    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('+',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Kantumruy Pro')),
              const SizedBox(height: 12),
              ContainerLogin(
                width: double.infinity,
                height: 53,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Título (ej. Agradecimientos)',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText:
                        'Descripción (ej. Escribir 3 cosas por las que estoy agradecido)',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final titulo = tituloCtrl.text.trim();
                    final descripcion = descCtrl.text.trim();
                    if (titulo.isEmpty || descripcion.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Completa título y descripción.')),
                      );
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(uid)
                        .collection('metas')
                        .add({
                      'titulo': titulo,
                      'descripcion': descripcion,
                      'creada': FieldValue.serverTimestamp(),
                      'estado': 'pendiente',
                    });

                    if (mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Meta agregada')));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
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
                // botón add
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4, left: 24, right: 24, bottom: 8),
                  child: Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        height: 40,
                        child: CircularElevatedButton(
                          onPressed: _showAddNoteSheet,
                          child: SvgPicture.asset("assets/images/add.svg"),
                        ),
                      ),
                    ],
                  ),
                ),
                // 1) Sugeridas (deck)
                _buildDeck(),
                const SizedBox(height: 10),
                // 2) Notas por completar
                const Padding(
                  padding: EdgeInsets.only(left: 24, bottom: 8, top: 8),
                  child: Text(
                    'Notas por completar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
                _buildNotesList(),
                const SizedBox(height: 10),
                // 3) Completados (chips circulares como antes)
                _buildCompletedChips(),
                const SizedBox(height: 130),
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
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/ia.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IaScreen()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiarioScreen()),
                      );
                    },
                  ),
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
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Psicologos()),
                      );
                    },
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

// --------- Widgets auxiliares (sin tocar tu look) ---------

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
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE0E7FF), const Color(0xFFFFFFFF)],
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
                      if (isTop) const SizedBox(width: 28),
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

class _CompletedCircleChip extends StatelessWidget {
  final String title;
  const _CompletedCircleChip({required this.title});

  @override
  Widget build(BuildContext context) {
    final t = title.trim();
    final length = t.length;
    double fontSize;
    if (length <= 10) {
      fontSize = 14;
    } else if (length <= 16) {
      fontSize = 12;
    } else if (length <= 24) {
      fontSize = 11;
    } else {
      fontSize = 10;
    }

    return Tooltip(
      message: t,
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
            BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-2, -2)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          t,
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
