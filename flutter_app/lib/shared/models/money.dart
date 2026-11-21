enum Currency { usd, khr }

class Money {
  final double amount;
  final Currency currency;

  const Money({
    required this.amount,
    this.currency = Currency.usd,
  });

  static const double usdToKhrRate = 4100.0;

  double get inUsd => currency == Currency.usd ? amount : amount / usdToKhrRate;
  double get inKhr => currency == Currency.khr ? amount : amount * usdToKhrRate;

  String format({Currency? targetCurrency}) {
    final cur = targetCurrency ?? currency;
    if (cur == Currency.usd) {
      return '\$${inUsd.toStringAsFixed(2)}';
    } else {
      final formatted = inKhr
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return '$formatted ៛';
    }
  }

  String formatDual() {
    final usd = '\$${inUsd.toStringAsFixed(2)}';
    final khr = format(targetCurrency: Currency.khr);
    return '$usd ($khr)';
  }

  @override
  String toString() => format();
}
