// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/helper/api/api_client_http.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';

class WalletManagementProvider with ChangeNotifier {
  var _loanList;
  var _depositwalletlist;

  var _wallet;

  get depositwalletlist => _depositwalletlist;
  get wallet => _wallet;

  Future<void> getWallet() async {
    var sharedPref = SharedPreferencesManager();

    var user = jsonDecode(await sharedPref.getString(AppConstants.user));

    var res = await ApiClientHttp(
            headers: <String, String>{'Content-type': 'application/json'})
        .getRequest("${AppConstants.getWalletUrl}?id=${user['id']}");

    if (res == null) {
      print("Res Null :: $res");
    } else {
      var body = res;
      _wallet = body['data'];
      // var sharedPref = SharedPreferencesManager();
      sharedPref.saveString(AppConstants.wallet, json.encode(body['data']));
      print("BODY-WALLET saved:: ${AppConstants.wallet}");
      // print("BODY-WALLET USer:: ${wallet}");

      print("BODY-WALLET :: ${json.encode(body['data'])}}");
      // print("BODY-WALLET decode:: ${json.encode(body['data'])}");

      notifyListeners();
    }
  }

  Future<bool> depositWallet(ctx, data) async {
    try {
      var sharedPref = SharedPreferencesManager();
      var user = jsonDecode(await sharedPref.getString(AppConstants.user));
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest("${AppConstants.getWalletDepositUrl}", data);

      print("RES: $res");
      if (res == null) {
        print("Res Null :: $res");

        return false;
      } else {
        var body = res;
        if (body['save']) {
          // _depositlist = body['data'];

          // print("BODY-WALLET :: ${body}");
          print("BODY-WALLET :: ${AppConstants.wallet}");

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("errors : ${e.toString()}");
      return false;
    }
  }

  Future<bool> getWalletDepositList() async {
    try {
      var sharedPref = SharedPreferencesManager();
      var user = jsonDecode(await sharedPref.getString(AppConstants.user));
      var wallet = jsonDecode(await sharedPref.getString(AppConstants.wallet));

      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).getRequest("${AppConstants.getWalletDepositUrl}?id=${wallet['id']}}");
      print("res :: $res");
      if (res == null) {
        print("RES NULL :: $res");
        return false;
      } else {
        var body = res;
        if (body["error"] == false) {
          _depositwalletlist = body['data'];
          print("BODY OF DEPOSIT LIST :: ${depositwalletlist}");

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
