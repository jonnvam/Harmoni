import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/core/responsive.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_application_1/state/app_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// Audio recording temporarily disabled until plugin mismatch is resolved.
import 'package:flutter_application_1/data/diary_repo.dart';
import 'package:intl/intl.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  // final _recorder = AudioRecorder();
  bool _isRecording = false; // UI state only while audio is disabled
  List<DiaryNote> _notes = [];
  final FocusNode _textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _titleCtrl.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await DiaryRepo.instance.listNotes();
    if (!mounted) return;
    setState(() => _notes = notes);
  }

  Future<void> _addTextNote() async {
    final content = _noteCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (content.isEmpty) {
      _textFocus.requestFocus();
      return;
    }
    final id = await DiaryRepo.nextId();
    final note = DiaryNote(
      id: id,
      date: DateTime.now(),
      type: DiaryNoteType.text,
      title: title.isEmpty ? 'Nota' : title,
      text: content,
    );
    await DiaryRepo.instance.addNote(note);
    _noteCtrl.clear();
    _titleCtrl.clear();
    await _loadNotes();
  }

  Future<void> _toggleRecord() async {
    // TODO: Re-enable using `record` plugin when dependency versions are aligned.
    // For now, just toggle UI and create a placeholder audio note without file.
    if (_isRecording) {
      setState(() => _isRecording = false);
      final id = await DiaryRepo.nextId();
      final title = _titleCtrl.text.trim();
      final note = DiaryNote(
        id: id,
        date: DateTime.now(),
        type: DiaryNoteType.audio,
        title: title.isEmpty ? 'Nota de audio' : title,
        filePath: null,
        text: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );
      await DiaryRepo.instance.addNote(note);
      _noteCtrl.clear();
      _titleCtrl.clear();
      await _loadNotes();
    } else {
      setState(() => _isRecording = true);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final id = await DiaryRepo.nextId();
      final title = _titleCtrl.text.trim();
      final note = DiaryNote(
        id: id,
        date: DateTime.now(),
        type: DiaryNoteType.image,
        title: title.isEmpty ? 'Imagen' : title,
        filePath: file.path,
        text: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );
      await DiaryRepo.instance.addNote(note);
      _noteCtrl.clear();
      _titleCtrl.clear();
      await _loadNotes();
    }
  }

  Future<void> _openEditNote(DiaryNote note) async {
    final titleCtrl = TextEditingController(text: note.title ?? '');
    final textCtrl = TextEditingController(text: note.text ?? '');
    String? imagePath = note.type == DiaryNoteType.image ? note.filePath : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(builder: (ctx, setModal) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Editar nota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Contenido', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(source: ImageSource.gallery);
                          if (file != null) {
                            setModal(() => imagePath = file.path);
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Agregar imagen'),
                      ),
                      const SizedBox(width: 8),
                      if (imagePath != null)
                        TextButton.icon(
                          onPressed: () => setModal(() => imagePath = null),
                          icon: const Icon(Icons.close),
                          label: const Text('Quitar imagen'),
                        ),
                    ],
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(imagePath!), height: 140, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await DiaryRepo.instance.deleteNote(note.id);
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          await _loadNotes();
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: const Text('Eliminar'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          final updated = DiaryNote(
                            id: note.id,
                            date: note.date,
                            type: imagePath != null ? DiaryNoteType.image : note.type,
                            title: titleCtrl.text.trim().isEmpty ? note.title : titleCtrl.text.trim(),
                            text: textCtrl.text.trim().isEmpty ? null : textCtrl.text.trim(),
                            filePath: imagePath,
                            emotionAsset: note.emotionAsset,
                          );
                          await DiaryRepo.instance.updateNote(updated);
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          await _loadNotes();
                        },
                        child: const Text('Guardar cambios'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
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
                DropMenu(),
                MaxWidthContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM', 'es_MX').format(DateTime.now()),
                            style: TextStyle(
                              fontFamily: 'Kantumruy Pro',
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      SevenDayCalendar(currentDate: DateTime.now()),

                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  top: 25,
                                ),
                                child: HolaNombre(
                                  style: TextStyles.textDiario,
                                  prefix: "Hola",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  top: 5,
                                ),
                                child: Text(
                                  "Tus pensamientos importan, regístralos aquí",
                                  style: TextStyles.textDiario2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 35),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Como te sientes
                              ContainerC2(
                                width: 290,
                                height: 95,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "¿Cómo te sientes hoy?",
                                            style: TextStyles.textDiario3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Registra tus emociones y pensamientos \npara seguir tu bienestar",
                                            style: TextStyles.textDiario4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              //Botones Laterales
                              ContainerC1(
                                width: 45,
                                height: 130,
                                child: SizedBox(
                                  width: 45,
                                  height: 130,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(height: 5),
                                      InkWell(
                                        onTap: _addTextNote,
                                        child: safeSvg(
                                          "assets/images/diario/edit.svg",
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _toggleRecord,
                                        child: safeSvg(
                                          "assets/images/diario/microphone-2.svg",
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _pickImage,
                                        child: safeSvg(
                                          "assets/images/diario/gallery.svg",
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Campo de texto para título y notas (sirve para texto y acompañar imagen)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: _titleCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Título',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Campo de texto para notas (sirve para texto y acompañar imagen)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              focusNode: _textFocus,
                              decoration: InputDecoration(
                                hintText: 'Escribe una nota...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          //Notas
                          SizedBox(height: 40),
                          ContainerC3(
                            width: 380,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    SizedBox(width: 35),
                                    Text(
                                      "Tus notas",
                                      style: TextStyles.textDiario5,
                                    ),
                                    SizedBox(width: 180),
                                    safeSvg(
                                      "assets/images/diario/calendar.svg",
                                      width: 30,
                                      height: 30,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Column(children: [ContenedorDiarioBuscar()]),
                                const SizedBox(height: 12),
                                _buildMonthlySections(),
                              ],
                            ),
                          ),

                          // Row(children: [Column()]),
                        ],
                      ),
                    ],
                    ),
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
                currentIconAsset: "assets/images/icon/diario.svg",
                ringColor: Colors.transparent,
                items: [
                  // IA (left)
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

extension on DateTime {
  String get monthKey => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}

Widget _monthHeader(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  );
}

String _formatMonthES(DateTime d) {
  // Simple mapa en español para evitar issues de locales
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return '${meses[d.month - 1]} ${d.year}';
}

extension _DiarioGroups on _DiarioScreenState {
  Widget _buildMonthlySections() {
    if (_notes.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: Text('Sin notas aún.')));
    }

    // Agrupar por mes
    final Map<String, List<DiaryNote>> groups = {};
    for (final n in _notes) {
      final key = n.date.monthKey;
      groups.putIfAbsent(key, () => []).add(n);
    }
    // Ordenar por mes desc
    final keys = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in keys) ...[
          _monthHeader(_formatMonthES(DateTime.parse('$key-01'))),
          SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: groups[key]!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final n = groups[key]![i];
                return GestureDetector(
                  onTap: () => _openEditNote(n),
                  child: ContainerDiarioWhite(
                    height: 108,
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  (n.title ?? '').isEmpty ? 'Sin título' : n.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (n.emotionAsset != null && n.emotionAsset!.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(left: 6),
                                  child: SvgPicture.asset(
                                    n.emotionAsset!,
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Expanded(child: _NotePreview(note: n)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

Widget safeSvg(String path, {double? width, double? height}) {
  try {
    return SvgPicture.asset(path, width: width, height: height);
  } catch (e) {
    return Icon(Icons.error, color: Colors.red);
  }
}

class _NotePreview extends StatelessWidget {
  final DiaryNote note;
  const _NotePreview({required this.note});

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (note.type) {
      case DiaryNoteType.text:
        content = Text(
          note.text ?? '',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            height: 1.25,
            color: Colors.black87,
          ),
        );
        break;
      case DiaryNoteType.image:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.file(
                File(note.filePath ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
            if (note.text != null && note.text!.isNotEmpty)
              Text(
                note.text!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.2),
              ),
          ],
        );
        break;
      case DiaryNoteType.audio:
        content = Row(
          children: const [
            Icon(Icons.mic, size: 18),
            SizedBox(width: 6),
            Expanded(child: Text('Nota de audio', style: TextStyle(fontSize: 12, color: Colors.black87))),
          ],
        );
        break;
    }
    return content;
  }
}
