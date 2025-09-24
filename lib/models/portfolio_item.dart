class PortfolioItem {
  final String coinId;
  final String name;
  final String symbol;
  final double quantity;
  final double currentPrice;

  PortfolioItem({
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.quantity,
    this.currentPrice = 0.0,
  });

  /// Computed total value
  double get totalValue => quantity * currentPrice;

  /// copyWith method
  PortfolioItem copyWith({
    String? coinId,
    String? name,
    String? symbol,
    double? quantity,
    double? currentPrice,
  }) {
    return PortfolioItem(
      coinId: coinId ?? this.coinId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  Map<String, dynamic> toMap() => {
        'coinId': coinId,
        'name': name,
        'symbol': symbol,
        'quantity': quantity,
        'currentPrice': currentPrice,
      };

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      coinId: map['coinId'],
      name: map['name'],
      symbol: map['symbol'],
      quantity: (map['quantity'] as num).toDouble(),
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
