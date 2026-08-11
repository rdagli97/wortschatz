import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  // Flash card için büyük kelime stili
  static const TextStyle flashcardWord = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Artikel için (renk sonradan verilecek)
  static const TextStyle article = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
}