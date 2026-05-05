import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/data/goals_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/services/goals_firestore_service.dart';
import 'package:flutter_application_1/core/app_colors.dart';

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
  bool _lockScrollForDeck = false;

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

  void _setDeckScrollLock(bool value) {
    if (!mounted) return;
    if (_lockScrollForDeck == value) return;

    setState(() {
      _lockScrollForDeck = value;
    });
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

    try {
      await GoalsFirestoreService.instance.startRecommendedGoal(goal);

      if (!mounted) return;

      _showStartedMessage(goal.titulo);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo iniciar la meta: $e')));
    }
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
    _setDeckScrollLock(false);
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

  String _formatGoalDate(dynamic value) {
    if (value == null) return 'Sin fecha límite';

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) return 'Sin fecha límite';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _priorityLabel(String value) {
    switch (value.toLowerCase()) {
      case 'baja':
        return 'Baja';
      case 'alta':
        return 'Alta';
      case 'media':
      default:
        return 'Media';
    }
  }

  String _sourceLabel(String value) {
    switch (value.toLowerCase()) {
      case 'recommended':
        return 'Recomendada';
      case 'manual':
        return 'Manual';
      default:
        return 'No especificado';
    }
  }

  String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'completada':
        return 'Completada';
      case 'en_progreso':
      default:
        return 'En progreso';
    }
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

    final screenH = MediaQuery.of(context).size.height;
    final deckHeight =
        screenH.clamp(640, 900) == screenH
            ? 360.0
            : (screenH * 0.48).clamp(340.0, 360.0);
    return SizedBox(
      height: deckHeight,
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
            Widget gestureWrapped = Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) {
                _setDeckScrollLock(true);
              },
              onPointerUp: (_) {
                _setDeckScrollLock(false);
              },
              onPointerCancel: (_) {
                _setDeckScrollLock(false);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  _setDeckScrollLock(true);
                },
                onPanUpdate: _swipingHorizontally ? null : _onDragUpdate,
                onPanEnd: (d) {
                  _onDragEnd(d, goal);
                  _setDeckScrollLock(false);
                },
                onPanCancel: () {
                  setState(_resetDrag);
                  _setDeckScrollLock(false);
                },
                child: card,
              ),
            );

            if (_swipingHorizontally) {
              final exitOffset =
                  _horizontalExitLeft
                      ? -MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width;
              gestureWrapped = AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: Offset(
                  exitOffset / MediaQuery.of(context).size.width,
                  0,
                ),
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

  Widget _buildNotesList() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text('Inicia sesión para ver tus metas.'),
      );
    }

    final query = GoalsFirestoreService.instance.metasPorEstadoQuery(
      uid: uid,
      estado: 'en_progreso',
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            final d = docs[i].data();

            final titulo = (d['titulo'] ?? '').toString();
            final descripcion = (d['descripcion'] ?? '').toString();

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showGoalDetailsDialog(d),
                child: Container(
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
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

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 115,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  _showEditGoalSheet(
                                    goalRef: docs[i].reference,
                                    data: d,
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined, size: 17),
                                label: const Text(
                                  'Editar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Kantumruy Pro',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            SizedBox(
                              width: 130,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  try {
                                    await GoalsFirestoreService.instance
                                        .completeGoal(
                                          goalRef: docs[i].reference,
                                        );

                                    GoalsManager.instance
                                        .incrementProgressTick();

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Meta marcada como completada',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo completar la meta: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Completar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

    final query = GoalsFirestoreService.instance.metasPorEstadoQuery(
      uid: uid,
      estado: 'completada',
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Error al cargar metas completadas.'),
          );
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) return const SizedBox.shrink();

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
                children:
                    recent.map((d) {
                      final data = d.data();
                      final titulo = (data['titulo'] ?? '').toString();
                      return _CompletedCircleChip(title: titulo);
                    }).toList(),
              ),
            ),
            if (docs.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 6),
                child: GestureDetector(
                  onTap: () => _showAllCompletedBottomSheet(docs),
                  child: const Text(
                    'ver más',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Agrega este helper debajo (abre un bottom sheet con todos los chips)
  void _showAllCompletedBottomSheet(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text(
                    'Metas completadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            docs.map((d) {
                              final data = d.data();
                              final titulo = (data['titulo'] ?? '').toString();
                              return _CompletedCircleChip(title: titulo);
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- BottomSheet agregar nota ----
  void _showAddNoteSheet() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión.')));
      return;
    }

    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? fechaLimite;
    String prioridad = 'media';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final messenger = ScaffoldMessenger.of(context);
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nueva meta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kantumruy Pro',
                      ),
                    ),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: now,
                                firstDate: now.subtract(
                                  const Duration(days: 0),
                                ),
                                lastDate: now.add(const Duration(days: 365)),
                              );
                              if (picked != null)
                                setModal(() => fechaLimite = picked);
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              fechaLimite == null
                                  ? 'Fecha límite (opcional)'
                                  : '${fechaLimite!.day.toString().padLeft(2, '0')}/${fechaLimite!.month.toString().padLeft(2, '0')}/${fechaLimite!.year}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prioridad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (final p in ['baja', 'media', 'alta'])
                          ChoiceChip(
                            label: Text(p[0].toUpperCase() + p.substring(1)),
                            selected: prioridad == p,
                            onSelected: (_) => setModal(() => prioridad = p),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final titulo = tituloCtrl.text.trim();
                          final descripcion = descCtrl.text.trim();

                          if (titulo.isEmpty || descripcion.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Completa título y descripción.'),
                              ),
                            );
                            return;
                          }

                          try {
                            await GoalsFirestoreService.instance
                                .createManualGoal(
                                  titulo: titulo,
                                  descripcion: descripcion,
                                  prioridad: prioridad,
                                  fechaLimite: fechaLimite,
                                );

                            if (!context.mounted) return;

                            Navigator.of(ctx).pop();

                            messenger.showSnackBar(
                              const SnackBar(content: Text('Meta agregada')),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('No se pudo agregar la meta: $e'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Guardar'),
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

  void _showEditGoalSheet({
    required DocumentReference<Map<String, dynamic>> goalRef,
    required Map<String, dynamic> data,
  }) {
    final tituloCtrl = TextEditingController(
      text: (data['titulo'] ?? '').toString(),
    );

    final descCtrl = TextEditingController(
      text: (data['descripcion'] ?? '').toString(),
    );

    DateTime? fechaLimite;
    final rawFecha = data['fechaLimite'];

    if (rawFecha is Timestamp) {
      fechaLimite = rawFecha.toDate();
    }

    String prioridad = (data['prioridad'] ?? 'media').toString();

    if (!['baja', 'media', 'alta'].contains(prioridad)) {
      prioridad = 'media';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final messenger = ScaffoldMessenger.of(context);

        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar meta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kantumruy Pro',
                      ),
                    ),

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
                            hintText: 'Título',
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
                          hintText: 'Descripción',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();

                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: fechaLimite ?? now,
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 365)),
                              );

                              if (picked != null) {
                                setModal(() => fechaLimite = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              fechaLimite == null
                                  ? 'Fecha límite opcional'
                                  : '${fechaLimite!.day.toString().padLeft(2, '0')}/${fechaLimite!.month.toString().padLeft(2, '0')}/${fechaLimite!.year}',
                            ),
                          ),
                        ),

                        if (fechaLimite != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Quitar fecha',
                            onPressed: () {
                              setModal(() => fechaLimite = null);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Prioridad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 10,
                      children: [
                        for (final p in ['baja', 'media', 'alta'])
                          ChoiceChip(
                            label: Text(p[0].toUpperCase() + p.substring(1)),
                            selected: prioridad == p,
                            selectedColor: const Color(0xFFEEF2FF),
                            onSelected: (_) {
                              setModal(() => prioridad = p);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              final titulo = tituloCtrl.text.trim();
                              final descripcion = descCtrl.text.trim();

                              if (titulo.isEmpty || descripcion.isEmpty) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Completa título y descripción.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                await GoalsFirestoreService.instance.updateGoal(
                                  goalRef: goalRef,
                                  titulo: titulo,
                                  descripcion: descripcion,
                                  prioridad: prioridad,
                                  fechaLimite: fechaLimite,
                                );

                                if (!context.mounted) return;

                                Navigator.of(ctx).pop();

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Meta actualizada'),
                                  ),
                                );
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No se pudo actualizar la meta: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Guardar'),
                          ),
                        ),
                      ],
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

  void _showGoalDetailsDialog(Map<String, dynamic> data) {
    final titulo = (data['titulo'] ?? 'Sin título').toString();
    final descripcion = (data['descripcion'] ?? 'Sin descripción').toString();
    final prioridad = _priorityLabel((data['prioridad'] ?? 'media').toString());
    final fechaLimite = _formatGoalDate(data['fechaLimite']);
    final estado = _statusLabel((data['estado'] ?? 'en_progreso').toString());
    final origen = _sourceLabel((data['source'] ?? '').toString());

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEEF2FF),
                      ),
                      child: const Icon(
                        Icons.flag_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Detalle de meta',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Kantumruy Pro',
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1.1,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                _GoalDetailRow(
                  icon: Icons.priority_high_rounded,
                  label: 'Prioridad',
                  value: prioridad,
                ),

                const SizedBox(height: 10),

                _GoalDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha límite',
                  value: fechaLimite,
                ),

                const SizedBox(height: 10),

                _GoalDetailRow(
                  icon: Icons.timeline_rounded,
                  label: 'Estado',
                  value: estado,
                ),

                const SizedBox(height: 10),

                _GoalDetailRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Origen',
                  value: origen,
                ),

                const SizedBox(height: 22),

                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 147, 148, 235),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A6366F1),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Kantumruy Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
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
            physics:
                _lockScrollForDeck
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
            child: Column(
              children: [
                const DropMenu(),
                MaxWidthContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      // Header: título + botón Agregar (alineado a la derecha)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Tus metas de hoy',
                                style: TextStyles.tituloMotivacional,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                maxWidth: 140,
                              ),
                              child: OutlinedButton.icon(
                                onPressed: _showAddNoteSheet,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  'Agregar',
                                  style: TextStyle(fontSize: 14),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  foregroundColor: const Color(0xFF111827),
                                ),
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
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Text(
                          'Metas por completar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
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
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
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
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
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
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Progreso()),
                      );
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Completa el test inicial para desbloquear esta sección.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Psicologos(),
                        ),
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xD8E0E7FF), const Color(0xFFFFFFFF)],
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

class _GoalDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GoalDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEF2FF),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(-2, -2),
            ),
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
