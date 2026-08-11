import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wortschatz/screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

void main() {
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