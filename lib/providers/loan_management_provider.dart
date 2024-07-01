// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/helper/api/api_client_http.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';

class LoanManagementProvider with ChangeNotifier {
  var _loanList;
  var _depositlist;

  var _arrivedCargoList;
  var _shippedCargoList;

  get getloanList => _loanList;
  get getdepositList => _depositlist;

  get getArrivedCargoList => _arrivedCargoList;
  get getShippedCargoList => _shippedCargoList;

  Future<bool> getLoanList() async {
    try {
      var sharedPref = SharedPreferencesManager();
      var user = jsonDecode(await sharedPref.getString(AppConstants.user));
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).getRequest("${AppConstants.getLoanUrl}?q=s&id=${user['id']}");
      if (res == null) {
        return false;
      } else {
        var body = res;
        if (body["error"] == false) {
          _loanList = body['data'];
          
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

  Future<bool> getArrivedCargos() async {
    try {
      var customer =
          await SharedPreferencesManager().getString(AppConstants.customer);
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).getRequest('${AppConstants.arrivedCargoUrl}$customer');
      if (res == null) {
        return false;
      } else {
        var body = res;
        if (body.containsKey("results")) {
          _arrivedCargoList = body['results'];
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

  Future<bool> getShippedCargos() async {
    try {
      var customer =
          await SharedPreferencesManager().getString(AppConstants.customer);
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).getRequest('${AppConstants.shippedCargoUrl}$customer');
      if (res == null) {
        return false;
      } else {
        var body = res;
        if (body.containsKey("results")) {
          _shippedCargoList = body['results'];
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

  Future<bool> requestLoan(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.requestLoanUrl, data);
      if (res == null) {
        return false;
      } else {
        var body = res;
        print(body['save']);
        if (body['save']) {
          getLoanList();
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> requestDeposit(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.getDepositUrl, data);
        print("RES :: ${res}");

      if (res == null) {
        return false;
      } else {
        var body = res;
        // print(body['save']);
        print("BODY :: ${body}");
        if (body['save']) {
          // getDepositList(); //getDepositList();

          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> getDepositList() async {
    try {
      var sharedPref = SharedPreferencesManager();
      var user = jsonDecode(await sharedPref.getString(AppConstants.user));
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).getRequest("${AppConstants.getDepositUrl}?q=s&id=${user['id']}");
      if (res == null) {
        return false;
      } else {
        var body = res;
        if (body["error"] == false) {
          _depositlist = body['data'];
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
