import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/german_text.dart';
import '../models/word.dart';

class GeneratedStory {
  final String title;
  final String content; // her satırda bir cümle

  const GeneratedStory({required this.title, required this.content});
}

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
    // Kullanıcı kelimeyi artikeliyle yazmış olabilir (ör. "das Haus"); AI
    // ayrıca kendi artikelini döndürdüğü için, bunu birleştirmeden önce
    // baştaki artikeli ayıklamak gerekiyor ("das das Haus" olmasın diye).
    final cleanedWord = stripLeadingGermanArticle(germanWord);

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
                    'Almanca "$cleanedWord" kelimesi için A1-A2 seviyesinde bir '
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
      word: cleanedWord,
      meaningEn: (input['meaningEn'] as String? ?? '').trim(),
      meaningTr: (input['meaningTr'] as String? ?? '').trim(),
      plural: (input['plural'] as String? ?? '').trim(),
      exampleSentence: (input['exampleSentence'] as String? ?? '').trim(),
      exampleTranslationEn: (input['exampleTranslationEn'] as String? ?? '').trim(),
      exampleTranslationTr: (input['exampleTranslationTr'] as String? ?? '').trim(),
    );
  }

  // Kullanıcının merak ettiği bir Almanca konusunu basitçe anlatır.
  Future<String> explainTopic(String keyword, String apiKey) async {
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
                    'Ben almanca da $keyword konusunu öğrenmekte çok zorlanıyorum. '
                    'Bana bunu çok basit bir şekilde anlat. Bir kaç örnek ile destekle. '
                    'Cevabını okunması ve anlaşılması kolay olacak şekilde Markdown '
                    'ile biçimlendir: kısa başlıklar (##), önemli kelimeleri '
                    '**kalın** yap, örnekleri madde işaretleriyle listele, ve '
                    'karşılaştırma yaparken (örneğin iki kullanım arasındaki '
                    'farkı gösterirken) bir Markdown tablosu kullan. Uzun, tek '
                    'parça bir paragraf yazma; kısa ve göz gezdirmesi kolay '
                    'bölümler halinde anlat.',
              },
            ],
          },
        ],
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

    return (parts.first['text'] as String? ?? '').trim();
  }

  // Seviyeye uygun, okunması kolay kısa bir Almanca hikaye üretir.
  // Şimdilik sadece 'A1' seviyesi destekleniyor.
  Future<GeneratedStory> generateStory(
    String level,
    String topic,
    String apiKey,
  ) async {
    final rules = _storyRulesByLevel[level];
    if (rules == null) {
      throw GeminiApiException('$level seviyesi için hikaye üretimi henüz eklenmedi.');
    }

    final topicInstruction = topic.trim().isEmpty
        ? 'No topic was given. Choose a common everyday A1 topic yourself '
            '(e.g. shopping, cooking, a day at home, a walk, the weather, '
            'visiting a friend).'
        : 'A topic has been given: "${topic.trim()}". Build the story around '
            'this topic.';

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
                'text': '$rules\n\n## TOPIC\n$topicInstruction',
              },
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': _storySchema,
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
    final sentences = (input['sentences'] as List<dynamic>? ?? [])
        .map((s) => s.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return GeneratedStory(
      title: (input['title'] as String? ?? '').trim(),
      content: sentences.join('\n'),
    );
  }

  static const _storyRulesByLevel = {
    'A1': '''
You are a German language teacher creating short reading stories for A1-level learners.

Generate ONE original German story following these STRICT rules:

## LEVEL: A1 (CEFR)
- Use ONLY Präsens (present tense). You may use max 1-2 simple Perfekt sentences at the very beginning (e.g. "Ich habe heute frei").
- Write ONLY main clauses (Hauptsätze). NO subordinate clauses.
- FORBIDDEN connectors: weil, dass, wenn, obwohl, damit, deshalb.
- ALLOWED connectors only: und, aber, dann, oder, später, danach.
- Keep sentences SHORT: 4–8 words each. One idea per sentence.
- Use A1 vocabulary only (everyday life: home, food, school, shopping, transport, family, daily routine).
- Write in 1st person singular (Ich...) as the main perspective.
- Total length: 15–22 sentences.
- The story must describe ONE simple everyday scene or routine.

## OUTPUT
Return the title (2-4 German words, no ending punctuation) and the story as
a list of sentences, one idea per array item, following the sentence rules
above. Do not add translations, explanations, grammar notes, markdown,
quotes, or emojis anywhere.''',
  };

  static const _storySchema = {
    'type': 'OBJECT',
    'properties': {
      'title': {
        'type': 'STRING',
        'description': 'Almanca başlık, 2-4 kelime, sonunda noktalama yok',
      },
      'sentences': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
        'description': 'Hikayenin cümleleri, her biri ayrı bir dizi elemanı',
      },
    },
    'required': ['title', 'sentences'],
  };

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
