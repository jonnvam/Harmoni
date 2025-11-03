import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/reusable_widgets.dart';
import 'package:flutter_application_1/core/text_styles.dart';
import 'package:flutter_application_1/screens/diario_screen.dart';
import 'package:flutter_application_1/screens/metas_screen.dart';
import 'package:flutter_application_1/screens/progreso.dart';
import 'package:flutter_application_1/screens/second_principal_screen.dart';
import 'package:flutter_application_1/screens/psicologos.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/data/diary_repo.dart';
import 'package:flutter_application_1/data/api_service.dart'; // 👈 (ya estaba correcto)

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final TextEditingController _chatCtrl = TextEditingController();
  final List<_Message> _messages = [];

  // 🧠 Variables nuevas para IA (cache + control)
  final Map<String, String> _cacheRespuestas = {};
  bool _isSending = false;

  // 🧠 Historial de conversación (para contexto) — cambie esto
  final List<Map<String, String>> _historial = [];

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  Future<void> _shareDiaryPages() async {
    final notes = await DiaryRepo.instance.listNotes();
    final buffer = StringBuffer();
    for (final n in notes.take(20).toList().reversed) {
      final date = n.date.toLocal().toString().split('.').first;
      switch (n.type) {
        case DiaryNoteType.text:
          buffer.writeln('[$date] Texto: ${n.text ?? ''}');
          break;
        case DiaryNoteType.audio:
          buffer.writeln('[$date] Audio: ${n.filePath ?? ''}');
          break;
        case DiaryNoteType.image:
          buffer.writeln('[$date] Imagen: ${n.filePath ?? ''} ${n.text ?? ''}');
          break;
      }
    }
    final content =
        buffer.isEmpty ? 'No hay notas para compartir.' : buffer.toString();
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contenido copiado al portapapeles')),
    );
  }

  // ===============================================================
  // 💬 FUNCIÓN MODIFICADA _sendMessage() — cambie esto
  // ===============================================================
  Future<void> _sendMessage() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    final textoMinus = text.toLowerCase();

    // 🚨 Palabras clave de riesgo
    final palabrasRiesgo = [
      "suicidio",
      "matarme",
      "no quiero vivir",
      "depresion",
      "depresión",
      "ansiedad fuerte",
      "me odio",
      "autolesión",
      "autolesion",
      "sin sentido",
    ];

    final esRiesgo = palabrasRiesgo.any((p) => textoMinus.contains(p));

    if (esRiesgo) {
      setState(() {
        _messages.add(_Message(sender: Sender.user, text: text));
        _messages.add(_Message(
          sender: Sender.bot,
          text:
              "💜 Parece que estás pasando por un momento difícil. Te recomiendo hablar con un psicólogo o alguien de confianza. No estás solo 💙",
        ));
      });
      _chatCtrl.clear();
      return;
    }

    // 💬 Limitar texto muy largo
    if (text.length > 200) {
      setState(() {
        _messages.add(_Message(
          sender: Sender.bot,
          text: "⚠️ El mensaje es demasiado largo, intenta resumirlo un poco.",
        ));
      });
      return;
    }

    // 🚫 Evitar mensajes simultáneos
    if (_isSending) return;
    _isSending = true;

    setState(() {
      _messages.add(_Message(sender: Sender.user, text: text));
    });
    _chatCtrl.clear();

    setState(() {
      _messages.add(
          _Message(sender: Sender.bot, text: "💭 Haru está pensando..."));
    });

    // ⚡ Cache: si ya respondió antes, no gasta tokens
    if (_cacheRespuestas.containsKey(text)) {
      await Future.delayed(const Duration(milliseconds: 200));
      final cached = _cacheRespuestas[text]!;
      setState(() {
        _messages.removeLast();
        _messages.add(_Message(sender: Sender.bot, text: cached));
      });
      _isSending = false;
      return;
    }

    // 🧠 Agregar mensaje del usuario al historial — cambie esto
    _historial.add({"role": "user", "content": text});

    try {
      // 🧠 Enviar mensaje con historial (contexto completo) — cambie esto
      final respuesta = await ApiService.enviarMensaje(text, _historial);

      // Guardar la respuesta en cache y también en el historial
      _cacheRespuestas[text] = respuesta;
      _historial.add({"role": "assistant", "content": respuesta});

      setState(() {
        _messages.removeLast();
        _messages.add(_Message(sender: Sender.bot, text: respuesta));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(_Message(
            sender: Sender.bot,
            text:
                "⚠️ Error al conectar con Haru. Revisa tu conexión o tu API key."));
      });
    }

    _isSending = false;
  }
  // ===============================================================

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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 45),
                      child: Column(
                        children: [
                          HolaNombre(
                            style: TextStyles.textInicioName,
                            prefix:"hola",
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15),
                      child: InfoBubbleButton(
                        message:
                            "Es una IA no te lo creas todo",
                        autoHideDuration: const Duration(seconds: 4),
                        iconSize: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                ContainerC2(
                  width: 350,
                  alignment: Alignment.center,
                  height: 80,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Compartir Paginas del Diario",
                              style: TextStyles.textDLogin,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Row(
                            children: [
                              InkWell(
                                onTap: _shareDiaryPages,
                                child: SvgPicture.asset("assets/images/ia/copy.svg"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                ContainerC1(
                  height: 145,
                  width: 350,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Text(
                              "Entendiendo la ansiedad",
                              style: TextStyles.textDLogin,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 45),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/images/ia/lamp-charge.svg",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 35,
                        left: 35,
                        right: 20,
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ContainerC1(
                                width: 140,
                                height: 145,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Habitos \nSaludables",
                                  style: TextStyles.textDLogin,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 60),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ContainerC1(
                                alignment: Alignment.center,
                                width: 140,
                                height: 145,
                                child: const Text(
                                  "Identificar \nsíntomas de\nestres",
                                  style: TextStyles.textDLogin,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Chat-like area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final m = _messages[i];
                            final isUser = m.sender == Sender.user;
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isUser ? const Color(0xFFE0F2FE) : const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(m.text),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ContainerC2(
                        width: 330,
                        height: 70,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatCtrl,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Comparte una idea (chat IA)',
                                    hintStyle: TextStyles.textDLogin,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              InkWell(
                                onTap: _sendMessage,
                                child: SvgPicture.asset("assets/images/ia/level.svg"),
                              ),
                              SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SemiCircularRadialMenu(
                currentIconAsset: "assets/images/icon/ia.svg",
                ringColor: Colors.transparent,
                items: [
                  // Diario (left)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/diario.svg",
                    onTap: () {
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Progreso()));
                    },
                  ),
                  // Psicólogos (right)
                  RadialMenuItem(
                    iconAsset: "assets/images/icon/psicologos.svg",
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Psicologos()));},
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

enum Sender { user, bot }

class _Message {
  final Sender sender;
  final String text;
  _Message({required this.sender, required this.text});
}
