import 'dart:async';
import 'package:crypto_app/provider/porfolio_provider.dart';
import 'package:crypto_app/utils/app_color.dart';
import 'package:crypto_app/utils/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final _currencyFormatter = NumberFormat.currency(symbol: "\$");
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    ref.read(portfolioProvider.notifier).loadPortfolio();

    // Auto-refresh every 1.5 minutes
    _timer = Timer.periodic(const Duration(seconds: 90), (_) {
      ref.read(portfolioProvider.notifier).updatePrices();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final portfolioNotifier = ref.read(portfolioProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    if (portfolioState.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Portfolio")),
        body: Center(
          child: Text(
            portfolioState.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Portfolio",
          style: textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push(RoutesPath.addStock),
      ),
      body: portfolioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: portfolioNotifier.updatePrices,
              child: portfolioState.items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 150),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 80,
                                color: AppColor.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Your portfolio is empty",
                                style: textTheme.headlineSmall!.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Start adding assets to track your investments",
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium!.copyWith(
                                  fontSize: 14,
                                  color: AppColor.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: portfolioState.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          double totalValue = portfolioState.items.fold(
                              0.0, (sum, item) => sum + item.totalValue);
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Total Portfolio Value",
                                      style: textTheme.bodySmall!.copyWith(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _currencyFormatter.format(totalValue),
                                      style: textTheme.headlineSmall!.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 28,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          final item = portfolioState.items[index - 1];
                          return Dismissible(
                            key: ValueKey(item.coinId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) =>
                                portfolioNotifier.removeItem(item.coinId),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColor.primary.withOpacity(0.1),
                                  child: Text(
                                    item.symbol.toUpperCase(),
                                    style: textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColor.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: textTheme.headlineSmall!.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  "Qty: ${item.quantity}",
                                  style: textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: AppColor.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Price: ${_currencyFormatter.format(item.currentPrice)}",
                                      style: textTheme.bodyMedium!.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Total: ${_currencyFormatter.format(item.totalValue)}",
                                      style: textTheme.bodyMedium!.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
    );
  }
}
