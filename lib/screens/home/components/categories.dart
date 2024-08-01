// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:loan_user_app/screens/Loan/loan_history_screen.dart';
import 'package:loan_user_app/screens/home/components/wallerdepositlist.dart';
import 'package:provider/provider.dart';
import '../../../models/Deposits.dart';
import '../../../models/Loans.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  void initState() {
    super.initState();
    Provider.of<WalletManagementProvider>(context, listen: false).getWallet();
    // fetchWaller();
    Provider.of<LoanManagementProvider>(context, listen: false).getLoanList();
  }

  void fetchWaller() async {
    await Provider.of<WalletManagementProvider>(context, listen: false)
        .getWallet();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total amount for "Mikopo Yangu" category
    String mikopoTotalAmount = calculateMikopoTotalAmount();
    var walletData =
        Provider.of<WalletManagementProvider>(context, listen: true).wallet;
    // print("wallet data :: ${walletData['amount']}");

    var loan = Provider.of<LoanManagementProvider>(context).getloanList;
    // Calculate the total remaining amount for accepted loans
    int totalMikopoRemain = 0;
    if (loan != null) {
      for (var l in loan) {
        totalMikopoRemain += (l['amount_remain'] as num).toInt();
      }
    }
    List<Map<String, dynamic>> categories = [
      {
        "icon": "assets/icons/Cash.svg",
        "text": "Account Balance",
        "color": Colors.greenAccent, // Green color for this category
        "totalAmount":
            mikopoTotalAmount // Calculate total amount for "Fedha Zote"
      },
      {
        "icon": "assets/icons/Cash.svg",
        "text": "My Loan",
        "color": const Color(0xFFFFECDF), // Default color for other categories
        "totalAmount": mikopoTotalAmount,
      },
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: CategoryCard(
                  icon: categories[0]["icon"],
                  text: categories[0]["text"],
                  amount: walletData['amount'].toString() ?? "0",
                  backgroundColor: categories[0]["color"],
                  press: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletScreen()));
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: CategoryCard(
                  icon: categories[1]["icon"],
                  text: categories[1]["text"],
                  // amount: categories[1]["totalAmount"],
                  amount: totalMikopoRemain.toString() ?? "0",

                  backgroundColor: categories[1]["color"],
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoanHistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]),
    );
  }

  String calculateTotalAmount() {
    int totalAmount = 0;
    for (var deposit in demoDeposits) {
      totalAmount +=
          int.parse(deposit.amount.replaceAll('Tsh', '').replaceAll(',', ''));
    }
    return "Tsh$totalAmount";
  }

  String calculateMikopoTotalAmount() {
    int mikopoTotalAmount = 0;
    for (var loan in demoLoans) {
      mikopoTotalAmount +=
          int.parse(loan.amount.replaceAll('Tsh', '').replaceAll(',', ''));
    }
    return "Tsh$mikopoTotalAmount";
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.amount,
    required this.backgroundColor,
    required this.press,
  }) : super(key: key);

  final String icon, text, amount;
  final Color backgroundColor;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 56,
            width: 180,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon),
                const SizedBox(
                    width: 8), // Adjust spacing between icon and text
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  backgroundColor == Colors.green ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
