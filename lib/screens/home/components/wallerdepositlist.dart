// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_user_app/constants/snackbar.dart';
import 'package:loan_user_app/models/Loans.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:loan_user_app/screens/mikopo/components/loanRepayment.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ndialog/ndialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

class RecentWalletDeposits extends StatefulWidget {
  const RecentWalletDeposits({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentWalletDeposits> createState() => _RecentWalletDepositsState();
}

class _RecentWalletDepositsState extends State<RecentWalletDeposits> {
  String formattedDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat.yMMMMd('en_US').add_jms();
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletManagementProvider>(
        builder: (context, recordProvider, child) {
      return recordProvider.depositwalletlist == null ||
              recordProvider.depositwalletlist.isEmpty
          ? Center(
              child: const SizedBox(
              child: Text("no data found"),
            ))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recordProvider.depositwalletlist.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // NDialog(
                    //   dialogStyle: DialogStyle(titleDivider: true),
                    //   title: Text("Loan"),
                    //   content: Text(
                    //       "Amount Deposited: ${recordProvider.depositwalletlist[index]['amount']}"),
                    //   actions: <Widget>[
                    //     TextButton(
                    //       child: Text("View details"),
                    //       onPressed: () {},
                    //     ),
                    //     TextButton(
                    //       child: Text("Pay"),
                    //       onPressed: () {},
                    //     ),
                    //   ],
                    // ).show(context);
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child: ListTile(
                        // ),
                        leading: Icon(Icons.money),
                        title: Text(
                            "Amount Deposited: ${recordProvider.depositwalletlist[index]['amount']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            recordProvider.depositwalletlist[index]
                                        ['created_at'] ==
                                    null
                                ? const SizedBox()
                                : Text(
                                    "Requested At: ${formattedDate(recordProvider.depositwalletlist[index]['created_at'])}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
    });
  }

  void _showLoanHistory(BuildContext context, Loans loan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Loan History"),
          content: Text(loan.history),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  setSetData() {
    Provider.of<LoanManagementProvider>(context, listen: false).getLoanList();
  }

  @override
  void initState() {
    super.initState();
    setSetData();
    Provider.of<WalletManagementProvider>(context, listen: false)
        .getWalletDepositList();
    requestStoragePermission();
  }

  String formattedDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat.yMMMMd('en_US').add_jms();
    return formatter.format(dateTime);
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // status = await Permission.accessMediaLocation.request();
      // status = await Permission.storage.request();
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  Future<void> generateAndSavePdf(List depositWalletList) async {
    final pdf = pw.Document();
    // print("printing :: $depositWalletList");
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Deposits Statement',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Email',
                  'Phone Number',
                  'Amount Deposited',
                  'Date & Time'
                ],
                data: depositWalletList.map((item) {
                  // final user = item['id'];
                  print("print user :: ${item['wallet']['user']}");
                  return [
                    item['wallet']['user']['email'],
                    item['wallet']['user']['phone_number'].toString(),
                    item['amount'].toString(),
                    formattedDate(item['created_at']),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    try {
      final path = Directory('/storage/emulated/0/kikoba');

      // Create the directory if it doesn't exist
      if (!await path.exists()) {
        await path.create(recursive: true);
      }

      final file = File(
          '${path.path}/deposits_Statement${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      print("PDF saved successfully at ${file.path}");
      ShowMToast(context).successToast(
          message: "PDF saved successfully at ${file.path}",
          alignment: Alignment.bottomCenter);
    } catch (e) {
      ShowMToast(context).errorToast(
          message: "Error saving PDF: $e", alignment: Alignment.bottomCenter);
      print("Error saving PDF: $e");
    }
  }

  Future<void> _handlePdfGeneration() async {
    bool isPermissionGranted = await requestStoragePermission();
    if (isPermissionGranted) {
      var walletData =
          Provider.of<WalletManagementProvider>(context, listen: false);
      await generateAndSavePdf(walletData.depositwalletlist);
    } else {
      print("Storage permission denied");
    }
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
              // RecentLoans(),
              // RecentLoanWidget(),
              RecentWalletDeposits()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _requestLoan(context);
          _handlePdfGeneration();
        },
        // child: Icon(Icons.add),
        child: Icon(Icons.download_rounded),
        backgroundColor: Colors.greenAccent, // Set the background color here
      ),
    );
  }
}
