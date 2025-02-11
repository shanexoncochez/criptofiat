import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final Dio dio;
  final String baseUrl = 'https://min-api.cryptocompare.com/data';
  final List<String> cryptoCurrencies = [
    'BTC', 'ETH', 'USDT', 'BNB', 'BCH',
    'XRP', 'SOL', 'DOGE', 'ADA', 'TRX',
    'XMR', 'TRUMP', 'POL'
  ];
  final List<String> fiatCurrencies = [
    'USD', 'COP', 'EUR', 'ARS', 'MXN',
    'CAD', 'BRL', 'CLP'
  ];

  CurrencyRepositoryImpl({required this.dio});

  @override
  Future<Either<String, Map<String, Map<String, double>>>> getCurrencyRates() async {
    try {
      final response = await dio.get(
        '$baseUrl/pricemulti',
        queryParameters: {
          'fsyms': cryptoCurrencies.join(','),
          'tsyms': fiatCurrencies.join(','),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final Map<String, Map<String, double>> rates = {};

        data.forEach((key, value) {
          if (value is Map) {
            rates[key] = value.map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0));
          }
        });

        return Right(rates);
      } else {
        return const Left('Failed to fetch currency rates');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CurrencyPair>> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    try {
      final ratesResult = await getCurrencyRates();

      return ratesResult.fold(
        (error) => Left(error),
        (rates) {
          double rate;
          double convertedAmount;

          if (cryptoCurrencies.contains(fromCurrency) && fiatCurrencies.contains(toCurrency)) {
            // Crypto to Fiat conversion
            rate = rates[fromCurrency]?[toCurrency] ?? 0.0;
            convertedAmount = amount * rate;
          } else if (fiatCurrencies.contains(fromCurrency) && cryptoCurrencies.contains(toCurrency)) {
            // Fiat to Crypto conversion
            rate = rates[toCurrency]?[fromCurrency] ?? 0.0;
            convertedAmount = amount / (rate != 0 ? rate : 1);
          } else {
            return const Left('Invalid currency pair');
          }

          return Right(CurrencyPair(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            amount: amount,
            convertedAmount: convertedAmount,
          ));
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}