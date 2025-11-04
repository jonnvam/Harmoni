import 'package:flutter/material.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/core/app_colors.dart';

class PhqGadTestScreen extends StatefulWidget {
  const PhqGadTestScreen({super.key});

  @override
  State<PhqGadTestScreen> createState() => _PhqGadTestScreenState();
}

class _PhqGadTestScreenState extends State<PhqGadTestScreen> {
  final _phq9 = const [
    'Poco interés o placer en hacer cosas',
    'Se ha sentido desanimado/a, deprimido/a o sin esperanzas',
    'Dificultad para conciliar el sueño o quedarse dormido/a, o dormir demasiado',
    'Se ha sentido cansado/a o con poca energía',
    'Poco apetito o comer en exceso',
    'Se ha sentido mal consigo mismo/a – o que es un/a fracasado/a o que ha quedado mal consigo mismo/a o su familia',
    'Dificultad para concentrarse en cosas, como leer el periódico o ver la televisión',
    'Se ha movido o hablado tan lentamente que otras personas lo han notado o lo contrario, ha estado tan inquieto/a o agitado/a que se ha estado moviendo mucho más de lo habitual',
    'Pensamientos de que estaría mejor muerto/a o de lastimarse de alguna manera',
  ];

  final _gad7 = const [
    'Sentirse nervioso/a, ansioso/a, o al límite',
    'No poder parar o controlar la preocupación',
    'Preocuparse demasiado por diferentes cosas',
    'Dificultad para relajarse',
    'Estar tan inquieto/a que es difícil quedarse quieto/a',
    'Enojarse o irritarse fácilmente',
    'Sentir miedo como si algo terrible fuese a pasar',
  ];

  // 0-3 por ítem
  final List<int?> _phqAnswers = List<int?>.filled(9, null);
  final List<int?> _gadAnswers = List<int?>.filled(7, null);
  int _step = 0; // 0 = PHQ, 1 = GAD

  static const _choices = [
    'Nunca (0)',
    'Varios días (1)',
    'Más de la mitad de los días (2)',
    'Casi todos los días (3)',
  ];

  bool get _currentSectionComplete {
    final list = _step == 0 ? _phqAnswers : _gadAnswers;
    return list.every((e) => e != null);
  }

  int _sum(List<int?> xs) => xs.fold(0, (a, b) => a + (b ?? 0));

  Future<void> _finish() async {
    final phqScore = _sum(_phqAnswers);
    final gadScore = _sum(_gadAnswers);
    // Mostrar resultados brevemente
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resultados'),
        content: Text('PHQ-9: $phqScore\nGAD-7: $gadScore'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    // Por hacer: Guardar resultados en backend/Firestore si aplica
    await AppState.instance.setTestCompleted(true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SecondPrincipalScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _step == 0 ? _phq9 : _gad7;
    final answers = _step == 0 ? _phqAnswers : _gadAnswers;
    final title = _step == 0 ? 'PHQ-9 (Depresión)' : 'GAD-7 (Ansiedad)';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.fondo3,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(questions[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  for (var val = 0; val < 4; val++)
                    RadioListTile<int>(
                      value: val,
                      groupValue: answers[index],
                      onChanged: (v) => setState(() => answers[index] = v),
                      title: Text(_choices[val]),
                      dense: true,
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              if (_step == 1)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step = 0),
                    child: const Text('Atrás'),
                  ),
                ),
              if (_step == 1) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.fondo3),
                  onPressed: !_currentSectionComplete
                      ? null
                      : () {
                          if (_step == 0) {
                            setState(() => _step = 1);
                          } else {
                            _finish();
                          }
                        },
                  child: Text(_step == 0 ? 'Siguiente' : 'Finalizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
