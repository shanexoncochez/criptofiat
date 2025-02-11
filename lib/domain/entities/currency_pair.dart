import 'package:equatable/equatable.dart';

class CurrencyPair extends Equatable {
  factory CurrencyPair.fromJson(Map<String, dynamic> json) {
    return CurrencyPair(
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'fromCurrency': fromCurrency,
    'toCurrency': toCurrency,
    'rate': rate,
    'amount': amount,
    'convertedAmount': convertedAmount,
  };

  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double amount;
  final double convertedAmount;

  const CurrencyPair({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.amount,
    required this.convertedAmount,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, amount, convertedAmount];

  CurrencyPair copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? rate,
    double? amount,
    double? convertedAmount,
  }) {
    return CurrencyPair(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }
}