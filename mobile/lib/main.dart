import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const AmaratiApp());
}

class AmaratiApp extends StatelessWidget {
  const AmaratiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amarati',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', '')],
      locale: const Locale('ar', ''),
      home: const SplashPage(),
    );
  }
}
