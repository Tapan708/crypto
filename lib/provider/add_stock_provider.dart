import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final coinsProvider =
    StateNotifierProvider<CoinsNotifier, List<Map<String, dynamic>>>(
  (ref) => CoinsNotifier(),
);

class CoinsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> _allCoins = [];

  CoinsNotifier() : super([]) {
    loadCoins();
  }

  Future<void> loadCoins() async {
    final box = await Hive.openBox('coinsBox');
    final coins = box.get('allCoins', defaultValue: []);

    // ✅ Convert dynamic list into List<Map<String, dynamic>>
    _allCoins = (coins as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    state = _allCoins;
  }

  void filterCoins(String query) {
    if (query.isEmpty) {
      state = _allCoins;
    } else {
      state = _allCoins
          .where((coin) =>
              coin['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              coin['symbol'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
