const _germanArticles = {'der', 'die', 'das'};

/// Kullanıcı kelimeyi artikeliyle birlikte yazdıysa (ör. "das Haus") başındaki
/// artikeli ayıklar; öyle olmayan kelimeleri değiştirmeden döner. Bu sayede
/// AI'ın ayrıca döndürdüğü artikelle birleşince "das das Haus" gibi
/// mükerrer bir sonuç oluşmaz.
String stripLeadingGermanArticle(String word) {
  final trimmed = word.trim();
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length > 1 && _germanArticles.contains(parts.first.toLowerCase())) {
    return parts.skip(1).join(' ');
  }
  return trimmed;
}
