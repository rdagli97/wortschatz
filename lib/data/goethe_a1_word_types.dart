// A1 kelime listesindeki artikelsiz kelimelerin (fiil/bağlaç) sınıflandırması.
// article'ı olan kelimeler zaten isim olduğu için burada yer almaz; burada
// sınıflandırılmayan (null dönen) her kelime "Kelimeler" sekmesinde kalır
// (isimler, soru kelimeleri, sıfat/zarflar, edatlar vb.).

// Ayrılabilir fiiller (trennbare Verben)
const _separableVerbsA1 = {
  'abfahren', 'abfliegen', 'abgeben', 'abholen',
  'an sein', 'anbieten', 'anfangen', 'anklicken', 'ankommen', 'ankreuzen',
  'anmachen', 'anrufen',
  'auf sein', 'aufhören', 'aufstehen',
  'aus sein', 'ausfüllen', 'ausmachen', 'aussehen', 'aussteigen',
  'einkaufen', 'einladen', 'einsteigen',
  'fernsehen',
  'kennenlernen',
  'mitbringen', 'mitkommen', 'mitmachen', 'mitnehmen',
  'rad fahren',
  'sich anmelden', 'sich anziehen', 'sich ausziehen', 'sich vorstellen',
  'umziehen',
  'weg sein', 'weh tun',
  'zu sein',
};

// Düzensiz fiiller (güçlü/karışık çekimli fiiller)
const _irregularVerbsA1 = {
  'beginnen', 'bekommen', 'bitten', 'bleiben', 'bringen', 'dürfen',
  'empfehlen', 'essen', 'fahren', 'finden', 'fliegen',
  'geben', 'gefallen', 'gehen', 'gewinnen',
  'haben', 'halten', 'heißen', 'helfen',
  'kennen', 'kommen',
  'laufen', 'lesen', 'liegen',
  'mögen',
  'nehmen',
  'riechen',
  'scheinen', 'schlafen', 'schließen', 'schreiben', 'schwimmen', 'sehen',
  'sein', 'sich treffen', 'sich waschen', 'sitzen', 'sprechen', 'stehen',
  'trinken', 'tun',
  'überweisen', 'unterschreiben',
  'verstehen',
  'werden', 'wissen', 'wollen',
};

// Düzenli fiiller (zayıf çekimli fiiller)
const _regularVerbsA1 = {
  'antworten', 'arbeiten',
  'baden', 'bedeuten', 'benutzen', 'besichtigen', 'bestellen', 'besuchen',
  'bezahlen', 'brauchen', 'buchstabieren',
  'danken', 'dauern', 'drucken', 'drücken',
  'enden', 'entschuldigen', 'erklären', 'erlauben', 'erzählen',
  'fehlen', 'feiern', 'fragen', 'frühstücken',
  'gehören', 'glauben', 'gratulieren', 'grillen',
  'heiraten', 'holen', 'hören',
  'kaufen', 'kochen', 'kosten', 'kriegen',
  'lachen', 'leben', 'legen', 'lernen', 'lieben',
  'machen', 'mieten',
  'öffnen',
  'rauchen', 'regnen', 'reisen', 'reparieren',
  'sagen', 'schicken', 'schmecken', 'sich duschen', 'sich freuen',
  'sich kümmern', 'spielen', 'stellen', 'studieren', 'suchen',
  'tanzen', 'telefonieren',
  'übernachten',
  'verdienen', 'verkaufen', 'vermieten',
  'wandern', 'warten', 'wiederholen', 'wohnen',
  'zahlen',
};

// Bağlaçlar (bu listede yer alan, tartışmasız bağlaç olan kelimeler)
const _conjunctionsA1 = {'und', 'oder', 'aber', 'denn'};

// Almanca'da fiili yan cümlenin sonuna gönderen yan cümle bağlaçları
// (unterordnende Konjunktionen). Bu, bağlaç sınıflandırmasından (_conjunctionsA1)
// bağımsız, saf bir dilbilgisi kuralı listesidir; ileride A2/B1 ile birlikte
// weil/dass/wenn gibi kelimeler bağlaç olarak eklendiğinde otomatik işler.
const _subordinatingConjunctions = {
  'weil', 'dass', 'ob', 'wenn', 'während', 'obwohl', 'obgleich', 'nachdem',
  'bevor', 'ehe', 'seitdem', 'sobald', 'solange', 'soweit', 'damit', 'indem',
  'falls', 'sodass',
};

// Verilen kelimeyi sınıflandırır; isim/soru kelimesi/sıfat-zarf gibi diğer
// tüm kelimeler için null döner (bunlar "Kelimeler" sekmesinde kalır).
String? classifyGoetheWordType(String word) {
  final normalized = word.trim().toLowerCase();
  if (_conjunctionsA1.contains(normalized)) return 'conjunction';
  if (_separableVerbsA1.contains(normalized)) return 'separableVerb';
  if (_irregularVerbsA1.contains(normalized)) return 'irregularVerb';
  if (_regularVerbsA1.contains(normalized)) return 'regularVerb';
  return null;
}

// Bir bağlacın fiili cümle sonuna gönderip göndermediğini döner.
// Bağlaç olarak sınıflandırılmamış kelimeler için null döner.
bool? conjunctionSendsVerbToEnd(String word) {
  final normalized = word.trim().toLowerCase();
  if (!_conjunctionsA1.contains(normalized)) return null;
  return _subordinatingConjunctions.contains(normalized);
}
