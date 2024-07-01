// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
import 'package:provider/provider.dart';

class LoanRequestPage extends StatefulWidget {
  const LoanRequestPage({Key? key}) : super(key: key);

  @override
  _LoanRequestPageState createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  // double? _interest;
  // double? _amount_to_pay;
  String? _selectedDuration;

  Map<int, String> _loanDurationMap = {
    10000: '2 weeks',
    100001: '1 month',
    500001: '2 months',
    1000001: '6 months',
  };

  double getInterestRate() => 0.09;

  @override
  void dispose() {
    _loanAmountController.dispose();
    super.dispose();
  }

  double calculateTotalReturn(var loanAmount) {
    try {
      double interestRate = getInterestRate();
      return int.parse(loanAmount.toString()) +
          (int.parse(loanAmount.toString()) * interestRate);
    } catch (e) {
      return 0;
    }
  }

  void updateSelectedDuration(var loanAmount) {
    try {
      _loanDurationMap.forEach((key, value) {
        if (int.parse(loanAmount.toString()) >= key) {
          setState(() {
            _selectedDuration = value;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  String? validateLoanAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the loan amount';
    }
    final amount = int.tryParse(value);
    if (amount == null ||
        amount < 10000 ||
        amount > 10000000 ||
        value.length > 8) {
      return 'Loan amount must be between 10,000 and 10,000,000 and should not exceed 8 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Loan Request",
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
                controller: _loanAmountController,
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
                validator: validateLoanAmount,
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      int loanAmount = int.parse(value);
                      updateSelectedDuration(loanAmount);
                    } else {
                      _selectedDuration = null;
                    }
                  });
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
                        text: 'Interest',
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
                        text: getInterestRate().toString(),
                        style: const TextStyle(
                            fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Amount to pay',
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
                        text: calculateTotalReturn(_loanAmountController.text)
                            .toString(),
                        style: const TextStyle(
                            fontSize: 14, decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Duration',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                      const TextSpan(
                        text: "  : ",
                        style: TextStyle(
                            fontSize: 14, decoration: TextDecoration.none),
                      ),
                      _selectedDuration == null
                          ? const TextSpan(
                              text: "---",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.none),
                            )
                          : TextSpan(
                              text: _selectedDuration,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                                fontSize: 14,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  var pref = SharedPreferencesManager();
                  var userId =
                      jsonDecode(await pref.getString(AppConstants.user))['id'];
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_loanAmountController.text.isNotEmpty &&
                        _selectedDuration != null) {
                      double totalReturn =
                          calculateTotalReturn(_loanAmountController.text);
                      int toPay = totalReturn.toInt();
                      print("remain amount :: $toPay");
                      var data = {
                        "amount": _loanAmountController.text,
                        "interest": getInterestRate(),
                        "amount_remain": toPay,
                        "duration": _selectedDuration,
                        "requested_by": userId
                      };
                      bool result = await Provider.of<LoanManagementProvider>(
                              context,
                              listen: false)
                          .requestLoan(context, data);
                      if (result) {
                        Navigator.pop(context);
                      } else {}
                    }
                  }
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

void main() {
  runApp(const MaterialApp(
    home: LoanRequestPage(),
  ));
}
