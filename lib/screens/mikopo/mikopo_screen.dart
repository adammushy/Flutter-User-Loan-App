// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:provider/provider.dart';
import 'components/LoanRequestPage.dart';
import 'components/RecentLoanWidget.dart';
import 'components/image_display.dart';
import 'components/mikopo_header.dart';
import 'components/recent_loans.dart';

class MikopoScreen extends StatefulWidget {
  const MikopoScreen({Key? key}) : super(key: key);

  @override
  State<MikopoScreen> createState() => _MikopoScreenState();
}

class _MikopoScreenState extends State<MikopoScreen> {
  setSetData() {
    Provider.of<LoanManagementProvider>(context, listen: false).getLoanList();
  }

  @override
  void initState() {
    super.initState();
    setSetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // MikopoHeader(),
              // ImageDisplay(),
              RecentLoans(),
              RecentLoanWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _requestLoan(context);
        },
        child: Icon(Icons.add),
        backgroundColor:
            Colors.greenAccent, // Set the background color here
      ),
    );
  }

  void _requestLoan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoanRequestPage()),
    );
  }
}
