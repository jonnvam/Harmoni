import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/data/emotion_journal.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/services/progress_emotion_service.dart';
import 'package:flutter_application_1/core/app_colors.dart';

class Progreso extends StatefulWidget {
  const Progreso({super.key});

  @override
  State<Progreso> createState() => _ProgresoState();
}

class _ProgresoState extends State<Progreso> {
  Map<EmotionType, int> _counts = {
    for (final emotion in EmotionType.values) emotion: 0,
  };
  Map<int, Map<EmotionType, int>> _daily = const {};
  EmotionType? _most;

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final progress = await ProgressEmotionService.instance.loadForDate(
        _selectedMonth,
      );

      if (!mounted) return;

      setState(() {
        _counts = progress.counts;
        _daily = progress.daily;
        _most = progress.mostFrequent;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar tu progreso emocional: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });

    _load();
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );

    if (nextMonth.isAfter(currentMonth)) {
      return;
    }

    setState(() {
      _selectedMonth = nextMonth;
    });

    _load();
  }

  bool get _canGoNextMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );

    return !nextMonth.isAfter(currentMonth);
  }

  String _monthTitle(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content (no top bar per request)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropMenu(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonthSelector(
                        title: _monthTitle(_selectedMonth),
                        canGoNext: _canGoNextMonth,
                        onPrevious: _goToPreviousMonth,
                        onNext: _goToNextMonth,
                      ),

                      const SizedBox(height: 18),
                      // Lotus flower centered
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(
                            'assets/animations/flower.json',
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Most frequent emotion
                      Text(
                        _most == null ? '—' : _emotionLabel(_most!),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Emoción más frecuente',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      if (_loading) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Color(0xFFE5E7EB),
                          color: AppColors.primary,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Emotion bars card
                      _EmotionBarsCard(counts: _counts),

                      const SizedBox(height: 28),
                      const Text(
                        'Calendario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _EmotionCalendarCard(
                        daily: _daily,
                        month: _selectedMonth,
                      ),
                      const SizedBox(height: 100), // space above radial menu
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
                currentIconAsset: "assets/images/icon/progreso.svg",
                ringColor: Colors.transparent,
                items: [
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
                  // Metas
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
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
                        MaterialPageRoute(builder: (context) => MetasScreen()),
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
                  // Psicólogos (right)
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
                        MaterialPageRoute(builder: (context) => Psicologos()),
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

/// Selector de mes
class _MonthSelector extends StatelessWidget {
  final String title;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.title,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _MonthArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrevious,
            enabled: true,
          ),

          Expanded(
            child: Column(
              children: [
                const Text(
                  'Progreso emocional',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          _MonthArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            enabled: canGoNext,
          ),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _MonthArrowButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFFEEF2FF) : const Color(0xFFF1F5F9),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          icon,
          size: 26,
          color: enabled ? AppColors.primary : Colors.black26,
        ),
      ),
    );
  }
}

// --- Emotion Bars Card ---

class _EmotionBarsCard extends StatelessWidget {
  final Map<EmotionType, int> counts;
  const _EmotionBarsCard({required this.counts});

  @override
  Widget build(BuildContext context) {
    final data = <_EmotionDatum>[
      _EmotionDatum(
        label: 'Felicidad',
        value: counts[EmotionType.happy] ?? 0,
        color: const Color(0xFFFFD54F),
        iconAsset: 'assets/images/emotions/Feliz.svg',
      ),
      _EmotionDatum(
        label: 'Tristeza',
        value: counts[EmotionType.sad] ?? 0,
        color: const Color(0xFF60A5FA),
        iconAsset: 'assets/images/emotions/Triste.svg',
      ),
      _EmotionDatum(
        label: 'Enojo',
        value: counts[EmotionType.angry] ?? 0,
        color: const Color(0xFFEF4444),
        iconAsset: 'assets/images/emotions/Enojado.svg',
      ),
      _EmotionDatum(
        label: 'Sorpresa',
        value: counts[EmotionType.surprised] ?? 0,
        color: const Color(0xFF8B5CF6),
        iconAsset: 'assets/images/emotions/Sorpresa.svg',
      ),
      _EmotionDatum(
        label: 'Miedo',
        value: counts[EmotionType.fear] ?? 0,
        color: const Color(0xFF34D399),
        iconAsset: 'assets/images/emotions/Miedo.svg',
      ),
    ];

    final maxVal = data
        .map((e) => e.value)
        .fold<int>(0, (p, c) => c > p ? c : p);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x68A5B4FC), //
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...data.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _EmotionBarRow(datum: d, maxValue: maxVal),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionDatum {
  final String label;
  final int value;
  final Color color;
  final String iconAsset;
  const _EmotionDatum({
    required this.label,
    required this.value,
    required this.color,
    required this.iconAsset,
  });
}

class _EmotionBarRow extends StatelessWidget {
  final _EmotionDatum datum;
  final int maxValue;
  const _EmotionBarRow({required this.datum, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 34,
          child: Text(
            '${datum.value}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barMaxW = constraints.maxWidth;
              final fraction = maxValue == 0 ? 0.0 : (datum.value / maxValue);
              final barW = barMaxW * fraction.clamp(0, 1);
              return Stack(
                children: [
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: datum.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    width: barW,
                    height: 18,
                    decoration: BoxDecoration(
                      color: datum.color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        SvgPicture.asset(datum.iconAsset, width: 28, height: 28),
      ],
    );
  }
}

// --- Emotion Calendar Card ---

class _EmotionCalendarCard extends StatelessWidget {
  final Map<int, Map<EmotionType, int>> daily;
  final DateTime month;
  const _EmotionCalendarCard({required this.daily, required this.month});

  String _iconForEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return 'assets/images/emotions/Feliz.svg';
      case EmotionType.sad:
        return 'assets/images/emotions/Triste.svg';
      case EmotionType.angry:
        return 'assets/images/emotions/Enojado.svg';
      case EmotionType.surprised:
        return 'assets/images/emotions/Sorpresa.svg';
      case EmotionType.fear:
        return 'assets/images/emotions/Miedo.svg';
    }
  }

  void _showDayEmotionDetailsDialog(
    BuildContext context, {
    required int day,
    required Map<EmotionType, int> emotions,
  }) {
    final selected = month;

    final entries =
        emotions.entries.where((entry) => entry.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);

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
                        Icons.calendar_month_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Día $day de ${_monthName(selected.month)}',
                        style: const TextStyle(
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
                          color: const Color(0xFFEEF2FF),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  entries.isEmpty
                      ? 'No registraste emociones este día.'
                      : total == 1
                      ? 'Registraste 1 emoción este día.'
                      : 'Registraste $total emociones este día.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontFamily: 'Kantumruy Pro',
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                if (entries.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEEF2FF),
                          ),
                          child: const Icon(
                            Icons.self_improvement_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Sin registros emocionales',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Cuando registres cómo te sientes, aquí aparecerá el resumen de ese día.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            fontFamily: 'Kantumruy Pro',
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 14),

                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(ctx);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DiarioScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFDCE4FF),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Ir al diario',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Kantumruy Pro',
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...entries.map((entry) {
                    final emotion = entry.key;
                    final count = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DayEmotionRow(
                        iconAsset: _iconForEmotion(emotion),
                        label: _emotionLabel(emotion),
                        count: count,
                        color: _colorForEmotion(emotion),
                      ),
                    );
                  }),

                const SizedBox(height: 12),

                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
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

  String _monthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon .. 7=Sun

    // daily is provided from persisted storage

    // Build a list of cells with leading blanks based on startWeekday (Mon-first)
    final leadingBlanks = (startWeekday - 1) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final displayCells = rows * 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x72E0E7FF), // light purple
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Weekday headers (Mon-Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeekdayLabel('L'),
              _WeekdayLabel('M'),
              _WeekdayLabel('M'),
              _WeekdayLabel('J'),
              _WeekdayLabel('V'),
              _WeekdayLabel('S'),
              _WeekdayLabel('D'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 0.72,
            ),
            itemCount: displayCells,
            itemBuilder: (context, index) {
              final dayNum = index - leadingBlanks + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final emotionsForDay =
                  daily[dayNum] ?? const <EmotionType, int>{};

              final uniqueEmotions =
                  emotionsForDay.entries
                      .where((entry) => entry.value > 0)
                      .map((entry) => entry.key)
                      .toList();

              final visibleDots = uniqueEmotions.take(2).toList();
              final extraCount = uniqueEmotions.length - visibleDots.length;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    _showDayEmotionDetailsDialog(
                      context,
                      day: dayNum,
                      emotions: emotionsForDay,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            emotionsForDay.isEmpty
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFFDCE4FF),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Kantumruy Pro',
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (visibleDots.isEmpty)
                            Container(
                              width: 11,
                              height: 11,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE5E7EB),
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            SizedBox(
                              height: 20,
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...visibleDots.map((emotion) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _colorForEmotion(emotion),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    }),

                                    if (extraCount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 3),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFDCE4FF),
                                          ),
                                        ),
                                        child: Text(
                                          '+$extraCount',
                                          style: const TextStyle(
                                            fontSize: 8,
                                            fontFamily: 'Kantumruy Pro',
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _colorForEmotion(EmotionType? t) {
    switch (t) {
      case EmotionType.happy:
        return const Color(0xFFFFD54F);
      case EmotionType.sad:
        return const Color(0xFF60A5FA);
      case EmotionType.angry:
        return const Color(0xFFEF4444);
      case EmotionType.surprised:
        return const Color(0xFF8B5CF6);
      case EmotionType.fear:
        return const Color(0xFF34D399);
      default:
        return const Color(0xFFE5E7EB);
    }
  }
}

class _DayEmotionRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final int count;
  final Color color;

  const _DayEmotionRow({
    required this.iconAsset,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = count == 1 ? '1 registro' : '$count registros';

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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
            ),
            child: Center(
              child: SvgPicture.asset(iconAsset, width: 24, height: 24),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Kantumruy Pro',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _emotionLabel(EmotionType t) {
  switch (t) {
    case EmotionType.happy:
      return 'Feliz';
    case EmotionType.sad:
      return 'Triste';
    case EmotionType.angry:
      return 'Enojo';
    case EmotionType.surprised:
      return 'Sorpresa';
    case EmotionType.fear:
      return 'Miedo';
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
