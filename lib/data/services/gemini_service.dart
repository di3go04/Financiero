import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  // Configuración de la API (Para producción, esto debería estar en un backend o .env)
  static const String apiKey = 'REPLACE_WITH_YOUR_GEMINI_API_KEY';
  
  /// Analiza las transacciones y devuelve un reporte en Markdown
  static Future<String> analyzeFinances(List<dynamic> transactions) async {
    if (apiKey.contains('REPLACE')) {
      return '⚠️ **API Key no configurada.**\nPor favor, añade tu API Key de Gemini en `gemini_service.dart`.';
    }

    try {
      final prompt = '''
Eres "Prosper AI", un asesor Prosper personal experto.
Aquí están mis transacciones recientes (en JSON):
${jsonEncode(transactions)}

Por favor, genera un reporte Prosper corto con la siguiente estructura:
1. **Resumen rápido:** (1 párrafo sobre el estado general de mis finanzas).
2. **Advertencias:** (Si hay algún gasto inusual o excesivo).
3. **Consejo del mes:** (1 consejo práctico y motivador para ahorrar más).
Usa un tono profesional pero muy amigable, y utiliza emojis moderadamente. Escribe la respuesta en formato Markdown puro sin envolver en bloques de código.
''';

      return await _callGeminiText(prompt);
    } catch (e) {
      debugPrint('Error en GeminiService: $e');
      return '❌ No se pudo conectar con la Inteligencia Artificial en este momento.';
    }
  }

  /// Procesa una imagen en Base64 para extraer recibos usando OCR
  static Future<Map<String, dynamic>?> scanReceipt(String base64Image) async {
    if (apiKey.contains('REPLACE')) {
      throw Exception('API Key no configurada para OCR.');
    }

    try {
      final prompt = '''
Analiza esta imagen que es un recibo de compra.
Extrae los siguientes datos exactos y responde ÚNICAMENTE con un objeto JSON (sin comillas invertidas de markdown, puro texto JSON):
{
  "amount": (número flotante, el total a pagar),
  "category": (elige una de: "Comida", "Transporte", "Ocio", "Vivienda", "Salud", "Suscripciones", "Educación", "Compras"),
  "merchant": (string, el nombre del comercio o tienda)
}
Si no estás seguro de algo, trata de adivinar con el contexto.
''';

      final response = await _callGeminiVision(prompt, base64Image);
      return jsonDecode(response.trim());
    } catch (e) {
      debugPrint('Error OCR Gemini: $e');
      return null;
    }
  }

  static Future<String> _callGeminiText(String prompt) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{
          "parts": [{"text": prompt}]
        }]
      })
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API Error: \${response.body}');
    }
  }

  static Future<String> _callGeminiVision(String prompt, String base64Image) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{
          "parts": [
            {"text": prompt},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }]
      })
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API Vision Error: \${response.body}');
    }
  }
}
