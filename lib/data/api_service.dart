import 'dart:convert';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/log.dart';

class ApiService {
  static final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String endpoint = "https://api.openai.com/v1/chat/completions";

=======
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Lee la API key desde variable de entorno si está disponible,
  // de lo contrario usa un placeholder y muestra advertencia.
  static final String apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '')
      .trim();
  static const String endpoint = "https://api.openai.com/v1/chat/completions";
  
>>>>>>> feature/stabilize-before-main
  // 🧠 Cambie esto: ahora acepta historial para mantener el contexto
  static Future<String> enviarMensaje(
    String mensajeUsuario,
    List<Map<String, String>> historial,
  ) async {
    // Verifica si hay API key configurada
<<<<<<< HEAD
    if (apiKey == "TU_API_KEY_AQUI" || apiKey.trim().isEmpty) {
=======
    if (apiKey.isEmpty) {
>>>>>>> feature/stabilize-before-main
      return "⚠️ No hay API Key configurada. Agrega tu clave de OpenAI en api_service.dart.";
    }

    try {
      // 🧩 Cambie esto: se arma el contexto completo con sistema + historial + mensaje nuevo
      final mensajes = [
        {
          "role": "system",
          "content": """
Eres Haru, un asistente empático y motivador especializado únicamente en bienestar emocional, manejo de ansiedad y hábitos saludables.

💬 No eres psicólogo ni médico, y no das diagnósticos.
❌ No hablas de temas fuera de emociones, salud mental o bienestar personal.
⚠️ Si el usuario pregunta algo fuera de tu enfoque, responde con:
"Lo siento, solo puedo hablar sobre bienestar emocional y hábitos saludables 😊".

Tu meta es escuchar con empatía, ofrecer apoyo emocional general y redirigir a profesionales cuando detectes riesgo emocional o crisis.
<<<<<<< HEAD
""",
        },
        ...historial, // 👈 historial del chat (user + assistant)
        {
          "role": "user",
          "content": mensajeUsuario,
        }, // último mensaje del usuario
=======
"""
        },
        ...historial, // 👈 historial del chat (user + assistant)
        {"role": "user", "content": mensajeUsuario}, // último mensaje del usuario
>>>>>>> feature/stabilize-before-main
      ];

      // Petición a OpenAI
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4.1-mini",
          "messages": mensajes,
          "max_tokens": 300,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Respuesta textual del modelo
        return data["choices"][0]["message"]["content"];
      } else {
<<<<<<< HEAD
        log.e('Error ${response.statusCode}: ${response.body}');
        return "⚠️ Error al conectar con Haru. Intenta más tarde.";
      }
    } catch (e, st) {
      log.e('Excepción en ApiService', error: e, stackTrace: st);
=======
        print("❌ Error ${response.statusCode}: ${response.body}");
        return "⚠️ Error al conectar con Haru. Intenta más tarde.";
      }
    } catch (e) {
      print("❌ Excepción: $e");
>>>>>>> feature/stabilize-before-main
      return "⚠️ Ocurrió un error inesperado al contactar a Haru.";
    }
  }
}
