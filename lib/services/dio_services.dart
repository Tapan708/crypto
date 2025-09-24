import 'package:dio/dio.dart';

class DioServices {
  // Singleton instance
  static final DioServices _instance = DioServices._internal();
  factory DioServices() => _instance;
  DioServices._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );
  }

  late Dio _dio;

  // Base URL for CoinGecko API
  final String _baseUrl = "https://api.coingecko.com/api/v3";

  Dio get dio => _dio;

  /// Fetch list of coins
  Future<List?> fetchCoins() async {
    try {
      final response = await _dio.get('/coins/list');
      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List coins = response.data;
        print('✅ API Response received. Total coins: ${coins.length}');
        return coins;
      } else {
        print('⚠️ API call failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching coins: $e');
      return null;
    }
  }
}
