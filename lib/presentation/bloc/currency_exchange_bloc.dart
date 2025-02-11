import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/repositories/currency_repository.dart';

// Events
abstract class CurrencyExchangeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCurrencyRates extends CurrencyExchangeEvent {}

class UpdateAmount extends CurrencyExchangeEvent {
  final double amount;

  UpdateAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SwapCurrencies extends CurrencyExchangeEvent {}

class UpdateFromCurrency extends CurrencyExchangeEvent {
  final String currency;

  UpdateFromCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class UpdateToCurrency extends CurrencyExchangeEvent {
  final String currency;

  UpdateToCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

// States
abstract class CurrencyExchangeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CurrencyExchangeInitial extends CurrencyExchangeState {}

class CurrencyExchangeLoading extends CurrencyExchangeState {}

class CurrencyExchangeLoaded extends CurrencyExchangeState {
  final CurrencyPair currencyPair;
  final Map<String, Map<String, double>> rates;
  final List<String> cryptoCurrencies;
  final List<String> fiatCurrencies;

  CurrencyExchangeLoaded({
    required this.currencyPair,
    required this.rates,
    required this.cryptoCurrencies,
    required this.fiatCurrencies,
  });

  @override
  List<Object?> get props => [currencyPair, rates, cryptoCurrencies, fiatCurrencies];

  CurrencyExchangeLoaded copyWith({
    CurrencyPair? currencyPair,
    Map<String, Map<String, double>>? rates,
    List<String>? cryptoCurrencies,
    List<String>? fiatCurrencies,
  }) {
    return CurrencyExchangeLoaded(
      currencyPair: currencyPair ?? this.currencyPair,
      rates: rates ?? this.rates,
      cryptoCurrencies: cryptoCurrencies ?? this.cryptoCurrencies,
      fiatCurrencies: fiatCurrencies ?? this.fiatCurrencies,
    );
  }
}

class CurrencyExchangeError extends CurrencyExchangeState {
  final String message;

  CurrencyExchangeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CurrencyExchangeBloc extends Bloc<CurrencyExchangeEvent, CurrencyExchangeState> {
  final CurrencyRepository repository;

  CurrencyExchangeBloc({required this.repository}) : super(CurrencyExchangeInitial()) {
    on<LoadCurrencyRates>(_onLoadCurrencyRates);
    on<UpdateAmount>(_onUpdateAmount);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<UpdateFromCurrency>(_onUpdateFromCurrency);
    on<UpdateToCurrency>(_onUpdateToCurrency);
  }

  Future<void> _onLoadCurrencyRates(LoadCurrencyRates event, Emitter<CurrencyExchangeState> emit) async {
    emit(CurrencyExchangeLoading());

    final result = await repository.getCurrencyRates();

    result.fold(
      (error) => emit(CurrencyExchangeError(error)),
      (rates) {
        final cryptoCurrencies = ['BTC', 'ETH', 'USDT', 'BNB', 'BCH', 'XRP', 'SOL', 'DOGE', 'ADA', 'TRX', 'XMR', 'TRUMP', 'POL'];
        final fiatCurrencies = ['USD', 'COP', 'EUR', 'ARS', 'MXN', 'CAD', 'BRL', 'CLP'];

        // Ensure the rate is converted to double
        double initialRate = (rates[cryptoCurrencies.first]?[fiatCurrencies.first] ?? 0).toDouble();

        emit(CurrencyExchangeLoaded(
          currencyPair: CurrencyPair(
            fromCurrency: cryptoCurrencies.first,
            toCurrency: fiatCurrencies.first,
            rate: initialRate,
            amount: 1.0,
            convertedAmount: initialRate,
          ),
          rates: rates,
          cryptoCurrencies: cryptoCurrencies,
          fiatCurrencies: fiatCurrencies,
        ));
      },
    );
  }

  Future<void> _onUpdateAmount(UpdateAmount event, Emitter<CurrencyExchangeState> emit) async {
    if (state is CurrencyExchangeLoaded) {
      final currentState = state as CurrencyExchangeLoaded;
      final result = await repository.convertCurrency(
        fromCurrency: currentState.currencyPair.fromCurrency,
        toCurrency: currentState.currencyPair.toCurrency,
        amount: event.amount,
      );

      result.fold(
        (error) => emit(CurrencyExchangeError(error)),
        (currencyPair) => emit(currentState.copyWith(currencyPair: currencyPair)),
      );
    }
  }

  Future<void> _onSwapCurrencies(SwapCurrencies event, Emitter<CurrencyExchangeState> emit) async {
    if (state is CurrencyExchangeLoaded) {
      final currentState = state as CurrencyExchangeLoaded;
      final result = await repository.convertCurrency(
        fromCurrency: currentState.currencyPair.toCurrency,
        toCurrency: currentState.currencyPair.fromCurrency,
        amount: currentState.currencyPair.convertedAmount,
      );

      result.fold(
        (error) => emit(CurrencyExchangeError(error)),
        (currencyPair) => emit(currentState.copyWith(currencyPair: currencyPair)),
      );
    }
  }

  Future<void> _onUpdateFromCurrency(UpdateFromCurrency event, Emitter<CurrencyExchangeState> emit) async {
    if (state is CurrencyExchangeLoaded) {
      final currentState = state as CurrencyExchangeLoaded;
      final result = await repository.convertCurrency(
        fromCurrency: event.currency,
        toCurrency: currentState.currencyPair.toCurrency,
        amount: currentState.currencyPair.amount,
      );

      result.fold(
        (error) => emit(CurrencyExchangeError(error)),
        (currencyPair) => emit(currentState.copyWith(currencyPair: currencyPair)),
      );
    }
  }

  Future<void> _onUpdateToCurrency(UpdateToCurrency event, Emitter<CurrencyExchangeState> emit) async {
    if (state is CurrencyExchangeLoaded) {
      final currentState = state as CurrencyExchangeLoaded;
      final result = await repository.convertCurrency(
        fromCurrency: currentState.currencyPair.fromCurrency,
        toCurrency: event.currency,
        amount: currentState.currencyPair.amount,
      );

      result.fold(
        (error) => emit(CurrencyExchangeError(error)),
        (currencyPair) => emit(currentState.copyWith(currencyPair: currencyPair)),
      );
    }
  }
}