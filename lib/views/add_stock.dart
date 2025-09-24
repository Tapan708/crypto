
import 'package:crypto_app/custom/custom_dialog.dart';
import 'package:crypto_app/models/portfolio_item.dart';
import 'package:crypto_app/provider/porfolio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/coins_provider.dart';

class AddStockScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);
    final portfolio = ref.watch(portfolioProvider); // Watch current portfolio

    return Scaffold(
      appBar: AppBar(title: Text("Add Stock"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Coin",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(coinsProvider.notifier).filterCoins(value),
            ),
          ),
          Expanded(
            child: coins.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: coins.length,
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      return ListTile(
                        title: Text(coin.name),
                        subtitle: Text(coin.symbol),
                        onTap: () {
                          // Check if coin already exists in portfolio
                          final exists = portfolio.items.any((item) => item.coinId == coin.id);

                          if (exists) {
                            // Show error dialog if coin already exists
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Already Added"),
                                content: Text(
                                  "${coin.name} is already in your portfolio.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Show quantity dialog if not exists
                            showDialog(
                              context: context,
                              builder: (_) => QuantityDialog(
                                coinName: coin.name,
                                onBuy: (quantity) {
                                  ref
                                      .read(portfolioProvider.notifier)
                                      .addOrUpdateItem(
                                        PortfolioItem(
                                          coinId: coin.id,
                                          name: coin.name,
                                          symbol: coin.symbol,
                                          quantity: quantity.toDouble(),
                                        ),
                                      );
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
