class AppConstants {
  static const String appName = 'E-koba';
  static const double appVersion = 1.0;

  // Shared Preference Key
  static const String token = 'token';
  static const String user = 'user';
  static const String wallet = 'wallet';

  static const String customer = 'customer';
  static const String isLogin = 'is_login';
  static const String isNotFirstLogin = 'is_not_firstLogin';
  static const String language = 'lang';

  // API URLS
  // static const String apiBaseUrl = 'http://192.168.100.19:8000/';
  // static const String mediaBaseUrl = 'http://192.168.100.19:8000';
  // static const String apiBaseUrl = 'http://192.168.217.68:8000/';
  // static const String mediaBaseUrl = 'http://192.168.217.68:8000';
  static const String apiBaseUrl = 'http://157.245.109.105:7000/';
  static const String mediaBaseUrl = 'http://157.245.109.105:7000';

  static const String loginUrl = 'user-management/login-user';
  static const String registerMemberUrl = 'user-management/register-user';
  static const String requestLoanUrl = 'loan-management/request-get-loan';
  static const String getLoanUrl = 'loan-management/request-get-loan';
  static const String getDepositUrl = 'loan-management/loan-deposit';
  static const String getWalletUrl = 'wallet-management/create-get-wallet';
  static const String getWalletDepositUrl = 'wallet-management/wallet-deposit';

  static const String verifyOtpUrl = 'cargo/api/verify-otp';
  static const String shippedCargoUrl =
      'cargo/api/mobile/v1/customer-cargo/?s=1&c=';
  static const String arrivedCargoUrl =
      'cargo/api/mobile/v1/customer-cargo/?s=2&c=';
  static const String registerCustomerDeviceUrl = 'user-management/login';
  // get these credentials from the azampay developers account
  // var azampay = AzamPay(
  //     sandbox: true, // set to false on production
  //     appName: "Kikoba",
  //     clientId: "f74a6c8e-b095-470f-90d4-0affb7bca6db",
  //     clientSecret:
  //         "C8X834ViNTVeSyRn9I8QsO/lJJCeyMaVb9aYvryOJ5/ivvSNPrfliBFzj5moZ5W/UIAiAcJYvQ4s2grzVxVrc0ZEoVryG3fP5uW7kA0aGc4933s3iJU8ES1Mbq4SnVvZcAbUJjvlqqaOBgwOKhaH6uSBu2pz5fXS1grHuOHu3OD0UC3MKb1u73gky2wHGaF0bltUP1eUhY2nalxHAj3Z7GWvnudbpTjKKfMS6uZjpWvLWVC2jhQDXNpEOiy5bnC74t0WT6nkPyZByGJm1eglbbRDVQ21q7shgQ0vH5Z+u+VoCoiwd50DPh+ELXYCjf/+hjrgYfPt1PgDZN6qimtNaDoZu8d/jUKiCer9jfcVN6fH0UYSuh7Vw9SjduA3Qono1RmuIsUOTDZn7VgYtMU4a4fnxBe9HwKH3t3eco3/CrO87cyAlPr7EI65lXTddEXHS8edkwfn/H4wVq7L+aexcRMARMZcyCrpksvY1OiuvbklhPbjEZh4tDdPu47PNJJkYAvLyTnwJKqyJO8bP2eytpbztL57Vuta4yMS2CsKlrrzr+QblEoRDhxX+huP1pXHl8mBdAj+tEpb5WrTCKbxMn9lxdWDnmCM2jny+Ni55FksfZJtXYBNJPYagwl4aNd2xYomO5loadYYrJVaYOtYHJ4Yuuev93X8Eajwyal5fvc=",
  //     token: "fce9f8a0-2e03-4de9-afaa-5e65f0d1908d");
}
