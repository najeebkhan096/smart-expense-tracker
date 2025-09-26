class Currency {
  final String code; // e.g., USD, PKR, QAR
  final String symbol; // $, ₨, ر.ق
  final double rateToBase; // conversion rate to base currency (e.g., PKR)

  Currency({
    required this.code,
    required this.symbol,
    required this.rateToBase,
  });
}

class CurrencyManager {
  // Base currency is PKR
  static final List<Currency> currencies = [
    Currency(code: 'PKR', symbol: '₨', rateToBase: 1.0),
    Currency(code: 'USD', symbol: '\$', rateToBase: 220.0),
    Currency(code: 'EUR', symbol: '€', rateToBase: 240.0),
    Currency(code: 'SGD', symbol: 'S\$', rateToBase: 160.0),
    Currency(code: 'AED', symbol: 'د.إ', rateToBase: 77.0),
    Currency(code: 'QAR', symbol: 'ر.ق', rateToBase: 77.0), // Added QAR
  ];

  static Currency getCurrencyByCode(String code) {
    return currencies.firstWhere((c) => c.code == code, orElse: () => currencies.first);
  }

  /// Convert amount from given currency to base (PKR)
  static double toBase(double amount, String code) {
    final currency = getCurrencyByCode(code);
    return amount * currency.rateToBase;
  }

  /// Convert amount from base (PKR) to target currency
  static double fromBase(double baseAmount, String code) {
    final currency = getCurrencyByCode(code);
    return baseAmount / currency.rateToBase;
  }

  /// Format number with currency symbol
  static String format(double amount, String code) {
    final currency = getCurrencyByCode(code);
    return '${currency.code} ${amount.toStringAsFixed(2)}';
  }

  /// Convert from any currency to any currency
  static double convert(double amount, {required String from, required String to}) {
    final base = toBase(amount, from); // convert to PKR
    return fromBase(base, to);         // convert to target
  }

}
