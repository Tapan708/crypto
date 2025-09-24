// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';

// // Coin Model
// class Coin {
//   final String id;
//   final String name;
//   final String symbol;

//   Coin({required this.id, required this.name, required this.symbol});

//   factory Coin.fromJson(Map<String, dynamic> json) {
//     return Coin(
//       id: json['id'],
//       name: json['name'],
//       symbol: json['symbol'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'symbol': symbol,
//     };
//   }
// }

// // PortfolioItem Model
// class PortfolioItem {
//   final String coinId;
//   final double quantity;

//   PortfolioItem({required this.coinId, required this.quantity});

//   factory PortfolioItem.fromJson(Map<String, dynamic> json) {
//     return PortfolioItem(
//       coinId: json['coinId'],
//       quantity: json['quantity'].toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'coinId': coinId,
//       'quantity': quantity,
//     };
//   }
// }

// // StorageService
// class StorageService {
//   static const String _coinMapKey = 'coin_map';
//   static const String _portfolioKey = 'portfolio';

//   Future<void> saveCoinMap(Map<String, Coin> coinMap) async {
//     final prefs = await SharedPreferences.getInstance();
//     final Map<String, dynamic> jsonMap = coinMap.map((key, value) => MapEntry(key, value?.toJson() ?? {}));
//     await prefs.setString(_coinMapKey, jsonEncode(jsonMap));
//   }

//   Future<Map<String, Coin>> loadCoinMap() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? coinData = prefs.getString(_coinMapKey);
//     if (coinData != null) {
//       final Map<String, dynamic> jsonMap = jsonDecode(coinData);
//       return jsonMap.map((key, value) => MapEntry(key, Coin.fromJson(value)));
//     }
//     return {};
//   }

//   Future<void> savePortfolio(List<PortfolioItem> portfolio) async {
//     final prefs = await SharedPreferences.getInstance();
//     final json = portfolio.map((e) => e.toJson()).toList();
//     await prefs.setString(_portfolioKey, jsonEncode(json));
//   }

//   Future<List<PortfolioItem>> loadPortfolio() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? portfolioData = prefs.getString(_portfolioKey);
//     if (portfolioData != null) {
//       final List<dynamic> json = jsonDecode(portfolioData);
//       return json.map((e) => PortfolioItem.fromJson(e)).toList();
//     }
//     return [];
//   }
// }

// // CoinRepository
// class CoinRepository {
//   final StorageService _storageService = StorageService();
//   final Dio _dio = Dio();

//   Future<Map<String, Coin>> fetchAndStoreCoinList() async {
//     try {
//       final response = await _dio.get('https://api.coingecko.com/api/v3/coins/list');
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         final Map<String, Coin> coinMap = {
//           for (var item in data) item['id']: Coin.fromJson(item)
//         };
//         await _storageService.saveCoinMap(coinMap);
//         return coinMap;
//       } else {
//         throw Exception('Failed to fetch coin list: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching coin list: $e');
//     }
//   }

//   Future<Map<String, Coin>> getCoinMap() async {
//     return await _storageService.loadCoinMap();
//   }

//   Future<Map<String, double>> fetchPrices(List<String> coinIds) async {
//     try {
//       print('Fetching prices for IDs: $coinIds'); // Debug coin IDs
//       final ids = coinIds.join(',');
//       final response = await _dio.get(
//         'https://api.coingecko.com/api/v3/simple/price?ids=$ids&vs_currencies=usd',
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = response.data;
//         final Map<String, double> prices = data.map((key, value) => MapEntry(key, value['usd']?.toDouble() ?? 0.0));
//         print('Fetched prices: $prices'); // Debug price data
//         return prices;
//       } else if (response.statusCode == 429) {
//         print('Rate limit hit (429). Using previous prices.'); // Log rate limit
//         return {}; // Return empty map to use previous prices
//       } else {
//         throw Exception('Failed to fetch prices: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (e is DioException && e.response?.statusCode == 429) {
//         print('Rate limit error (429): $e. Try again in 1 minute.'); // Specific 429 handling
//         return {}; // Return empty to use previous prices
//       }
//       print('Error fetching prices: $e'); // Debug error
//       return {};
//     }
//   }
// }

// // AddAssetScreen
// class AddAssetScreen extends StatefulWidget {
//   final Map<String, Coin> coinMap;
//   final Function(String, double) onAddAsset;

//   const AddAssetScreen({super.key, required this.coinMap, required this.onAddAsset});

//   @override
//   _AddAssetScreenState createState() => _AddAssetScreenState();
// }

// class _AddAssetScreenState extends State<AddAssetScreen> {
//   String? selectedCoinId;
//   String quantityInput = '';
//   List<Coin> filteredCoins = [];

//   void filterCoins(String query) {
//     setState(() {
//       filteredCoins = widget.coinMap.values.where((coin) =>
//           coin.name.toLowerCase().contains(query.toLowerCase()) ||
//           coin.symbol.toLowerCase().contains(query.toLowerCase())).toList();
//       print('Filtered coins count for "$query": ${filteredCoins.length}');
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     filterCoins(''); // Initial filter
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Asset'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: const InputDecoration(labelText: 'Search Coin', border: OutlineInputBorder()),
//               onChanged: filterCoins,
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredCoins.length,
//                 itemBuilder: (context, index) {
//                   final coin = filteredCoins[index];
//                   return ListTile(
//                     title: Text('${coin.name} (${coin.symbol})'),
//                     onTap: () {
//                       setState(() {
//                         selectedCoinId = coin.id;
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//             if (selectedCoinId != null) ...[
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) => setState(() => quantityInput = value),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       if (selectedCoinId == null || quantityInput.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please select a coin and enter a quantity')),
//                         );
//                         return;
//                       }
//                       final quantity = double.tryParse(quantityInput);
//                       if (quantity == null || quantity <= 0) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please enter a valid positive quantity')),
//                         );
//                         return;
//                       }
//                       widget.onAddAsset(selectedCoinId!, quantity);
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Save'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel'),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // PortfolioScreen
// class PortfolioScreen extends StatefulWidget {
//   const PortfolioScreen({super.key});

//   @override
//   _PortfolioScreenState createState() => _PortfolioScreenState();
// }

// class _PortfolioScreenState extends State<PortfolioScreen> {
//   final CoinRepository _coinRepository = CoinRepository();
//   final StorageService _storageService = StorageService();
//   List<PortfolioItem> _portfolio = [];
//   Map<String, double> _prices = {};
//   bool _isLoading = true;
//   bool _isPriceLoading = false;
//   String? _errorMessage;
//   late Map<String, Coin> _coinMap;

//   @override
//   void initState() {
//     super.initState();
//     _preloadCoinMap();
//     _fetchInitialData();
//     _loadPortfolio();
//   }

//   Future<void> _preloadCoinMap() async {
//     _coinMap = await _coinRepository.getCoinMap();
//     if (_coinMap.isEmpty) {
//       await _fetchInitialData();
//       _coinMap = await _coinRepository.getCoinMap();
//     }
//     print('Preloaded coin map size: ${_coinMap.length}');
//   }

//   Future<void> _fetchInitialData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final coinMap = await _coinRepository.fetchAndStoreCoinList();
//       print('Fetched coin count: ${coinMap.length}');
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadPortfolio() async {
//     final portfolio = await _storageService.loadPortfolio();
//     setState(() {
//       _portfolio = portfolio;
//     });
//     _fetchPrices();
//   }

//   Future<void> _fetchPrices() async {
//     if (_portfolio.isEmpty) return;
//     setState(() {
//       _isPriceLoading = true;
//     });
//     try {
//       final coinIds = _portfolio.map((item) => item.coinId).toList();
//       print('Fetching prices for coin IDs: $coinIds'); // Debug coin IDs being fetched
//       final prices = await _coinRepository.fetchPrices(coinIds);
//       if (prices.isNotEmpty) {
//         setState(() {
//           _prices = prices;
//         });
//       }
//     } catch (e) {
//       if (e is DioException && e.response?.statusCode == 429) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Rate limit reached. Try again in 1 minute.')),
//         );
//         // Keep previous prices, no state update needed
//       } else {
//         setState(() {
//           _errorMessage = 'Error fetching prices: $e';
//         });
//       }
//     } finally {
//       setState(() {
//         _isPriceLoading = false;
//       });
//     }
//   }

//   void _addAsset(String coinId, double quantity) {
//     print('Adding asset: $coinId with quantity $quantity'); // Debug added asset
//     final existingItem = _portfolio.firstWhere(
//       (item) => item.coinId == coinId,
//       orElse: () => PortfolioItem(coinId: '', quantity: 0),
//     );
//     setState(() {
//       if (existingItem.coinId.isNotEmpty) {
//         _portfolio.remove(existingItem);
//         _portfolio.add(PortfolioItem(coinId: coinId, quantity: existingItem.quantity + quantity));
//       } else {
//         _portfolio.add(PortfolioItem(coinId: coinId, quantity: quantity));
//       }
//     });
//     _storageService.savePortfolio(_portfolio);
//     _fetchPrices();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double totalValue = _portfolio.fold(0.0, (sum, item) {
//       return sum + (_prices[item.coinId] ?? 0) * item.quantity;
//     });

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Portfolio', style: Theme.of(context).textTheme.headlineSmall),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _fetchPrices,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//                 ? Center(child: Text(_errorMessage!))
//                 : Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           'Total Portfolio Value: ${totalValue.toString()}',
//                           style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       Expanded(
//                         child: _isPriceLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : _portfolio.isEmpty
//                                 ? const Center(child: Text('No assets added yet'))
//                                 : ListView.builder(
//                                     itemCount: _portfolio.length,
//                                     itemBuilder: (context, index) {
//                                       final item = _portfolio[index];
//                                       final coin = _coinMap[item.coinId] ?? Coin(id: item.coinId, name: 'Unknown', symbol: 'UNK');
//                                       final price = _prices[item.coinId] ?? 0.0;
//                                       final total = price * item.quantity;
//                                       return Card(
//                                         margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                                         child: ListTile(
//                                           leading: Text(
//                                             coin.symbol,
//                                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//                                           ),
//                                           title: Text(
//                                             coin.name,
//                                             style: Theme.of(context).textTheme.bodyMedium,
//                                           ),
//                                           subtitle: Text(
//                                             'Qty: ${item.quantity}',
//                                             style: Theme.of(context).textTheme.bodySmall,
//                                           ),
//                                           trailing: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             crossAxisAlignment: CrossAxisAlignment.end,
//                                             children: [
//                                               Text(
//                                                 price > 0
//                                                     ? 'Price: ${price.toString()}'
//                                                     : 'Price: 0.0',
//                                                 style: Theme.of(context).textTheme.bodySmall,
//                                               ),
//                                               Text(
//                                                 'Total: ${total.toString()}',
//                                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                       ),
//                     ],
//                   ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddAssetScreen(
//               coinMap: _coinMap,
//               onAddAsset: _addAsset,
//             ),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PorfolioScreen extends StatelessWidget {
  const PorfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}