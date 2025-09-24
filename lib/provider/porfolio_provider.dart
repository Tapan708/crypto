import 'package:crypto_app/models/portfolio_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';

/// State with items, loading, and error message
class PortfolioState {
  final List<PortfolioItem> items;
  final bool isLoading;
  final String? errorMessage;

  PortfolioState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
  });

  PortfolioState copyWith({
    List<PortfolioItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PortfolioState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>(
        (ref) => PortfolioNotifier());

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier() : super(PortfolioState(items: [])) {
    loadPortfolio();
  }

  /// Load portfolio from Hive
  Future<void> loadPortfolio() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final box = await Hive.openBox('portfolioBox');
      final data = box.get('portfolio', defaultValue: []);
      final items = (data as List)
          .map((e) => PortfolioItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      state = state.copyWith(items: items, isLoading: false);
      await updatePrices();
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: "Failed to load portfolio: $e");
    }
  }

  /// Add or update portfolio item
  Future<void> addOrUpdateItem(PortfolioItem item) async {
    try {
      final index = state.items.indexWhere((e) => e.coinId == item.coinId);
      final newItems = List<PortfolioItem>.from(state.items);
      if (index >= 0) {
        newItems[index] = newItems[index]
            .copyWith(quantity: newItems[index].quantity + item.quantity);
      } else {
        newItems.add(item);
      }
      state = state.copyWith(items: newItems, errorMessage: null);
      await _saveToBox();
      await updatePrices();
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to add/update item: $e");
    }
  }

  /// Remove item
  Future<void> removeItem(String coinId) async {
    try {
      final newItems = state.items.where((e) => e.coinId != coinId).toList();
      state = state.copyWith(items: newItems, errorMessage: null);
      await _saveToBox();
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to remove item: $e");
    }
  }

  /// Update prices from API
  Future<void> updatePrices() async {
    if (state.items.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final ids = state.items.map((e) => e.coinId).join(',');
    final dio = Dio();

    try {
      final response = await dio.get(
          'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=usd');
      final prices = response.data as Map<String, dynamic>;

      final updatedItems = [
        for (var item in state.items)
          PortfolioItem(
            coinId: item.coinId,
            name: item.name,
            symbol: item.symbol,
            quantity: item.quantity,
            currentPrice: (prices[item.coinId]?['usd'] ?? 0.0).toDouble(),
          )
      ];

      state = state.copyWith(items: updatedItems, errorMessage: null);
      await _saveToBox();
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to update prices: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Save to Hive
  Future<void> _saveToBox() async {
    final box = await Hive.openBox('portfolioBox');
    await box.put('portfolio', state.items.map((e) => e.toMap()).toList());
  }
}
