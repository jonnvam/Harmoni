import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/ia_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_application_1/state/app_state.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  final _textFocus = FocusNode();
  final _picker    = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  /// Referencia a la subcolección de notas del usuario actual.
  CollectionReference<Map<String, dynamic>>? _notesCol() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('notas');
  }

  /// Sube una imagen a Storage y devuelve su URL pública.
  Future<String> _uploadImageToStorage({
    required String uid,
    required String docId,
    required File file,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('usuarios')
        .child(uid)
        .child('diario')
        .child('$docId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Agregar nota de texto.
  Future<void> _addTextNote() async {
    final col = _notesCol();
    if (col == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión.')),
      );
      return;
    }
    final texto = _noteCtrl.text.trim();
    if (texto.isEmpty) {
      _textFocus.requestFocus();
      return;
    }
    final titulo = _titleCtrl.text.trim().isEmpty ? 'Nota' : _titleCtrl.text.trim();

    await col.add({
      'titulo': titulo,
      'texto': texto,
      'tipo': 'texto',
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _titleCtrl.clear();
    _noteCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota guardada')),
    );
  }

  /// Agregar nota con imagen (opcionalmente acompañada de texto).
  Future<void> _pickImage() async {
    final col = _notesCol();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (col == null || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión.')),
      );
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Crea doc primero para usar su id como nombre del archivo en Storage.
    final tempDoc = await col.add({
      'titulo': _titleCtrl.text.trim().isEmpty ? 'Imagen' : _titleCtrl.text.trim(),
      'texto':  _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      'tipo':   'imagen',
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      final url = await _uploadImageToStorage(
        uid: uid,
        docId: tempDoc.id,
        file: File(picked.path),
      );
      await tempDoc.update({'imageUrl': url});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen guardada en tu diario')),
      );
    } catch (e) {
      // Si falla la subida, borra el doc vacío.
      await tempDoc.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir imagen')),
      );
    } finally {
      _titleCtrl.clear();
      _noteCtrl.clear();
    }
  }

  // ---------- Editar / eliminar ----------
  Future<void> _openEditNote(
    String docId, {
    required String? titulo,
    required String? texto,
    required String tipo,
    required String? imageUrl,
  }) async {
    final col = _notesCol();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (col == null || uid == null) return;

    final titleCtrl = TextEditingController(text: titulo ?? '');
    final textCtrl  = TextEditingController(text: texto ?? '');
    String? newImageUrl = imageUrl;

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
                          final picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            final file = File(picked.path);
                            final url  = await _uploadImageToStorage(uid: uid, docId: docId, file: file);
                            setModal(() => newImageUrl = url);
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Agregar / reemplazar imagen'),
                      ),
                      const SizedBox(width: 8),
                      if (newImageUrl != null)
                        TextButton.icon(
                          onPressed: () => setModal(() => newImageUrl = null),
                          icon: const Icon(Icons.close),
                          label: const Text('Quitar imagen'),
                        ),
                    ],
                  ),
                  if (newImageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        newImageUrl!,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await col.doc(docId).delete();
                          if ((newImageUrl ?? imageUrl) != null) {
                            try {
                              await FirebaseStorage.instance
                                  .refFromURL(newImageUrl ?? imageUrl!)
                                  .delete();
                            } catch (_) {}
                          }
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nota eliminada')),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: const Text('Eliminar'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          await col.doc(docId).update({
                            'titulo': titleCtrl.text.trim().isEmpty ? (titulo ?? 'Nota') : titleCtrl.text.trim(),
                            'texto' : textCtrl.text.trim().isEmpty ? null : textCtrl.text.trim(),
                            'tipo'  : (newImageUrl != null)
                                ? 'imagen'
                                : (tipo == 'imagen' && newImageUrl == null ? 'texto' : tipo),
                            'imageUrl': newImageUrl,
                          });
                          if (!mounted) return;
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cambios guardados')),
                          );
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
                const DropMenu(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mes actual
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM', 'es_MX').format(DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Kantumruy Pro',
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SevenDayCalendar(currentDate: DateTime.now()),

                      // Saludo + subtítulo
                      Column(
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 25),
                                child: HolaNombre(
                                  style: TextStyles.textDiario,
                                  prefix: "Hola",
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 5),
                                child: Text(
                                  "Tus pensamientos importan, regístralos aquí",
                                  style: TextStyles.textDiario2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // Caja ¿Cómo te sientes hoy? + botones laterales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ContainerC2(
                            width: 290,
                            height: 95,
                            child: const Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Text("¿Cómo te sientes hoy?", style: TextStyles.textDiario3),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
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
                          const SizedBox(width: 5),
                          ContainerC1(
                            width: 45,
                            height: 130,
                            child: SizedBox(
                              width: 45,
                              height: 130,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(height: 5),
                                  InkWell(
                                    onTap: _addTextNote,
                                    child: safeSvg("assets/images/diario/edit.svg", width: 30, height: 30),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Grabación de audio deshabilitada por ahora.')),
                                      );
                                    },
                                    child: safeSvg("assets/images/diario/microphone-2.svg", width: 30, height: 30),
                                  ),
                                  InkWell(
                                    onTap: _pickImage,
                                    child: safeSvg("assets/images/diario/gallery.svg", width: 30, height: 30),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Título + contenido
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _titleCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Título (opcional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _noteCtrl,
                          maxLines: 3,
                          focusNode: _textFocus,
                          decoration: InputDecoration(
                            hintText: 'Escribe una nota...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),

                      // Listado de notas
                      const SizedBox(height: 40),
                      ContainerC3(
                        width: 380,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const SizedBox(width: 35),
                                const Text("Tus notas", style: TextStyles.textDiario5),
                                const Spacer(),
                                safeSvg("assets/images/diario/calendar.svg", width: 30, height: 30),
                                const SizedBox(width: 16),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Column(children: [ContenedorDiarioBuscar()]),
                            const SizedBox(height: 12),
                            _MonthlyNotesStream(onOpenEdit: _openEditNote),
                          ],
                        ),
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menú radial inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/diario.svg",
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => IaScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/metas.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
//
                        );
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MetasScreen()));
                    },
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/house.svg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecondPrincipalScreen()),
                    ),
                  ),
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/progreso.svg",
                    onTap: () {
                      if (!AppState.instance.isTestCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa el test inicial para desbloquear esta sección.')),
                        );
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Psicologos()));
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

/// StreamBuilder que agrupa por mes las notas de `usuarios/{uid}/notas`
/// y pinta carruseles por cada mes.
class _MonthlyNotesStream extends StatelessWidget {
  final void Function(
    String docId, {
    required String? titulo,
    required String? texto,
    required String tipo,
    required String? imageUrl,
  }) onOpenEdit;

  const _MonthlyNotesStream({required this.onOpenEdit});

  CollectionReference<Map<String, dynamic>>? _notesCol() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('notas');
  }

  @override
  Widget build(BuildContext context) {
    final col = _notesCol();
    if (col == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('Inicia sesión para ver tus notas.')),
      );
    }

    final query = col.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return const SizedBox(height: 80, child: Center(child: Text('Error al cargar notas.')));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SizedBox(height: 80, child: Center(child: Text('Sin notas aún.')));
        }

        // Agrupar por mes (YYYY-MM)
        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> groups = {};
        for (final d in docs) {
          final data = d.data();
          final ts   = data['createdAt'] as Timestamp?;
          final date = ts?.toDate() ?? DateTime.now();
          final key  = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
          groups.putIfAbsent(key, () => []).add(d);
        }
        final keys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

        String formatMonthES(String key) {
          final d = DateTime.parse('$key-01');
          const meses = [
            'Enero','Febrero','Marzo','Abril','Mayo','Junio',
            'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
          ];
          return '${meses[d.month - 1]} ${d.year}';
        }

        Widget monthHeader(String label) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final key in keys) ...[
              monthHeader(formatMonthES(key)),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: groups[key]!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final d     = groups[key]![i];
                    final data  = d.data();

                    final titulo   = (data['titulo'] as String?) ?? '';
                    final texto    = (data['texto']  as String?) ?? '';
                    final tipo     = (data['tipo']   as String?) ?? 'texto';
                    final imageUrl = (data['imageUrl'] as String?) ?? '';

                    return GestureDetector(
                      onTap: () => onOpenEdit(
                        d.id,
                        titulo: titulo.isEmpty ? null : titulo,
                        texto:  texto.isEmpty ? null : texto,
                        tipo:   tipo,
                        imageUrl: imageUrl.isEmpty ? null : imageUrl,
                      ),
                      child: ContainerDiarioWhite(
                        height: 108,
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _NoteCell(
                            titulo: titulo.isEmpty ? 'Sin título' : titulo,
                            texto:  texto,
                            tipo:   tipo,
                            imageUrl: imageUrl,
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
      },
    );
  }
}

class _NoteCell extends StatelessWidget {
  final String  titulo;
  final String? texto;
  final String  tipo;     // 'texto' | 'imagen'
  final String? imageUrl;

  const _NoteCell({
    required this.titulo,
    required this.texto,
    required this.tipo,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (tipo == 'imagen' && (imageUrl != null && imageUrl!.isNotEmpty)) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          if (texto != null && texto!.isNotEmpty)
            Text(
              texto!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.2),
            ),
        ],
      );
    } else {
      content = Text(
        (texto ?? ''),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, height: 1.25, color: Colors.black87),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Expanded(child: content),
      ],
    );
  }
}

/// Helper seguro para SVGs (si falla, muestra ícono)
Widget safeSvg(String path, {double? width, double? height}) {
  try {
    return SvgPicture.asset(path, width: width, height: height);
  } catch (e) {
    return const Icon(Icons.error, color: Colors.red);
  }
}
