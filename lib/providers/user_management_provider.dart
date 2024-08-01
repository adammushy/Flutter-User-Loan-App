// import 'dart:convert';

// ignore_for_file: prefer_typing_uninitialized_variables, duplicate_import, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/helper/api/api_client_http.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';

class UserManagementProvider with ChangeNotifier {
  var _userData;
  var _userList;

  get getUserData => _userData;
  get getUserList => _userList;

  Future<bool> setUserData() async {
    var sharedPref = SharedPreferencesManager();
    _userData = jsonDecode(await sharedPref.getString(AppConstants.user));
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>> verifyPhone(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.loginUrl, data);
      if (res == null) {
        return {};
      } else {
        var body = res;
        print(body);
        if (body.containsKey('customer')) {
          var sharedPref = SharedPreferencesManager();
          sharedPref.saveString(
              AppConstants.customer, json.encode(body['customer']));
          return body;
        }
        return {};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<bool> verifyOtp(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.verifyOtpUrl, data);
      if (res == null) {
        return false;
      } else {
        var body = res;
        print(body.containsKey('success'));
        if (body.containsKey('success')) {
          var sharedPref = SharedPreferencesManager();
          sharedPref.saveString(AppConstants.user, json.encode(body['user']));
          sharedPref.saveString(AppConstants.token, json.encode(body['token']));
          setUserData();
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> loginUser(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.loginUrl, data);
      if (res == null) {
        return false;
      } else {
        var body = res;
        print(body);
        if (body['login']) {
          var sharedPref = SharedPreferencesManager();
          sharedPref.saveString(AppConstants.user, json.encode(body['user']));
          sharedPref.saveString(AppConstants.token, json.encode(body['token']));
          setUserData();
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> registerMember(ctx, data) async {
    try {
      var res = await ApiClientHttp(headers: <String, String>{
        'Content-Type': 'application/json',
      }).postRequest(AppConstants.registerMemberUrl, data);
      if (res == null) {
        return false;
      } else {
        var body = res;
        print(body['save']);
        if (body['save']) {
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

class UserInfoProvider with ChangeNotifier {
  Map<String, dynamic> userInfo = {};

  void setUserInfo(Map<String, dynamic> info) {
    userInfo = info;
    notifyListeners();
  }
}
