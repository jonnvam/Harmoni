import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_svg/svg.dart';
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
    if (content.isEmpty) {
      _textFocus.requestFocus();
      return;
    }
    final id = await DiaryRepo.nextId();
    final note = DiaryNote(
      id: id,
      date: DateTime.now(),
      type: DiaryNoteType.text,
      text: content,
    );
    await DiaryRepo.instance.addNote(note);
    _noteCtrl.clear();
    await _loadNotes();
  }

  Future<void> _toggleRecord() async {
    // TODO: Re-enable using `record` plugin when dependency versions are aligned.
    // For now, just toggle UI and create a placeholder audio note without file.
    if (_isRecording) {
      setState(() => _isRecording = false);
      final id = await DiaryRepo.nextId();
      final note = DiaryNote(
        id: id,
        date: DateTime.now(),
        type: DiaryNoteType.audio,
        filePath: null,
        text: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );
      await DiaryRepo.instance.addNote(note);
      _noteCtrl.clear();
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
      final note = DiaryNote(
        id: id,
        date: DateTime.now(),
        type: DiaryNoteType.image,
        filePath: file.path,
        text: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );
      await DiaryRepo.instance.addNote(note);
      _noteCtrl.clear();
      await _loadNotes();
    }
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
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
                            height: 250,
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
                                // Lista simple de notas
                                SizedBox(
                                  height: 120,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, i) {
                                      final n = _notes[i];
                                      return ContainerDiarioWhite(
                                        height: 108,
                                        width: 134,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _NotePreview(note: n),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                                    itemCount: _notes.length,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Row(children: [Column()]),
                        ],
                      ),
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
                currentIconAsset: "assets/images/icon/diario.svg",
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
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
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
                    onTap: () {},
                  ),
                  // Psicólogos (right)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {
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
    switch (note.type) {
      case DiaryNoteType.text:
        return Text(
          note.text ?? '',
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        );
      case DiaryNoteType.image:
        return Column(
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
                style: const TextStyle(fontSize: 11),
              ),
          ],
        );
      case DiaryNoteType.audio:
        return Row(
          children: const [
            Icon(Icons.mic, size: 18),
            SizedBox(width: 6),
            Expanded(child: Text('Nota de audio', style: TextStyle(fontSize: 12))),
          ],
        );
    }
  }
}
