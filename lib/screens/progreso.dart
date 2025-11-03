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

class Progreso extends StatefulWidget {
  const Progreso({super.key});

  @override
  State<Progreso> createState() => _ProgresoState();
}

class _ProgresoState extends State<Progreso> {
  Map<EmotionType, int> _counts = {for (var t in EmotionType.values) t: 0};
  Map<int, EmotionType> _daily = const {};
  EmotionType? _most;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final counts = await EmotionJournal.instance.loadCounts(now);
    final daily = await EmotionJournal.instance.loadMonth(now);
    final most = await EmotionJournal.instance.mostFrequent(now);
    if (!mounted) return;
    setState(() {
      _counts = counts;
      _daily = daily;
      _most = most;
    });
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
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
                      _EmotionCalendarCard(daily: _daily),
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
                  // Metas
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
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
                  // Psicólogos (right)
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

    final maxVal = data.map((e) => e.value).fold<int>(0, (p, c) => c > p ? c : p);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE), // light blue
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...data.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _EmotionBarRow(datum: d, maxValue: maxVal),
              )),
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
  final Map<int, EmotionType> daily;
  const _EmotionCalendarCard({required this.daily});

  @override
  Widget build(BuildContext context) {
  final now = DateTime.now();
  final firstDay = DateTime(now.year, now.month, 1);
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon .. 7=Sun

    // daily is provided from persisted storage

    // Build a list of cells with leading blanks based on startWeekday (Mon-first)
    final leadingBlanks = (startWeekday - 1) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final displayCells = rows * 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF), // light purple
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
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: displayCells,
            itemBuilder: (context, index) {
              final dayNum = index - leadingBlanks + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final emo = daily[dayNum];
              final color = _colorForEmotion(emo);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
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
