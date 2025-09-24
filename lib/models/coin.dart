class Coin {
  final String id;
  final String symbol;
  final String name;

  Coin({required this.id, required this.symbol, required this.name});

  factory Coin.fromMap(Map<String, dynamic> map) {
    return Coin(
      id: map['id'],
      symbol: map['symbol'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'symbol': symbol,
        'name': name,
      };
}
