// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:uuid/uuid.dart';
// import 'package:uuu';
import 'package:flutter/services.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
import 'package:provider/provider.dart';

class LoanRepaymentPage extends StatefulWidget {
  final String loanId;
  final String loanAmount; // Example variable
  // Example variable

  const LoanRepaymentPage(
      {Key? key, required this.loanId, required this.loanAmount})
      : super(key: key);

  @override
  _LoanRepaymentPageState createState() => _LoanRepaymentPageState();
}

class _LoanRepaymentPageState extends State<LoanRepaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _depositAmountController = TextEditingController();

  // double? _interest;
  // double? _amount_to_pay;
  String? _selectedDuration;
  bool isTestMode = true;

  Map<int, String> _loanDurationMap = {
    10000: '2 weeks',
    100001: '1 month',
    500001: '2 months',
    1000001: '6 months',
  };

  double getInterestRate() => 0.09;

  @override
  void dispose() {
    _depositAmountController.dispose();
    super.dispose();
  }

  _handlePaymentInitialization(email) async {
    final Customer customer = Customer(email: email);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: 'FLWPUBK_TEST-ad169f46c21db341e24cbde5816d72bf-X',
        currency: "TZS",
        redirectUrl: 'https://www.google.com/',
        // redirectUrl: url,
        txRef: Uuid().v1(),
        amount: _depositAmountController.text.toString().trim(),
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: "Loan Payment"),
        isTestMode: this.isTestMode);
    final ChargeResponse response = await flutterwave.charge();
    if (mounted) {
      showLoading(response.toString());
    }
    print("RESPONSE :: ${response.toJson()}");

    return response; // Return the ChargeResponse object
  }

  Future<void> showLoading(String message) {
    if (!mounted) return Future.value(); // Ensure the widget is still mounted
    return showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 50,
            child: Text(message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Loan Repayment",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _depositAmountController,
                decoration: const InputDecoration(
                  labelText: "Loan Amount",
                  hintText: "Enter amount",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                      8), // Limit input to 7 digits
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                // validator: validateLoanAmount,
                onChanged: (value) {
                  // setState(() {
                  //   if (value.isNotEmpty) {
                  //     int loanAmount = int.parse(value);
                  //     updateSelectedDuration(loanAmount);
                  //   } else {
                  //     _selectedDuration = null;
                  //   }
                  // });
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Loan Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      const TextSpan(
                        text: '  : ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      TextSpan(
                        // text: getInterestRate().toString(),
                        text: widget.loanAmount.toString(),
                        style: const TextStyle(
                            fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: RichText(
              //     text: TextSpan(
              //       style: DefaultTextStyle.of(context).style,
              //       children: <TextSpan>[
              //         const TextSpan(
              //           text: 'Amount to pay',
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14,
              //               color: Colors.black,
              //               decoration: TextDecoration.none),
              //         ),
              //         const TextSpan(
              //           text: '  : ',
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14,
              //               color: Colors.black,
              //               decoration: TextDecoration.none),
              //         ),
              //         TextSpan(
              //           text: _depositAmountController.text,
              //           style: const TextStyle(
              //               fontSize: 14, decoration: TextDecoration.none),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: RichText(
              //     text: TextSpan(
              //       style: DefaultTextStyle.of(context).style,
              //       children: <TextSpan>[
              //         const TextSpan(
              //           text: 'Duration',
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 14,
              //               color: Colors.black,
              //               decoration: TextDecoration.none),
              //         ),
              //         const TextSpan(
              //           text: "  : ",
              //           style: TextStyle(
              //               fontSize: 14, decoration: TextDecoration.none),
              //         ),
              //         _selectedDuration == null
              //             ? const TextSpan(
              //                 text: "---",
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.bold,
              //                     fontSize: 14,
              //                     decoration: TextDecoration.none),
              //               )
              //             : TextSpan(
              //                 text: _selectedDuration,
              //                 style: const TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   decoration: TextDecoration.none,
              //                   fontSize: 14,
              //                 ),
              //               ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  var pref = SharedPreferencesManager();
                  var userId =
                      jsonDecode(await pref.getString(AppConstants.user))['id'];
                  var email = jsonDecode(
                      await pref.getString(AppConstants.user))['email'];
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_depositAmountController.text.isNotEmpty) {
                      var data = {
                        "loan": widget.loanId,
                        "amount": _depositAmountController.text,
                        
                        // "duration": _selectedDuration,
                        "provider":"Tigopesa",
                        "inserted_by": userId
                      };
                      // var res = await _handlePaymentInitialization(email);
                      // res = res.toJson();
                      // print("RES  :: ${res['status']}");

                      // if (res['success']) {
                      bool result = await Provider.of<LoanManagementProvider>(
                              context,
                              listen: false)
                          .requestDeposit(context, data);
                      if (result) {
                        Navigator.pop(context);
                      } else {
                        print("REsult ::$result");
                      }
                      Navigator.pop(context);
                      // }
                      // print("RES  :: $res");
                    }
                  }
                  print("LIpa");
                },
                child: const Text("Submit Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(const MaterialApp(
//     home: LoanRequestPage(),
//   ));
// }
