import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:provider/provider.dart';
import '../../models/Deposits.dart'; // Import the Deposits class and demoDeposits list

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({Key? key}) : super(key: key);

  static String routeName = "/loan";

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  String formattedDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat.yMMMMd('en_US').add_jms();
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Loan History",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Consumer<LoanManagementProvider>(
          builder: (context, loanProvider, child) {
        return loanProvider.getloanList == null ||
                loanProvider.getloanList.isEmpty
            ? SizedBox()
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: loanProvider.getloanList.length,
                itemBuilder: (context, index) {
                  var loan = loanProvider.getloanList[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        loan['status'] == "ACCEPTED"
                            ? Icons.check_circle
                            : loan['status'] == "REJECTED"
                                ? Icons.error
                                : Icons.pending,
                        color: loan['status'] == "ACCEPTED"
                            ? Colors.green
                            : loan['status'] == "REJECTED"
                                ? Colors.red
                                : Colors.yellow,
                      ),
                      title: Text("Loan Amount : ${loan['amount']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Payment duration: ${loan['duration']}"),
                          // Text("Account Number: ${deposit.accountNumber}"),
                          Text(
                              "Date Requested: ${formattedDate(loan['created_at'])}"),
                          Text(
                              "Date Accepted: ${formattedDate(loan['accepted_at'])}"),
                        ],
                      ),
                    ),
                  );
                });
      }),
    );
  }
}



// ListView.builder(
//         itemCount: demoDeposits.length,
//         itemBuilder: (context, index) {
//           final deposit = demoDeposits[index];
//           return Card(
//             child: ListTile(
//               leading: Icon(
//                 deposit.isSuccess ? Icons.check_circle : Icons.error,
//                 color: deposit.isSuccess ? Colors.green : Colors.red,
//               ),
//               title: Text("Amount: ${deposit.amount}"),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("History: ${deposit.history}"),
//                   Text("Account Number: ${deposit.accountNumber}"),
//                   Text("Date: ${deposit.date}"),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),