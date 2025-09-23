
import 'package:cryto/utils/app_routes.dart';
import 'package:cryto/utils/app_theme.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CryptoPortfolioApp();
  }
}

class CryptoPortfolioApp extends StatelessWidget {
  const CryptoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Crypto Portfolio Tracker',
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}