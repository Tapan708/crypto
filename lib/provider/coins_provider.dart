import 'package:crypto_app/models/coin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final coinsProvider =
    StateNotifierProvider<CoinsNotifier, List<Coin>>((ref) => CoinsNotifier());

class CoinsNotifier extends StateNotifier<List<Coin>> {
  CoinsNotifier() : super([]) {
    loadCoins();
  }

  Future<void> loadCoins() async {
    final box = await Hive.openBox('coinsBox');
    final coinsData = box.get('allCoins', defaultValue: []);
    try {
      state = (coinsData as List)
          .map((e) => Coin.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      state = [];
      print("Error parsing coins: $e");
    }
  }

  void filterCoins(String query) {
    final box = Hive.box('coinsBox');
    final coinsData = box.get('allCoins', defaultValue: []);
    final allCoins = (coinsData as List)
        .map((e) => Coin.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    if (query.isEmpty) {
      state = allCoins;
    } else {
      state = allCoins
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
