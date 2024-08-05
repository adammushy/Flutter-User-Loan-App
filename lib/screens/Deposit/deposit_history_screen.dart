import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_user_app/constants/snackbar.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:provider/provider.dart';
// import '../../models/Deposits.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the Deposits class and demoDeposits list
import 'package:document_file_save_plus/document_file_save_plus.dart';

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
    var demoDeposits =
        Provider.of<WalletManagementProvider>(context, listen: false)
            .depositwalletlist;
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['Name', 'Amount', 'Account Number', 'Date'],
            data: demoDeposits.map<List<dynamic>>((deposit) {
              return [
                deposit['wallet']['user']['username'] ?? '--',
                deposit['amount'],
                deposit['wallet']['id'],
                deposit['created_at'],
                // deposit.isSuccess ? 'Success' : 'Failed'
              ];
            }).toList(),
          );
        },
      ),
    );
    final formattedDate =
        DateFormat('yyyy-MM-dd HH-mm-ss').format(DateTime.now());
    final directory = Directory('/storage/emulated/0/Kikoba');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    // Define the file path
    final filePath = "${directory.path}/deposit${formattedDate}.pdf";

    // Save the PDF bytes
    final pdfBytes = await pdf.save();
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes.toList());
    var save = DocumentFileSavePlus().saveFile(pdfBytes,
        "desposit - ${DateTime.now().toIso8601String()}.pdf", "deposits/pdf");

    ShowMToast(context).successToast(
        message: "PDF saved successfully to ${filePath}",
        alignment: Alignment.bottomCenter);
    // try {
    //   final path = Directory('/storage/emulated/0/kikoba');

    //   // Create the directory if it doesn't exist
    //   if (!await path.exists()) {
    //     await path.create(recursive: true);
    //   }

    //   final file = File('${path.path}/deposits_${DateTime.now()}.pdf');
    //   await file.writeAsBytes(await pdf.save());
    //   print("PDF saved successfully at ${file.path}");
    //   ShowMToast(context).successToast(
    //       message: "PDF saved successfully at ${file.path}",
    //       alignment: Alignment.bottomCenter);
    // } catch (e) {
    //   ShowMToast(context).errorToast(
    //       message: "Error saving PDF: $e", alignment: Alignment.bottomCenter);
    //   print("Error saving PDF: $e");
    // }
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
    Provider.of<WalletManagementProvider>(context, listen: false)
        .getWalletDepositList();
  }

  @override
  Widget build(BuildContext context) {
    var demoDeposits =
        Provider.of<WalletManagementProvider>(context, listen: true)
            .depositwalletlist;
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
            DataColumn(label: Text('name')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Account Number')),
            DataColumn(label: Text('Date')),
            // DataColumn(label: Text('Status')),
          ],
          rows: demoDeposits.map<DataRow>((deposit) {
            // var date = 
            return DataRow(
              cells: [
                DataCell(Text(deposit['wallet']['user']['username'] ?? '--')),
                DataCell(
                  Text(deposit['amount'].toString())),
                DataCell(Text(deposit['wallet']['id'])),
                DataCell(Text(
                  
                  DateFormat('yyyy-MM-dd HH-mm-ss')
                    .format( DateTime.parse(deposit['created_at']))
                )),
                // DataCell(
                //   Icon(
                //     deposit.isSuccess ? Icons.check_circle : Icons.error,
                //     color: deposit.isSuccess ? Colors.green : Colors.red,
                //   ),
                // ),
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
