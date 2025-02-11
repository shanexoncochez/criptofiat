import 'package:criptofiat/presentation/theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../bloc/currency_exchange_bloc.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1.0');
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    context.read<CurrencyExchangeBloc>().add(LoadCurrencyRates());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: BlocBuilder<CurrencyExchangeBloc, CurrencyExchangeState>(
        builder: (context, state) {
          if (state is CurrencyExchangeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CurrencyExchangeError) {
            return Center(child: Text(state.message));
          }

          if (state is CurrencyExchangeLoaded) {
            return Container(
              decoration: BoxDecoration(
          gradient: ColorSchemes.purpleGradient,
        ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0, bottom: 30),
                      child: Text('CryptoFiat Exchange', style: TextStyle( 
                        fontWeight: FontWeight.bold,
                        fontSize: 34
                      ),),
                    ),
                    
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Amount',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _amountController.clear();
                            context.read<CurrencyExchangeBloc>().add(UpdateAmount(0.0));
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                      onChanged: (value) {
                        final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                        context.read<CurrencyExchangeBloc>().add(UpdateAmount(amount));
                      },
                    ),
                                      const SizedBox(height: 40),
              
                    _buildCurrencySelector(
                      label: 'From',
                      selectedCurrency: state.currencyPair.fromCurrency,
                      currencies: state.cryptoCurrencies.contains(state.currencyPair.fromCurrency)
                          ? state.cryptoCurrencies
                          : state.fiatCurrencies,
                      onChanged: (currency) {
                        if (currency != null) {
                          context.read<CurrencyExchangeBloc>().add(UpdateFromCurrency(currency));
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        onPressed: () {
                          context.read<CurrencyExchangeBloc>().add(SwapCurrencies());
                          _amountController.text = _numberFormat
                              .format(state.currencyPair.convertedAmount)
                              .replaceAll(',', '.');
                        },
                        icon: Icon(
                          Icons.swap_vert,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCurrencySelector(
                      label: 'To',
                      selectedCurrency: state.currencyPair.toCurrency,
                      currencies: state.fiatCurrencies.contains(state.currencyPair.toCurrency)
                          ? state.fiatCurrencies
                          : state.cryptoCurrencies,
                      onChanged: (currency) {
                        if (currency != null) {
                          context.read<CurrencyExchangeBloc>().add(UpdateToCurrency(currency));
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.surface.withOpacity(0.7),
                              Theme.of(context).colorScheme.surface.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                          child: Column(
                            children: [
                              Text(
                                'Converted Amount',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${state.currencyPair.toCurrency} ',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  AnimatedFlipCounter(
                                    value: state.currencyPair.convertedAmount,
                                    duration: const Duration(milliseconds: 500),
                                    fractionDigits: 5,
                                    thousandSeparator: ',',
                                    textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 32,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  '${state.currencyPair.fromCurrency} = ${_numberFormat.format(state.currencyPair.rate)} ${state.currencyPair.toCurrency}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String selectedCurrency,
    required List<String> currencies,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      items: currencies
          .map((currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}