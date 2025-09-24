import 'package:cryto/provider/add_stock_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStockScreen extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Stock"),
        centerTitle: true,
      ),
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
              onChanged: (value) => ref.read(coinsProvider.notifier).filterCoins(value),
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
                        title: Text(coin['name']),
                        subtitle: Text(coin['symbol']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}