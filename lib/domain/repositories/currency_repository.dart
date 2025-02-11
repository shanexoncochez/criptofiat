import 'package:dartz/dartz.dart';
import '../entities/currency_pair.dart';

abstract class CurrencyRepository {
  Future<Either<String, Map<String, Map<String, double>>>> getCurrencyRates();
  
  Future<Either<String, CurrencyPair>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });
}