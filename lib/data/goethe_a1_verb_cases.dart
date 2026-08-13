// Düzenli/düzensiz A1 fiillerinin nesne durumu (Rektion): fiil nesnesiz mi
// (sadece Nominativ - özne), sadece Akkusativ mi, sadece Dativ mi, yoksa
// hem Dativ hem Akkusativ mi alıyor. Ayrılabilir fiiller bu kapsamda değil.
//
// Sınıflandırma, A1 seviyesinde en yaygın/öğretilen kullanıma göre yapıldı;
// bazı fiiller hem geçişli hem geçişsiz kullanılabildiği için (ör. "fahren",
// "rauchen") en temsili anlam esas alındı.

// Sadece Dativ alan (Almanca öğrenenlerin en çok karıştırdığı) fiiller
const _dativOnlyVerbs = {
  'antworten', 'danken', 'fehlen', 'gehören', 'glauben', 'gratulieren',
  'schmecken', 'gefallen', 'helfen',
};

// Hem Dativ (kime/kimin için) hem Akkusativ (neyi) alan fiiller
const _dativAndAkkusativVerbs = {
  'erklären', 'erlauben', 'erzählen', 'schicken', 'verkaufen', 'vermieten',
  'bringen', 'empfehlen', 'geben', 'überweisen',
};

// Nesne almayan (geçişsiz, sadece Nominativ - özne) fiiller
const _nominativOnlyVerbs = {
  'arbeiten', 'baden', 'dauern', 'enden', 'frühstücken', 'lachen', 'leben',
  'regnen', 'reisen', 'tanzen', 'telefonieren', 'übernachten', 'wandern',
  'warten', 'wohnen',
  'bleiben', 'fahren', 'fliegen', 'gehen', 'heißen', 'kommen', 'laufen',
  'riechen', 'scheinen', 'schlafen', 'schwimmen', 'sein', 'sitzen', 'stehen',
  'werden',
};

// Geri kalan tüm düzenli/düzensiz fiiller Akkusativ alır (varsayılan, en
// yaygın durum) — bu yüzden ayrı bir liste tutmaya gerek yok.

/// Bir fiilin nesne durumunu döner: 'nominativ' | 'akkusativ' | 'dativ' |
/// 'akkusativ+dativ'. Düzenli/düzensiz fiil değilse null döner.
String? verbCase(String word, String? wordType) {
  if (wordType != 'regularVerb' && wordType != 'irregularVerb') return null;

  final trimmed = word.trim().toLowerCase();
  final key = trimmed.startsWith('sich ') ? trimmed.substring(5).trim() : trimmed;

  if (_dativOnlyVerbs.contains(key)) return 'dativ';
  if (_dativAndAkkusativVerbs.contains(key)) return 'akkusativ+dativ';
  if (_nominativOnlyVerbs.contains(key)) return 'nominativ';
  return 'akkusativ';
}
