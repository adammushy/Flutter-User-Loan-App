// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:loan_user_app/providers/user_management_provider.dart';
import 'package:provider/provider.dart';
import '../sign_in/sign_in_screen.dart';
import 'components/my_account_screen.dart';
import 'components/profile_header.dart';
import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData;

  setUserData() {
    var data =
        Provider.of<UserManagementProvider>(context, listen: false).getUserData;
    setState(() {
      userData = data;
    });
    print(userData);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<UserManagementProvider>(context, listen: false).setUserData();
    setUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileHeader(),
            const SizedBox(height: 40),
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: "assets/icons/User Icon.svg",
              press: () {
                // Navigator.pushNamed(context, MyAccountScreen.routeName);
              },
            ),
            ProfileMenu(
              text: userData['email'].toString(),
              icon: "assets/icons/Bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: userData['usertype'].toString(),
              icon: "assets/icons/Settings.svg",
              press: () {},
            ),
            ProfileMenu(
              text: userData['phone_number'].toString(),
              icon: "assets/icons/Question mark.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/Log out.svg",
              press: () {
                // Navigate to the SignInScreen when Log Out is pressed
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  SignInScreen.routeName,
                  (route) =>
                      false, // Remove all routes and only show SignInScreen
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
