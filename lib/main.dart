import 'package:flutter/material.dart';
import 'package:loan_user_app/providers/default_provider.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/providers/user_management_provider.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:loan_user_app/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutterwave_standard/flutterwave.dart';
// import 'package:azampay/azampay.dart';
import 'routes.dart';
import 'theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DefaultProvider()),
        ChangeNotifierProvider(create: (context) => UserManagementProvider()),
        ChangeNotifierProvider(create: (context) => WalletManagementProvider()),
        ChangeNotifierProvider(create: (context) => LoanManagementProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loan App - Users',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
