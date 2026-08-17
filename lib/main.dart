import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wortschatz/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

void main() {
  // sqflite'ın native platform channel'ı sadece Android/iOS/macOS'ta var;
  // Windows/Linux masaüstünde FFI tabanlı sqlite3 implementasyonuna geçiyoruz.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ProviderScope(child: WortschatzApp()));
}

class WortschatzApp extends StatelessWidget {
  const WortschatzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(),
    );
  }
}