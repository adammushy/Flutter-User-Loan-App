// ignore_for_file: non_const_call_to_literal_constructor

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRCodeScreen extends StatefulWidget {
  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
  const QRCodeScreen({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  @override
  Widget build(BuildContext context) {
    // Example user data in JSON format
    Map<String, dynamic> userData = {
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'phone': '123-456-7890'
    };

    var sharedPref = SharedPreferencesManager();
    var userInfo;
    var userr;
    Future<String> getUser() async {
      var sharedPref = SharedPreferencesManager();
      userr = await sharedPref.getString(AppConstants.user);

      print("USerr :: $userr");
      setState(() {
        userInfo = userr;
      });
      print("usr Info :: ${widget.data.toString()}");
      return userr;
    }

    // Convert user data to a JSON string
    String userDataJson = jsonEncode(userData);

    @override
    void initState() {
      super.initState();
      getUser();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Generate QR Code from JSON Data'),
      ),
      body: Center(
        // child: QrImageView(
        //   // data: userDataJson,
        //   // data: getUser().toString(),
        //   data: jsonEncode(widget.data),
        //   version: QrVersions.auto,
        //   size: 400.0,
        // ),
        child: Container(
          height: MediaQuery.of(context).size.height *0.7,
          width: MediaQuery.of(context).size.width * 0.7,

          child: PrettyQrView.data(
            data: jsonEncode(widget.data),
            decoration: PrettyQrDecoration(
              image: PrettyQrDecorationImage(
                image: AssetImage("assets/images/Koba.png"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
