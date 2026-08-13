// Düzenli ve düzensiz A1 fiilleri için şimdiki zaman (Präsens) çekimi üretir.
// Ayrılabilir fiiller bu kapsamda değil (ayrı bir konu: fiil + ayrılan ek).

class VerbConjugation {
  final String ich;
  final String du;
  final String erSieEs;
  final String wir;
  final String ihr;
  final String sieSie;

  const VerbConjugation({
    required this.ich,
    required this.du,
    required this.erSieEs,
    required this.wir,
    required this.ihr,
    required this.sieSie,
  });
}

// Kök ünlüsü değişen ya da tamamen düzensiz çekimlenen fiiller: (ich, du, er).
// wir/ihr/sie(Sie) bu fiillerde de değişmeyen kökten kuralla üretilir.
const _irregularOverrides = <String, (String, String, String)>{
  'essen': ('esse', 'isst', 'isst'),
  'fahren': ('fahre', 'fährst', 'fährt'),
  'gefallen': ('gefalle', 'gefällst', 'gefällt'),
  'geben': ('gebe', 'gibst', 'gibt'),
  'halten': ('halte', 'hältst', 'hält'),
  'helfen': ('helfe', 'hilfst', 'hilft'),
  'laufen': ('laufe', 'läufst', 'läuft'),
  'lesen': ('lese', 'liest', 'liest'),
  'nehmen': ('nehme', 'nimmst', 'nimmt'),
  'schlafen': ('schlafe', 'schläfst', 'schläft'),
  'sehen': ('sehe', 'siehst', 'sieht'),
  'sprechen': ('spreche', 'sprichst', 'spricht'),
  'treffen': ('treffe', 'triffst', 'trifft'),
  'waschen': ('wasche', 'wäschst', 'wäscht'),
  'empfehlen': ('empfehle', 'empfiehlst', 'empfiehlt'),
  'dürfen': ('darf', 'darfst', 'darf'),
  'mögen': ('mag', 'magst', 'mag'),
  'wollen': ('will', 'willst', 'will'),
  'haben': ('habe', 'hast', 'hat'),
  'werden': ('werde', 'wirst', 'wird'),
  'wissen': ('weiß', 'weißt', 'weiß'),
};

// Kökü ünsüz kümesi + m/n ile biten (öffnen, regnen gibi) ve bu yüzden
// du/er/ihr çekiminde araya "e" giren, t/d dışındaki istisna kökler.
const _extraEpentheticStems = {'öffn', 'regn'};

bool _needsEpentheticE(String stem) {
  if (stem.endsWith('t') || stem.endsWith('d')) return true;
  return _extraEpentheticStems.contains(stem);
}

bool _isSibilantStem(String stem) {
  return stem.endsWith('s') ||
      stem.endsWith('ß') ||
      stem.endsWith('z') ||
      stem.endsWith('x');
}

String _baseStem(String infinitive) {
  if (infinitive.endsWith('ern')) return infinitive.substring(0, infinitive.length - 1);
  if (infinitive.endsWith('en')) return infinitive.substring(0, infinitive.length - 2);
  if (infinitive.endsWith('n')) return infinitive.substring(0, infinitive.length - 1);
  return infinitive;
}

// Kelimenin şimdiki zaman çekimini üretir. Sadece düzenli/düzensiz (ayrılabilir
// olmayan) fiiller için anlamlıdır; başka bir wordType için null döner.
VerbConjugation? conjugatePresentTense(String word, String? wordType) {
  if (wordType != 'regularVerb' && wordType != 'irregularVerb') return null;

  final trimmed = word.trim();
  final isReflexive = trimmed.toLowerCase().startsWith('sich ');
  final infinitive = isReflexive ? trimmed.substring(5).trim() : trimmed;
  final key = infinitive.toLowerCase();

  if (key == 'sein') {
    const base = VerbConjugation(
      ich: 'bin',
      du: 'bist',
      erSieEs: 'ist',
      wir: 'sind',
      ihr: 'seid',
      sieSie: 'sind',
    );
    return base;
  }

  final stem = _baseStem(infinitive);
  final epenthetic = _needsEpentheticE(stem);
  final override = _irregularOverrides[key];

  final ich = override?.$1 ?? '${stem}e';
  final du = override?.$2 ??
      (_isSibilantStem(stem) ? '${stem}t' : (epenthetic ? '${stem}est' : '${stem}st'));
  final er = override?.$3 ?? (epenthetic ? '${stem}et' : '${stem}t');
  final ihr = epenthetic ? '${stem}et' : '${stem}t';

  if (!isReflexive) {
    return VerbConjugation(
      ich: ich,
      du: du,
      erSieEs: er,
      wir: infinitive,
      ihr: ihr,
      sieSie: infinitive,
    );
  }

  return VerbConjugation(
    ich: '$ich mich',
    du: '$du dich',
    erSieEs: '$er sich',
    wir: '$infinitive uns',
    ihr: '$ihr euch',
    sieSie: '$infinitive sich',
  );
}
