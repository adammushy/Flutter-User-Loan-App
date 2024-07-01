import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_user_app/models/Loans.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/screens/mikopo/components/loanRepayment.dart';
import 'package:provider/provider.dart';
import 'package:ndialog/ndialog.dart';

class RecentLoanWidget extends StatefulWidget {
  const RecentLoanWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentLoanWidget> createState() => _RecentLoanWidgetState();
}

class _RecentLoanWidgetState extends State<RecentLoanWidget> {
  String formattedDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat.yMMMMd('en_US').add_jms();
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanManagementProvider>(
        builder: (context, recordProvider, child) {
      return recordProvider.getloanList == null ||
              recordProvider.getloanList.isEmpty
          ? const SizedBox()
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recordProvider.getloanList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // print(recordProvider.getloanList[index]);
                    // print("nilipe mkopo sasa");
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => LoanRepaymentPage(
                    //         loanId: recordProvider.getloanList[index]['id'],
                    //         loanAmount: recordProvider.getloanList[index]
                    //                 ['amount']
                    //             .toString()),
                    //   ),
                    // );

                    NDialog(
                      dialogStyle: DialogStyle(titleDivider: true),
                      title: Text("Loan"),
                      content: Text(
                          "Amount Requested: ${recordProvider.getloanList[index]['amount']}"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("View details"),
                          onPressed: () {},
                        ),
                        TextButton(
                          child: Text("Pay"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoanRepaymentPage(
                                    loanId: recordProvider.getloanList[index]
                                        ['id'],
                                    loanAmount: recordProvider
                                        .getloanList[index]['amount']
                                        .toString()),
                              ),
                            );
                          },
                        ),
                      ],
                    ).show(context);
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
                        leading: Icon(
                          recordProvider.getloanList[index]['status'] ==
                                  "PENDING"
                              ? Icons.pending
                              : recordProvider.getloanList[index]['status'] ==
                                      "REJECTED"
                                  ? Icons.cancel
                                  : Icons.check_circle,
                          color: recordProvider.getloanList[index]['status'] ==
                                  "PENDING"
                              ? Colors.amber
                              : recordProvider.getloanList[index]['status'] ==
                                      "REJECTED"
                                  ? Colors.red
                                  : Colors.green,
                        ),
                        title: Text(
                            "Amount Requested: ${recordProvider.getloanList[index]['amount']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Interest: ${recordProvider.getloanList[index]['interest']}"),
                            Text(
                                "Amount_remain : ${recordProvider.getloanList[index]['amount_remain']}"),
                            // Text(
                            //     "Interest: ${recordProvider.getloanList[index]['interest']}"),
                            // Text(
                            //     "Return Duration: ${(recordProvider.getloanList[index]['duration'])}"),
                            // recordProvider.getloanList[index]['accepted_at'] ==
                            //         null
                            //     ? const SizedBox()
                            //     : Text(
                            //         "Accepted At: ${formattedDate(recordProvider.getloanList[index]['accepted_at'])}"),
                            // recordProvider.getloanList[index]['rejected_at'] ==
                            //         null
                            //     ? const SizedBox()
                            //     : Text(
                            //         "Rejected At: ${formattedDate(recordProvider.getloanList[index]['rejected_at'])}"),
                            // recordProvider.getloanList[index]['requested_at'] ==
                            //         null
                            //     ? const SizedBox()
                            //     : Text(
                            //         "Requested At: ${formattedDate(recordProvider.getloanList[index]['requested_at'])}"),
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
