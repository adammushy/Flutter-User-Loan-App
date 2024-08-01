// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, prefer_final_fields

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/constants/snackbar.dart';
import 'package:loan_user_app/providers/loan_management_provider.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class LoanRequestPage extends StatefulWidget {
  const LoanRequestPage({Key? key}) : super(key: key);

  @override
  _LoanRequestPageState createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _sponsorUsernameController = TextEditingController();
  final _sponsorEmailController = TextEditingController();
  final _sponsorPhoneController = TextEditingController();
  String? _selectedDuration;
  Map<int, String> _loanDurationMap = {
    10000: '2 weeks',
    100001: '1 month',
    500001: '2 months',
    1000001: '6 months',
    5000001: '1 year',
    100000000: '2 years'
  };
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  double getInterestRate() => 0.09;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _sponsorUsernameController.dispose();
    _sponsorEmailController.dispose();
    _sponsorPhoneController.dispose();
    controller?.dispose();
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      ShowMToast(context)
          .successToast(message: scanData.code!, alignment: Alignment.center);
      print("scanned data ${scanData.code!}");
      // Map<String, dynamic> userInfo = jsonDecode(scanData.code!);
      //    ShowMToast(context)
      //     .errorToast(message: userInfo.toString(), alignment: Alignment.center);
      // print("scanned data DECODED ${userInfo}");

      // // Map<String, dynamic> userInfo = scanData.code;
      // _sponsorUsernameController.text = userInfo['username'];
      // _sponsorEmailController.text = userInfo['email'];
      // _sponsorPhoneController.text = userInfo['phone_number'];
      // controller.pauseCamera();
      // Navigator.pop(context);
      try {
        // Attempt to decode JSON
        Map<String, dynamic> userInfo = jsonDecode(scanData.code!);
        print("Decoded data: $userInfo");

        _sponsorUsernameController.text = userInfo['username'];
        _sponsorEmailController.text = userInfo['email'];
        _sponsorPhoneController.text = userInfo['phone_number'];

        controller.pauseCamera();
        Navigator.pop(context); // Close QR scanner page
      } catch (e) {
        // Handle error when JSON decoding fails
        print("Error decoding QR data: $e");
        ShowMToast(context).errorToast(
            message: 'Invalid QR code format', alignment: Alignment.center);
        // Optionally, show an error message to the user or handle the error in another way
      }
    });
    // controller.toggleFlash();
    // controller.scannedDataStream.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Loan Request",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QRScannerPage(onQRViewCreated: _onQRViewCreated)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
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
                        8), // Limit input to 8 digits
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
                TextFormField(
                  controller: _sponsorUsernameController,
                  decoration: const InputDecoration(
                    labelText: "Sponsor Username",
                    hintText: "Enter sponsor's username",
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sponsorEmailController,
                  decoration: const InputDecoration(
                    labelText: "Sponsor Email",
                    hintText: "Enter sponsor's email",
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sponsorPhoneController,
                  decoration: const InputDecoration(
                    labelText: "Sponsor Phone",
                    hintText: "Enter sponsor's phone number",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    var pref = SharedPreferencesManager();
                    var userId = jsonDecode(
                        await pref.getString(AppConstants.user))['id'];
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
                          "requested_by": userId,
                          "sponsor_username": _sponsorUsernameController.text,
                          "sponsor_email": _sponsorEmailController.text,
                          "sponsor_phone": _sponsorPhoneController.text,
                        };
                        bool result = await Provider.of<LoanManagementProvider>(
                                context,
                                listen: false)
                            .requestLoan(context, data);
                        if (result) {
                          Navigator.pop(context);
                        } else {
                          // Handle failure
                        }
                      }
                    }
                  },
                  child: const Text("Submit Request"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRScannerPage extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;

  QRScannerPage({required this.onQRViewCreated});

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: QRView(
        cameraFacing: CameraFacing.back,
        formatsAllowed: [BarcodeFormat.qrcode],
        key: GlobalKey(debugLabel: 'QR'),
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
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










































// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:loan_user_app/constants/app_constants.dart';
// import 'package:loan_user_app/providers/loan_management_provider.dart';
// import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
// import 'package:provider/provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';


// class LoanRequestPage extends StatefulWidget {
//   const LoanRequestPage({Key? key}) : super(key: key);

//   @override
//   _LoanRequestPageState createState() => _LoanRequestPageState();
// }

// class _LoanRequestPageState extends State<LoanRequestPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _loanAmountController = TextEditingController();
//   // double? _interest;
//   // double? _amount_to_pay;
//   String? _selectedDuration;

//   Map<int, String> _loanDurationMap = {
//     10000: '2 weeks',
//     100001: '1 month',
//     500001: '2 months',
//     1000001: '6 months',
//     5000001: '1 year',
//     100000000: '2 years'
//   };

//   double getInterestRate() => 0.09;

//   @override
//   void dispose() {
//     _loanAmountController.dispose();
//     super.dispose();
//   }

//   double calculateTotalReturn(var loanAmount) {
//     try {
//       double interestRate = getInterestRate();
//       return int.parse(loanAmount.toString()) +
//           (int.parse(loanAmount.toString()) * interestRate);
//     } catch (e) {
//       return 0;
//     }
//   }

//   void updateSelectedDuration(var loanAmount) {
//     try {
//       _loanDurationMap.forEach((key, value) {
//         if (int.parse(loanAmount.toString()) >= key) {
//           setState(() {
//             _selectedDuration = value;
//           });
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   String? validateLoanAmount(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter the loan amount';
//     }
//     final amount = int.tryParse(value);
//     if (amount == null ||
//         amount < 10000 ||
//         amount > 10000000 ||
//         value.length > 8) {
//       return 'Loan amount must be between 10,000 and 10,000,000 and should not exceed 8 digits';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Loan Request",
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _loanAmountController,
//                 decoration: const InputDecoration(
//                   labelText: "Loan Amount",
//                   hintText: "Enter amount",
//                 ),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   LengthLimitingTextInputFormatter(
//                       8), // Limit input to 7 digits
//                   FilteringTextInputFormatter.digitsOnly, // Allow only digits
//                 ],
//                 validator: validateLoanAmount,
//                 onChanged: (value) {
//                   setState(() {
//                     if (value.isNotEmpty) {
//                       int loanAmount = int.parse(value);
//                       updateSelectedDuration(loanAmount);
//                     } else {
//                       _selectedDuration = null;
//                     }
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RichText(
//                   text: TextSpan(
//                     style: DefaultTextStyle.of(context).style,
//                     children: <TextSpan>[
//                       const TextSpan(
//                         text: 'Interest',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black,
//                             decoration: TextDecoration.none),
//                       ),
//                       const TextSpan(
//                         text: '  : ',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black,
//                             decoration: TextDecoration.none),
//                       ),
//                       TextSpan(
//                         text: getInterestRate().toString(),
//                         style: const TextStyle(
//                             fontSize: 14, decoration: TextDecoration.none),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RichText(
//                   text: TextSpan(
//                     style: DefaultTextStyle.of(context).style,
//                     children: <TextSpan>[
//                       const TextSpan(
//                         text: 'Amount to pay',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black,
//                             decoration: TextDecoration.none),
//                       ),
//                       const TextSpan(
//                         text: '  : ',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black,
//                             decoration: TextDecoration.none),
//                       ),
//                       TextSpan(
//                         text: calculateTotalReturn(_loanAmountController.text)
//                             .toString(),
//                         style: const TextStyle(
//                             fontSize: 14, decoration: TextDecoration.none),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RichText(
//                   text: TextSpan(
//                     style: DefaultTextStyle.of(context).style,
//                     children: <TextSpan>[
//                       const TextSpan(
//                         text: 'Duration',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Colors.black,
//                             decoration: TextDecoration.none),
//                       ),
//                       const TextSpan(
//                         text: "  : ",
//                         style: TextStyle(
//                             fontSize: 14, decoration: TextDecoration.none),
//                       ),
//                       _selectedDuration == null
//                           ? const TextSpan(
//                               text: "---",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                   decoration: TextDecoration.none),
//                             )
//                           : TextSpan(
//                               text: _selectedDuration,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.none,
//                                 fontSize: 14,
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () async {
//                   var pref = SharedPreferencesManager();
//                   var userId =
//                       jsonDecode(await pref.getString(AppConstants.user))['id'];
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     if (_loanAmountController.text.isNotEmpty &&
//                         _selectedDuration != null) {
//                       double totalReturn =
//                           calculateTotalReturn(_loanAmountController.text);
//                       int toPay = totalReturn.toInt();
//                       print("remain amount :: $toPay");
//                       var data = {
//                         "amount": _loanAmountController.text,
//                         "interest": getInterestRate(),
//                         "amount_remain": toPay,
//                         "duration": _selectedDuration,
//                         "requested_by": userId
//                       };
//                       bool result = await Provider.of<LoanManagementProvider>(
//                               context,
//                               listen: false)
//                           .requestLoan(context, data);
//                       if (result) {
//                         Navigator.pop(context);
//                       } else {}
//                     }
//                   }
//                 },
//                 child: const Text("Submit Request"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     home: LoanRequestPage(),
//   ));
// }
