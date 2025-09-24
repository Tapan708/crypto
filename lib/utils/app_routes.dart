import 'package:crypto_app/utils/routes_path.dart';
import 'package:crypto_app/views/add_stock.dart';
import 'package:crypto_app/views/porfolio_screen.dart';
import 'package:crypto_app/views/splash_screen.dart';
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
        builder: (context, state) => PortfolioScreen(),
      ),
      GoRoute(
        path: RoutesPath.addStock,
        builder: (context, state) => AddStockScreen(),
      ),
    ],
  );
}