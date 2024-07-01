import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/snackbar.dart';
import '../../models/Deposits.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the Deposits class and demoDeposits list

class DepositHistoryScreen extends StatefulWidget {
  const DepositHistoryScreen({Key? key}) : super(key: key);

  static String routeName = "/deposit";

  @override
  State<DepositHistoryScreen> createState() => _DepositHistoryScreenState();
}

class _DepositHistoryScreenState extends State<DepositHistoryScreen> {
  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // status = await Permission.accessMediaLocation.request();
      // status = await Permission.storage.request();
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  Future<void> generateAndSavePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['Amount', 'History', 'Account Number', 'Date', 'Status'],
            data: demoDeposits.map((deposit) {
              return [
                deposit.amount,
                deposit.history,
                deposit.accountNumber,
                deposit.date,
                deposit.isSuccess ? 'Success' : 'Failed'
              ];
            }).toList(),
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

      final file = File('${path.path}/deposits_${DateTime.now()}.pdf');
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
      await generateAndSavePdf();
    } else {
      print("Storage permission denied");
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deposit History",
          style: TextStyle(fontSize: 20),
        ),
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('History')),
            DataColumn(label: Text('Account Number')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
          ],
          rows: demoDeposits.map((deposit) {
            return DataRow(
              cells: [
                DataCell(Text(deposit.amount)),
                DataCell(Text(deposit.history)),
                DataCell(Text(deposit.accountNumber)),
                DataCell(Text(deposit.date)),
                DataCell(
                  Icon(
                    deposit.isSuccess ? Icons.check_circle : Icons.error,
                    color: deposit.isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),

      floatingActionButton: IconButton(
        onPressed: () {
          _handlePdfGeneration();
        },
        icon: Icon(Icons.download_rounded),
      ),

      // body: ListView.builder(
      //   itemCount: demoDeposits.length,
      //   itemBuilder: (context, index) {
      //     final deposit = demoDeposits[index];
      //     return Card(
      //       child: ListTile(
      //         leading: Icon(
      //           deposit.isSuccess ? Icons.check_circle : Icons.error,
      //           color: deposit.isSuccess ? Colors.green : Colors.red,
      //         ),
      //         title: Text("Amount: ${deposit.amount}"),
      //         subtitle: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text("History: ${deposit.history}"),
      //             Text("Account Number: ${deposit.accountNumber}"),
      //             Text("Date: ${deposit.date}"),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}