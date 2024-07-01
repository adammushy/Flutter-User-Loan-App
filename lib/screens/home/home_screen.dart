// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:loan_user_app/screens/mikopo/components/michango.dart';
import 'package:provider/provider.dart';
import 'components/RecentDepositsWidget.dart';
import 'components/body_text.dart';
import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';
import 'components/recent_deposits.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  final String? username; // Assuming you have the username available here

  const HomeScreen({Key? key, this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // fetchWaller();
    Provider.of<WalletManagementProvider>(context, listen: false).getWallet();
  }

  void fetchWaller() async {
    await Provider.of<WalletManagementProvider>(context, listen: false)
        .getWallet();
  }

  @override
  Widget build(BuildContext context) {
    var walletData =
        Provider.of<WalletManagementProvider>(context, listen: true).wallet;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(),
              BodyText(),
              SizedBox(
                height: 10,
              ),
              Categories(),
              // DiscountBanner(),
              RecentDeposits(),
              // RecentDepositsWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NormalPaymentPage(
                walletId: walletData['id'],
              ),
            ),
          );
        },
        child: Icon(Icons.monetization_on),

        backgroundColor: Colors.greenAccent, // Set the background color here
      ),
    );
  }
}
