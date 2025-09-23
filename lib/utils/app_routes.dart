import 'package:cryto/utils/routes_path.dart';
import 'package:cryto/views/porfolio_screen.dart';
import 'package:cryto/views/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutesPath.portfolio,
        builder: (context, state) => const portfolioScreen(),
      ),
    ],
  );
}