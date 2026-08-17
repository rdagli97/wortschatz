// Goethe B1 kelime listesindeki artikelsiz kelimelerin (fiil/bağlaç)
// sınıflandırması. Yöntem ve gerekçe için goethe_a1_word_types.dart'a bakın;
// buradaki kümeler classifyGoetheWordType ve conjunctionSendsVerbToEnd
// tarafından A1/A2 kümeleriyle birleştirilerek kullanılır.

// Ayrılabilir fiiller (trennbare Verben)
const separableVerbsB1 = {
  'abbiegen', 'abheben', 'abhängen', 'ablehnen', 'abmachen', 'abnehmen', 'absagen',
  'abschreiben', 'abstimmen', 'abwaschen', 'anerkennen', 'angeben', 'anhaben', 'ankündigen',
  'annehmen', 'anzeigen', 'auffallen', 'auffordern', 'aufführen', 'aufgeben', 'aufhalten',
  'aufheben', 'aufladen', 'auflösen', 'aufnehmen', 'aufschreiben', 'auftreten', 'aufwachen',
  'ausdrucken', 'ausfallen', 'ausreichen', 'ausrichten', 'ausschließen', 'ausstellen',
  'auswählen', 'bekannt geben', 'darstellen', 'einfallen', 'einfügen', 'einführen',
  'einnehmen', 'einrichten', 'einschalten', 'einsetzen', 'einstellen', 'eintragen',
  'eintreten', 'einzahlen', 'entgegenkommen', 'festhalten', 'festlegen', 'festnehmen',
  'festsetzen', 'feststehen', 'feststellen', 'fortsetzen', 'herausfinden', 'herunterfahren',
  'hinweisen', 'hochladen', 'kaputtgehen', 'kaputtmachen', 'leidtun', 'losfahren', 'mitteilen',
  'nachdenken', 'nachschlagen', 'runterwerfen', 'sich aufregen', 'sich aussuchen',
  'sich umdrehen', 'umgehen', 'umtauschen', 'vorhaben', 'vorkommen', 'vorlesen', 'vorschlagen',
  'zubereiten', 'zugehen', 'zumachen', 'zunehmen', 'zurechtkommen', 'zusagen',
  'zusammenfassen', 'zuschauen', 'zustimmen',
};

// Düzensiz fiiller (güçlü/karışık çekimli fiiller)
const irregularVerbsB1 = {
  'backen', 'behalten', 'beißen', 'beschließen', 'besitzen', 'besprechen', 'betrügen',
  'beweisen', 'bieten', 'brechen', 'brennen', 'empfangen', 'enthalten', 'entlassen',
  'entscheiden', 'entstehen', 'erfahren', 'erfinden', 'erhalten', 'erkennen', 'erschrecken',
  'erziehen', 'fangen', 'fliehen', 'fließen', 'fressen', 'frieren', 'gelingen', 'gelten',
  'genießen', 'geschehen', 'gießen', 'greifen', 'heben', 'hinterlassen', 'klingen', 'lassen',
  'leiden', 'leihen', 'lügen', 'messen', 'nennen', 'raten', 'rennen', 'rufen', 'schieben',
  'schießen', 'schlagen', 'schreien', 'schweigen', 'senden', 'sich befinden',
  'sich entschließen', 'sich stoßen', 'sich verbrennen', 'sich verhalten', 'sich verlaufen',
  'singen', 'sinken', 'springen', 'stechen', 'stehlen', 'steigen', 'stinken', 'tragen',
  'treiben', 'treten', 'unterbrechen', 'unterlassen', 'unterscheiden', 'unterstreichen',
  'verbieten', 'verbinden', 'verbringen', 'verlassen', 'vermeiden', 'verraten', 'verschreiben',
  'verschwinden', 'versprechen', 'vertreten', 'verzeihen', 'wachsen', 'werfen',
  'widersprechen', 'wiegen', 'zwingen', 'überfahren', 'übernehmen', 'übertreiben',
};

// Düzenli fiiller (zayıf çekimli fiiller)
const regularVerbsB1 = {
  'abonnieren', 'achten', 'akzeptieren', 'analysieren', 'atmen', 'basteln', 'bauen',
  'beachten', 'beantragen', 'beantworten', 'bedienen', 'beeinflussen', 'begegnen', 'begleiten',
  'begrüßen', 'behandeln', 'behaupten', 'behindern', 'beleidigen', 'bemerken', 'benötigen',
  'beobachten', 'berechnen', 'beruhigen', 'beschränken', 'beschädigen', 'beschäftigen',
  'besetzen', 'besorgen', 'bestrafen', 'betreuen', 'bewegen', 'blitzen', 'bluten', 'blühen',
  'bremsen', 'dekorieren', 'dienen', 'donnern', 'drehen', 'duzen', 'eilen', 'entdecken',
  'entfernen', 'entsorgen', 'enttäuschen', 'entwickeln', 'erfordern', 'erfüllen', 'ergänzen',
  'erhöhen', 'erleben', 'erledigen', 'erleichtern', 'ernähren', 'ersetzen', 'erstellen',
  'erwarten', 'eröffnen', 'fassen', 'faulenzen', 'finanzieren', 'folgen', 'fordern',
  'funktionieren', 'fördern', 'fühlen', 'führen', 'füttern', 'garantieren', 'gebrauchen',
  'genehmigen', 'genügen', 'gründen', 'grüßen', 'gucken', 'hageln', 'handeln', 'hassen',
  'heizen', 'hupen', 'informieren', 'installieren', 'integrieren', 'klagen', 'klappen',
  'kleben', 'klettern', 'klicken', 'klingeln', 'klopfen', 'klären', 'konsumieren',
  'kontrollieren', 'kopieren', 'korrigieren', 'kritisieren', 'kämpfen', 'küssen', 'landen',
  'leisten', 'leiten', 'loben', 'lächeln', 'löschen', 'lösen', 'malen', 'markieren', 'melden',
  'mischen', 'nutzen', 'nähen', 'nützen', 'operieren', 'ordnen', 'pflanzen', 'pflegen',
  'produzieren', 'protestieren', 'präsentieren', 'prüfen', 'putzen', 'reagieren',
  'realisieren', 'rechnen', 'reden', 'reduzieren', 'regeln', 'reichen', 'reinigen', 'retten',
  'schaden', 'schalten', 'schauen', 'schwitzen', 'schätzen', 'schütteln', 'schützen',
  'sich amüsieren', 'sich bedanken', 'sich beeilen', 'sich bemühen', 'sich beteiligen',
  'sich eignen', 'sich einigen', 'sich ereignen', 'sich erholen', 'sich erkundigen',
  'sich erkälten', 'sich fürchten', 'sich gewöhnen', 'sich irren', 'sich konzentrieren',
  'sich langweilen', 'sich lohnen', 'sich nähern', 'sich rasieren', 'sich schminken',
  'sich setzen', 'sich siezen', 'sich trennen', 'sich verabreden', 'sich verabschieden',
  'sich verbessern', 'sich vergnügen', 'sich verstecken', 'sich verändern', 'sich weigern',
  'sich wundern', 'sich überlegen', 'sichern', 'siegen', 'sorgen', 'spülen', 'spüren',
  'stammen', 'starten', 'stecken', 'stimmen', 'stoppen', 'streiken', 'stürzen', 'tanken',
  'tauchen', 'testen', 'tippen', 'transportieren', 'trocknen', 'umarmen', 'unterrichten',
  'unterstützen', 'verbrauchen', 'vergrößern', 'verhaften', 'verhindern', 'verlangen',
  'verlängern', 'vermissen', 'vermuten', 'verpacken', 'verpflegen', 'verschmutzen',
  'versichern', 'versäumen', 'verteilen', 'vertrauen', 'verurteilen', 'verwechseln',
  'verwenden', 'verzichten', 'veröffentlichen', 'warnen', 'weinen', 'wenden', 'wetten',
  'winken', 'wirken', 'zeigen', 'zelten', 'zerstören', 'zweifeln', 'zählen', 'überholen',
  'überprüfen', 'überqueren', 'überraschen', 'überreden', 'überzeugen',
};

// Bağlaçlar (tartışmasız bağlaç olan kelimeler; fiili cümle sonuna gönderip
// göndermediği goethe_a1_word_types.dart'taki _subordinatingConjunctions
// listesinden belirlenir — bu liste zaten A1/A2/B1 ortak/seviye bağımsızdır)
const conjunctionsB1 = {
  'bevor', 'damit', 'entweder ... oder', 'falls', 'indem', 'nachdem', 'ob', 'obwohl',
  'seitdem', 'sobald', 'sodass', 'solange', 'sondern', 'weder ... noch', 'während',
};
