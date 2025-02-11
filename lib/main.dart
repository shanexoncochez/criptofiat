import 'package:criptofiat/presentation/theme/app_theme.dart';
import 'package:criptofiat/presentation/theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/repositories/currency_repository_impl.dart';
import 'domain/repositories/currency_repository.dart';
import 'presentation/bloc/currency_exchange_bloc.dart';
import 'presentation/screens/splash_screen.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(dio: getIt()),
  );
  getIt.registerFactory(
    () => CurrencyExchangeBloc(repository: getIt()),
  );
}

void main() {
  setupDependencies(); // Initialize dependencies first
  
  runApp(
    BlocProvider(
      create: (context) => getIt<CurrencyExchangeBloc>()..add(LoadCurrencyRates()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoFiat Exchange',
      theme: AppTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          gradient: ColorSchemes.purpleGradient,
        ),
        child: const SplashScreen(),
      ),
    );
  }
}
