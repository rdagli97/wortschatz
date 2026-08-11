import 'package:flutter/material.dart';

/// Wortschatz'ın tüm renk paleti.
class AppColors {
  AppColors._();

  // Zemin renkleri (temiz, öğrenmeye odaklı — koyu tema)
  static const Color background = Color(0xFF16181D);
  static const Color surface = Color(0xFF1F2229);
  static const Color surfaceLight = Color(0xFF2A2E37);

  // Ana vurgu
  static const Color primary = Color(0xFF6C8EEF);        // chill blue
  static const Color primaryDark = Color(0xFF5878D4);

  // ARTİKEL RENKLERİ (öğrenmenin kalbi)
  static const Color der = Color(0xFF4A90E2);            // der → blue
  static const Color die = Color(0xFFE0457B);            // die → red/pink
  static const Color das = Color(0xFF3DB86A);            // das → green

  // Metin
  static const Color textPrimary = Color(0xFFF2F3F5);
  static const Color textSecondary = Color(0xFF9AA0AB);
  static const Color textMuted = Color(0xFF5C636E);

  // Durum
  static const Color error = Color(0xFFE0457B);
  static const Color divider = Color(0xFF2A2E37);

  /// Bir artikele göre rengini döndürür (der/die/das).
  static Color forArticle(String article) {
    switch (article.toLowerCase()) {
      case 'der':
        return der;
      case 'die':
        return die;
      case 'das':
        return das;
      default:
        return textSecondary;
    }
  }
}