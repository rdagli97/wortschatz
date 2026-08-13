class AppStrings {
  AppStrings._();

  static const String appName = 'Wortschatz';

  // Ana sayfa
  static const String words = 'Kelimeler';
  static const String regularVerbs = 'Düzenli Fiiller';
  static const String irregularVerbs = 'Düzensiz Fiiller';
  static const String separableVerbs = 'Ayrılabilir Fiiller';
  static const String conjunctions = 'Bağlaçlar';
  static const String comingSoon = 'Yakında';
  static const String verbToEnd = 'Fiili sona gönderir';
  static const String verbStaysSecond = 'Fiili 2. sırada bırakır';
  static const String presentTenseConjugation = 'Şimdiki Zaman Çekimi';
  static const String verbCaseAkkusativ = 'Akkusativ alır';
  static const String verbCaseDativ = 'Dativ alır';
  static const String verbCaseBoth = 'Dativ + Akkusativ alır';
  static const String verbCaseNominativ = 'Nesne almaz';

  // Çalışma alanı / seviye ilerleme takibi
  static const String statsTotalLabel = 'Toplam';
  static const String statsDifficultLabel = 'Zorlanılan';
  static const String statsLearnedLabel = 'Öğrenilen';
  static const String statsEmptyLabel = 'Henüz kelime yok';

  // Kelimeler ana sayfası (Benim Çalışma Alanım / Goethe)
  static const String myWorkspace = 'Benim Çalışma Alanım';
  static const String myWorkspaceDesc = 'Kendi eklediğin kelimeler';
  static const String goethe = 'Goethe';
  static const String goetheDesc = 'Goethe seviyelerine göre hazır listeler';
  static const String goetheA1 = 'A1';
  static const String goetheA2 = 'A2';
  static const String goetheB1 = 'B1';
  static const String noGoetheWordsYet = 'Bu seviyede henüz kelime yüklenmedi.';

  // AI ile Öğren
  static const String aiLearn = 'AI ile Öğren';
  static const String aiLearnDesc = 'Gemini ile öğren, sorularını sor';
  static const String askAiTitle = 'Merak Ettiğini Sor';
  static const String askAiDesc = 'Anlamadığın bir konuyu yaz, yapay zeka basitçe anlatsın';
  static const String askAiInputLabel = 'Merak ettiğin konu (örn. "ins - zu farkı")';
  static const String askAiButton = 'Sor';
  static const String askAiGenerating = 'Konu anlatılıyor...';
  static const String askAiHistoryTitle = 'Daha Önce Sorduklarım';
  static const String askAiEmptyHistory =
      'Henüz bir şey sormadın. Merak ettiğin bir konuyu yaz!';
  static const String askAiGenericError = 'Konu anlatılamadı. Tekrar dener misin?';

  // Hikaye Oku
  static const String storyRead = 'Hikaye Oku';
  static const String storyReadDesc = 'Seviyene uygun kısa bir Almanca hikaye okusun yapay zeka';
  static const String storyTopicInputLabel =
      'İstersen bir konu yaz (boş bırakırsan yapay zeka seçsin)';
  static const String storyGenerateButton = 'Hikaye Oluştur';
  static const String storyGenerating = 'Hikaye yazılıyor...';
  static const String storyHistoryTitle = 'Daha Önce Okuduklarım';
  static const String storyEmptyHistory =
      'Henüz bir hikaye okumadın. Yukarıdan yeni bir tane oluştur!';
  static const String storyDone = 'Bitti';
  static const String storyTapHint =
      'Kelimelere dokun: anlamını gör, çalışma alanına ekle.';
  static const String storyWordAddButton = 'Çalışma Alanına Ekle';
  static const String storyWordPickWorkspace = 'Hangi çalışma alanına eklemek istersin?';

  // Çalışma alanları (Benim Çalışma Alanım altındaki koleksiyonlar)
  static const String defaultWorkspaceName = 'Varsayılan Çalışma Alanı';
  static const String newWorkspace = 'Yeni Çalışma Alanı';
  static const String newWorkspaceDialogTitle = 'Yeni Çalışma Alanı Oluştur';
  static const String workspaceNameLabel = 'Çalışma Alanı Adı';
  static const String cancel = 'İptal';
  static const String create = 'Oluştur';
  static const String delete = 'Sil';
  static const String deleteWorkspaceTitle = 'Çalışma Alanını Sil';

  // Kelime kategorileri
  static const String allWords = 'Tüm Kelimeler';
  static const String newlyAddedWords = 'Yeni Eklenenler';
  static const String difficultWords = 'Zorlanılan Kelimeler';
  static const String wellLearnedWords = 'İyi Öğrenilmiş Kelimeler';

  // Kelime listesi
  static const String myWords = 'Kelimelerim';
  static const String practice = 'Tekrar Et';
  static const String addWord = 'Kelime Ekle';
  static const String noWordsYet = 'Henüz kelime yok. İlk kelimeni ekle!';
  static const String duplicateWordError = 'Bu kelime zaten listende var.';

  // Alıştırma (Tekrar Et / Test Modu seçimi)
  static const String exercise = 'Alıştırma';
  static const String exerciseModeSheetTitle = 'Nasıl çalışmak istersin?';
  static const String exercisePracticeTitle = 'Tekrar Et';
  static const String exercisePracticeDesc = 'Kartları çevirerek gözden geçir';
  static const String exerciseTestTitle = 'Test Modu';
  static const String exerciseTestDesc = 'Almancasını yazarak kendini sına';
  static const String practiceSetupWordCountQuestion =
      'Kaç kelimeyi tekrar etmek istiyorsun?';

  // Test modu kurulumu
  static const String testSetupTitle = 'Test Modu';
  static const String testSetupWordCountQuestion =
      'Kaç kelimeden sınav olmak istiyorsun?';
  static const String testSetupStart = 'Başla';

  // Test modu (soru ekranı)
  static const String testWriteHint = 'Almancasını yaz';
  static const String testSeeResult = 'Sonucu Gör';

  // Test sonucu
  static const String testResultTitle = 'Sonuç';
  static const String testResultCorrectSuffix = 'doğru cevap';
  static const String testResultYourAnswer = 'Senin cevabın';
  static const String testResultDone = 'Bitti';
  static const String testResultRetryWrong = 'Yanlışları Test Et';

  // Kelime detayı
  static const String categoryNew = 'Yeni';
  static const String categoryDifficult = 'Zorlanılan';
  static const String categoryWellLearned = 'İyi Öğrenilmiş';
  static const String timesReviewed = 'Tekrar Sayısı';
  static const String correctStreakLabel = 'Doğru Serisi';
  static const String noNewWordsYet = 'Yeni eklenmiş kelime yok.';
  static const String noDifficultWordsYet = 'Henüz zorlanılan kelime yok.';
  static const String noWellLearnedWordsYet = 'Henüz iyi öğrenilmiş kelime yok.';

  // Kelime ekleme
  static const String article = 'Artikel';
  static const String word = 'Kelime';
  static const String plural = 'Çoğul Hali';
  static const String exampleSentence = 'Örnek Cümle';
  static const String exampleTranslation = 'Türkçe Çevirisi';
  static const String save = 'Kaydet';

  // Kelime ekleme modu seçimi
  static const String addWordManual = 'Manuel Ekle';
  static const String addWordManualDesc = 'Tüm alanları kendin doldur';
  static const String addWordAi = 'Yapay Zeka ile Ekle';
  static const String addWordAiDesc = 'Sadece kelimeyi yaz, gerisini AI doldursun';
  static const String addWordBulk = 'Çoklu Kelime Ekle';
  static const String addWordBulkDesc = 'Virgülle ayırarak birden fazla kelime aynı anda ekle';

  // Çoklu kelime ekleme
  static const String bulkAddTitle = 'Çoklu Kelime Ekle';
  static const String bulkAddInputLabel =
      'Kelimeleri virgülle ayırarak yaz (ör. Haus, gehen, schön)';
  static const String bulkAddMaxHint =
      'Ücretsiz Gemini anahtarının dakikalık limiti nedeniyle tek seferde en '
      'fazla 5 kelime ekleyebilirsin.';
  static const String bulkAddStart = 'Kelimeleri Ekle';
  static const String bulkAddDone = 'Bitti';
  static const String bulkAddStatusAdded = 'Eklendi';
  static const String bulkAddStatusDuplicate = 'Zaten var';
  static const String bulkAddStatusError = 'Eklenemedi';
  static const String bulkAddStatusPending = 'Bekliyor';
  static const String bulkAddStatusChecking = 'Kontrol ediliyor...';

  // Yapay zeka modu
  static const String aiAddWordTitle = 'Yapay Zeka ile Ekle';
  static const String aiWordInputLabel = 'Almanca Kelime';
  static const String aiGenerate = 'Getir';
  static const String aiGenerating = 'Kelime bilgileri hazırlanıyor...';
  static const String aiReviewHint = 'AI\'ın doldurduğu bilgileri kontrol et, istersen düzenle.';
  static const String aiNoApiKeyError =
      'Önce ayarlardan Gemini API anahtarını girmelisin.';
  static const String aiGenericError =
      'Kelime bilgileri alınamadı. Tekrar dener misin?';
  static const String aiInvalidKeyError =
      'API anahtarı geçersiz görünüyor. Ayarlardan kontrol et.';
  static const String goToSettings = 'Ayarlara Git';

  // Ayarlar
  static const String settings = 'Ayarlar';
  static const String geminiApiKey = 'Google Gemini API Anahtarı';
  static const String geminiApiKeyHint = 'AIzaSy...';
  static const String apiKeySaved = 'API anahtarı kaydedildi.';
  static const String apiKeyCleared = 'API anahtarı silindi.';
  static const String clearApiKey = 'Anahtarı Sil';
  static const String apiKeyInfo =
      'Anahtarın sadece bu cihazda, şifreli olarak saklanır ve yalnızca '
      'Google\'a kelime bilgisi almak için gönderilir. Ücretsiz bir anahtarı '
      'aistudio.google.com üzerinden alabilirsin.';

  // Flash card
  static const String tapToReveal = 'Görmek için dokun';
  static const String next = 'Sonraki';
  static const String practiceComplete = 'Tebrikler! Tüm kelimeleri gördün.';
}