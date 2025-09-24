import 'package:crypto_app/services/dio_services.dart';
import 'package:crypto_app/utils/app_color.dart';
import 'package:crypto_app/utils/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final DioServices _dioServices = DioServices(); // instance

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      await _checkFirstTime();
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool('isLogin') ?? false;

    if (!isLogin) {
      print('🚀 First time launch, fetching coins...');
      final coins = await _dioServices.fetchCoins();

      if (coins != null) {
        final box = await Hive.openBox('coinsBox');
        await box.put('allCoins', coins);
        print('💾 Coins saved in Hive → coinsBox');
      }

      await prefs.setBool('isLogin', true);
      print('✅ First time complete → isLogin set to true');
    } else {
      print('🔁 Not first time → skipping API call, loading coins from Hive');
    }

    if (mounted) {
      context.go(RoutesPath.portfolio);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'Crypto Portfolio',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: AppColor.primary,
                  fontSize: 36,
                ),
          ),
        ),
      ),
    );
  }
}
