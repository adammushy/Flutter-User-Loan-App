// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:loan_user_app/constants/app_constants.dart';
import 'package:loan_user_app/providers/user_management_provider.dart';
import 'package:loan_user_app/providers/wallet_management_provider.dart';
import 'package:loan_user_app/shared-preference-manager/preference-manager.dart';
import 'package:provider/provider.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../login_success/login_success_screen.dart';

class SignForm extends StatefulWidget {
  const SignForm({Key? key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? username;
  String? password;
  bool? remember = false;
  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => username = newValue,
            controller: usernameController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kUserNameNullError);
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kUserNameNullError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => password = newValue,
            controller: passwordController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                removeError(error: kPassNullError);
              } else if (value.length >= 2) {
                removeError(error: kShortPassError);
              }
              return;
            },
            // validator: (value) {
            //   // if (value!.isEmpty) {
            //   //   addError(error: kPassNullError);
            //   //   return "";
            //   // } else if (value.length < 2) {
            //   //   addError(error: kShortPassError);
            //   //   return "";
            //   // }
            //   // return null;
            // },
            decoration: const InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              const Text("Remember me"),
              const Spacer(),
              // GestureDetector(
              //   onTap: () => Navigator.pushNamed(
              //       context, ForgotPasswordScreen.routeName),
              //   child: const Text(
              //     "Forgot Password",
              //     style: TextStyle(decoration: TextDecoration.underline),
              //   ),
              // )
            ],
          ),
          FormError(errors: errors),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                var data = {
                  "email": usernameController.text,
                  "password": passwordController.text
                };
                bool result = await Provider.of<UserManagementProvider>(context,
                        listen: false)
                    .loginUser(context, data);
                if (result) {
                  var sharedPref = SharedPreferencesManager();

                  sharedPref.saveBool(AppConstants.isLogin, true);
                  sharedPref.saveBool(AppConstants.isNotFirstLogin, true);
                  Provider.of<WalletManagementProvider>(context,listen: false).getWallet();
                  
                  Navigator.pushNamed(context, LoginSuccessScreen.routeName);
                  KeyboardUtil.hideKeyboard(context);
                } else {}
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
