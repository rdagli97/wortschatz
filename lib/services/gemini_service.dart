import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/german_text.dart';
import '../data/goethe_a1_conjugations.dart';
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
                    'Eğer bu bir fiilin çekimlenmiş/çekilmiş hali ise (ör. "ging", '
                    '"gegangen", "ist", "wäscht"), word alanına mastar (infinitiv) '
                    'halini yaz (ör. "gehen", "sein", "waschen"); isimse ya da '
                    'zaten sözlük/temel haldeyse olduğu gibi bırak (sadece doğru '
                    'büyük/küçük harf kullanımını düzelt). '
                    'Kelime bir isim değilse (fiil, sıfat, zarf vb.) article alanını '
                    'boş string olarak bırak. Plural alanı isim değilse boş string '
                    'olsun. '
                    'wordType alanına kelimenin türünü yaz: fiilse ve ayrılabilir '
                    '(trennbar) bir fiilse "separableVerb", düzensiz/güçlü çekimli '
                    'bir fiilse "irregularVerb", düzenli/zayıf çekimli bir fiilse '
                    '"regularVerb"; bağlaçsa (weil/und/dass gibi) "conjunction"; '
                    'isim ya da bunların dışında bir tür ise (sıfat, zarf, edat, '
                    'soru kelimesi vb.) "none". '
                    'Fiilse conjugationIch/conjugationDu/conjugationEr/'
                    'conjugationWir/conjugationIhr/conjugationSieSie alanlarına '
                    'şimdiki zaman (Präsens) çekimlerini yaz (ör. "gehen" için: '
                    'gehe/gehst/geht/gehen/geht/gehen; dönüşlü (reflexiv) bir '
                    'fiilse doğru dönüşlü zamiri de ekle, ör. "sich waschen" için '
                    '"wasche mich"/"wäschst dich"/"wäscht sich"/"waschen uns"/'
                    '"wascht euch"/"waschen sich"). '
                    'Fiilse verbCase alanına nesne durumunu yaz: sadece Akkusativ '
                    'nesne alıyorsa "akkusativ", sadece Dativ alıyorsa "dativ", '
                    'ikisini birden alıyorsa "akkusativ+dativ", hiç nesne '
                    'almıyorsa "nominativ". Fiil değilse conjugation alanlarını '
                    've verbCase alanını boş string bırak. '
                    'Bağlaçsa sendsVerbToEnd alanına, bu bağlacın bulunduğu yan '
                    'cümlede fiili sona gönderip göndermediğini yaz (weil/dass/'
                    'wenn/obwohl gibi bağlaçlar için true; und/aber/oder/denn '
                    'gibi bağlaçlar için false). Bağlaç değilse false yaz.',
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

    final resolvedWord = (input['word'] as String? ?? '').trim();
    final finalWord = resolvedWord.isEmpty ? cleanedWord : resolvedWord;

    final rawWordType = (input['wordType'] as String? ?? '').trim();
    final wordType =
        (rawWordType.isEmpty || rawWordType == 'none') ? null : rawWordType;

    String? conjugationJson;
    String? verbCaseValue;
    if (wordType == 'separableVerb' ||
        wordType == 'irregularVerb' ||
        wordType == 'regularVerb') {
      final ich = (input['conjugationIch'] as String? ?? '').trim();
      final du = (input['conjugationDu'] as String? ?? '').trim();
      final er = (input['conjugationEr'] as String? ?? '').trim();
      final wir = (input['conjugationWir'] as String? ?? '').trim();
      final ihr = (input['conjugationIhr'] as String? ?? '').trim();
      final sieSie = (input['conjugationSieSie'] as String? ?? '').trim();
      if (ich.isNotEmpty && du.isNotEmpty && er.isNotEmpty) {
        conjugationJson = VerbConjugation(
          ich: ich,
          du: du,
          erSieEs: er,
          wir: wir.isEmpty ? finalWord : wir,
          ihr: ihr.isEmpty ? finalWord : ihr,
          sieSie: sieSie.isEmpty ? finalWord : sieSie,
        ).toJson();
      }
      final rawCase = (input['verbCase'] as String? ?? '').trim();
      verbCaseValue = rawCase.isEmpty ? null : rawCase;
    }

    final sendsVerbToEnd =
        wordType == 'conjunction' ? (input['sendsVerbToEnd'] as bool? ?? false) : null;

    return Word(
      article: (input['article'] as String? ?? '').trim(),
      word: finalWord,
      meaningEn: (input['meaningEn'] as String? ?? '').trim(),
      meaningTr: (input['meaningTr'] as String? ?? '').trim(),
      plural: (input['plural'] as String? ?? '').trim(),
      exampleSentence: (input['exampleSentence'] as String? ?? '').trim(),
      exampleTranslationEn: (input['exampleTranslationEn'] as String? ?? '').trim(),
      exampleTranslationTr: (input['exampleTranslationTr'] as String? ?? '').trim(),
      wordType: wordType,
      conjugationJson: conjugationJson,
      verbCase: verbCaseValue,
      sendsVerbToEnd: sendsVerbToEnd,
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
  // 'A1', 'A2', 'B1' ve seviyelerin karıştığı doğal 'Karma' modu destekleniyor.
  Future<GeneratedStory> generateStory(
    String level,
    String topic,
    String apiKey,
  ) async {
    final rules = _storyRulesByLevel[level];
    if (rules == null) {
      throw GeminiApiException('$level seviyesi için hikaye üretimi henüz eklenmedi.');
    }

    final examples = _topicExamplesByLevel[level] ?? '';
    final topicInstruction = topic.trim().isEmpty
        ? 'No topic was given. Choose a common everyday topic yourself '
            '(e.g. $examples).'
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
    'A2': '''
You are a German language teacher creating short reading stories for A2-level learners.

Generate ONE original German story following these STRICT rules:

## LEVEL: A2 (CEFR)
- Main tense is Präsens, but you MUST also use Perfekt naturally (e.g. "Ich bin gekommen", "Ich habe gesehen"). A few Präteritum forms of common verbs are allowed (war, hatte, kam, ging).
- Use subordinate clauses (Nebensätze). Include connectors such as: weil, dass, wenn, als, während, nachdem, um...zu, trotzdem, deshalb.
- Also use sequencing/time words: zuerst, danach, später, dann, am Ende, gegen Mittag, am Morgen, am Abend.
- Sentences can be longer and combine two ideas, but stay clear and readable.
- Use A2 vocabulary: everyday life, family, feelings, opinions, travel, work, daily routine, simple descriptions and comparisons.
- Write mainly in 1st person singular (Ich...). Other people may appear and interact.
- Structure the story in 3–5 short paragraphs with a clear beginning, middle and end.
- Total length: 30–45 sentences.
- The story should describe a connected experience or event (e.g. a day, a visit, a trip, a description of a person or place).

## OUTPUT
Return the title (2-5 German words, no ending punctuation) and the story as
a list of paragraphs: one array item per paragraph (3-5 items total), each
item containing several connected sentences following the rules above. Do
not add translations, explanations, grammar notes, markdown, quotes, or
emojis anywhere.''',
    'B1': '''
You are a German language teacher creating short reading stories for B1-level learners.

Generate ONE original German story following these STRICT rules:

## LEVEL: B1 (CEFR)
- Choose the tense that fits the story type:
  - For narrated events/experiences, use PRÄTERITUM as the main narrative tense (e.g. beschloss, ging, fand, dachte nach), with Perfekt where natural.
  - For descriptions of a person, place or routine, Präsens is fine.
- Use a rich variety of subordinate clauses and connectors: obwohl, weil, dass, damit, deshalb, trotzdem, während, bevor, nachdem, sodass, gleichzeitig, als.
- Use zu + Infinitiv constructions (e.g. "Ich beschloss, die Bibliothek zu besuchen", "Er versucht, gesund zu essen").
- Use reflexive and verb+preposition structures (sich freuen auf, sich gewöhnen an, sich interessieren für, achten auf, sich vorbereiten auf).
- Vary sentence structure: start some sentences with a connector or adverb and apply correct inversion.
- Include some reflection, opinion or emotional depth — not only actions, but also thoughts and evaluations (e.g. why something matters, how the person feels).
- Use B1 vocabulary, including some abstract nouns (Möglichkeiten, Erfahrungen, Verantwortung, Deutschkenntnisse, Ernährung).
- Perspective can be 1st person singular OR 3rd person singular (a character portrait/story about someone).
- Structure the story in 3–4 paragraphs with a clear arc: situation → development → reflection/conclusion.
- Total length: 35–45 sentences.

## OUTPUT
Return the title (2-5 German words, no ending punctuation) and the story as
a list of paragraphs: one array item per paragraph (3-4 items total), each
item containing several connected sentences following the rules above. Do
not add translations, explanations, grammar notes, markdown, quotes, or
emojis anywhere.''',
    'Karma': '''
You are a native German writer creating short, natural reading stories for German learners.

Generate ONE original German story that reads like authentic, natural German — NOT like a graded textbook text.

## STYLE & LANGUAGE
- Write natural German that mixes simple and complex sentences, the way real texts do.
- Vary sentence length: some short and direct, some longer with subordinate clauses.
- Use whatever tense the story needs: Präsens for descriptions, Perfekt for spoken-style past, Präteritum for narration. Mix them naturally.
- Freely use subordinate clauses and connectors (weil, dass, obwohl, während, bevor, nachdem, deshalb, trotzdem, damit, als, sodass), zu + Infinitiv, reflexive verbs and verb+preposition structures — but only where they feel natural.
- Keep the overall vocabulary accessible (roughly up to B1). Avoid rare, literary or highly technical words. If a slightly harder word fits naturally, it's fine.
- Aim for warmth and authenticity: real situations, small emotions, everyday details, a natural flow — not a mechanical list of actions.

## STRUCTURE
- Give the story a clear arc: a situation, some development, and a small ending or reflection.
- 3–4 paragraphs. Total length: about 30–45 sentences.
- Perspective can be 1st or 3rd person.

## OUTPUT
Return the title (2-5 German words, no ending punctuation) and the story as
a list of paragraphs: one array item per paragraph (3-4 items total), each
item containing several connected sentences following the rules above. Do
not add translations, explanations, grammar notes, level labels, markdown,
quotes, or emojis anywhere.''',
  };

  static const _topicExamplesByLevel = {
    'A1': 'shopping, cooking, a day at home, a walk, the weather, visiting a friend',
    'A2': 'moving to a new city, a family visit, describing a relative, a day '
        'trip, learning German, a special day',
    'B1': 'a quiet afternoon, describing a family member, a first job, '
        'adapting to a new country, a small everyday decision and what it '
        'taught the person',
    'Karma': 'a walk in the city, a memorable meal, a small challenge at '
        'work, an unexpected encounter, a rainy day, learning something new',
  };

  static const _storySchema = {
    'type': 'OBJECT',
    'properties': {
      'title': {
        'type': 'STRING',
        'description': 'Almanca başlık, 2-5 kelime, sonunda noktalama yok',
      },
      'sentences': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
        'description':
            'Hikayenin metni; seviyeye göre her biri bir cümle ya da bir '
            'paragraf olacak şekilde ayrı bir dizi elemanı',
      },
    },
    'required': ['title', 'sentences'],
  };

  static const _wordDetailsSchema = {
    'type': 'OBJECT',
    'properties': {
      'word': {
        'type': 'STRING',
        'description':
            'Kelimenin sözlük/mastar hali (fiil çekimli girildiyse infinitiv '
            'hali, değilse olduğu gibi)',
      },
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
      'wordType': {
        'type': 'STRING',
        'description':
            "'separableVerb' (ayrılabilir fiil), 'irregularVerb' (düzensiz "
            "fiil), 'regularVerb' (düzenli fiil), 'conjunction' (bağlaç) ya "
            "da hiçbiri değilse 'none'",
      },
      'conjugationIch': {
        'type': 'STRING',
        'description': "Fiilse şimdiki zaman 'ich' çekimi, değilse boş string",
      },
      'conjugationDu': {
        'type': 'STRING',
        'description': "Fiilse 'du' çekimi, değilse boş string",
      },
      'conjugationEr': {
        'type': 'STRING',
        'description': "Fiilse 'er/sie/es' çekimi, değilse boş string",
      },
      'conjugationWir': {
        'type': 'STRING',
        'description': "Fiilse 'wir' çekimi, değilse boş string",
      },
      'conjugationIhr': {
        'type': 'STRING',
        'description': "Fiilse 'ihr' çekimi, değilse boş string",
      },
      'conjugationSieSie': {
        'type': 'STRING',
        'description': "Fiilse 'sie/Sie' çekimi, değilse boş string",
      },
      'verbCase': {
        'type': 'STRING',
        'description':
            "Fiilse nesne durumu: 'akkusativ', 'dativ', 'akkusativ+dativ' "
            "ya da nesne almıyorsa 'nominativ'; fiil değilse boş string",
      },
      'sendsVerbToEnd': {
        'type': 'BOOLEAN',
        'description':
            'Bağlaçsa fiili yan cümlenin sonuna gönderiyor mu, değilse false',
      },
    },
    'required': [
      'word',
      'article',
      'plural',
      'meaningEn',
      'meaningTr',
      'exampleSentence',
      'exampleTranslationEn',
      'exampleTranslationTr',
      'wordType',
      'conjugationIch',
      'conjugationDu',
      'conjugationEr',
      'conjugationWir',
      'conjugationIhr',
      'conjugationSieSie',
      'verbCase',
      'sendsVerbToEnd',
    ],
  };
}
