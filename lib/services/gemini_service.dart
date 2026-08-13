import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word.dart';

class GeminiApiException implements Exception {
  final String message;
  final bool isInvalidKey;

  GeminiApiException(this.message, {this.isInvalidKey = false});

  @override
  String toString() => message;
}

// Google Gemini API'yi (ücretsiz katman) Almanca kelime bilgisi üretmek için çağırır.
class GeminiService {
  static const _model = 'gemini-2.5-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  Future<Word> generateWordDetails(String germanWord, String apiKey) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-goog-api-key': apiKey,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text':
                    'Almanca "$germanWord" kelimesi için A1-A2 seviyesinde bir '
                    'Almanca öğrencisine yardımcı olacak sözlük bilgisi üret. '
                    'Kelime bir isim değilse (fiil, sıfat, zarf vb.) article alanını '
                    'boş string olarak bırak. Plural alanı isim değilse boş string olsun.',
              },
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': _wordDetailsSchema,
        },
      }),
    );

    if (response.statusCode == 400 || response.statusCode == 403) {
      throw GeminiApiException(
        'API anahtarı geçersiz.',
        isInvalidKey: true,
      );
    }
    if (response.statusCode == 429) {
      throw GeminiApiException(
        'Ücretsiz kullanım limitine ulaşıldı. Biraz sonra tekrar dene.',
      );
    }
    if (response.statusCode != 200) {
      throw GeminiApiException(
        'Gemini API hatası (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final candidates = body['candidates'] as List<dynamic>? ?? [];
    if (candidates.isEmpty) {
      throw GeminiApiException('Gemini beklenen formatta yanıt vermedi.');
    }

    final parts = candidates.first['content']?['parts'] as List<dynamic>? ?? [];
    if (parts.isEmpty) {
      throw GeminiApiException('Gemini beklenen formatta yanıt vermedi.');
    }

    final input = jsonDecode(parts.first['text'] as String) as Map<String, dynamic>;

    return Word(
      article: (input['article'] as String? ?? '').trim(),
      word: germanWord.trim(),
      meaningEn: (input['meaningEn'] as String? ?? '').trim(),
      meaningTr: (input['meaningTr'] as String? ?? '').trim(),
      plural: (input['plural'] as String? ?? '').trim(),
      exampleSentence: (input['exampleSentence'] as String? ?? '').trim(),
      exampleTranslationEn: (input['exampleTranslationEn'] as String? ?? '').trim(),
      exampleTranslationTr: (input['exampleTranslationTr'] as String? ?? '').trim(),
    );
  }

  static const _wordDetailsSchema = {
    'type': 'OBJECT',
    'properties': {
      'article': {
        'type': 'STRING',
        'description': 'der, die, das veya isim değilse boş string',
      },
      'plural': {
        'type': 'STRING',
        'description': 'Kelimenin çoğul hali, isim değilse boş string',
      },
      'meaningEn': {'type': 'STRING', 'description': 'İngilizce anlamı'},
      'meaningTr': {'type': 'STRING', 'description': 'Türkçe anlamı'},
      'exampleSentence': {
        'type': 'STRING',
        'description': 'Kelimeyi içeren basit bir Almanca örnek cümle',
      },
      'exampleTranslationEn': {
        'type': 'STRING',
        'description': 'Örnek cümlenin İngilizce çevirisi',
      },
      'exampleTranslationTr': {
        'type': 'STRING',
        'description': 'Örnek cümlenin Türkçe çevirisi',
      },
    },
    'required': [
      'article',
      'plural',
      'meaningEn',
      'meaningTr',
      'exampleSentence',
      'exampleTranslationEn',
      'exampleTranslationTr',
    ],
  };
}
