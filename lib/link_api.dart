class AppLink{
  static const String server = "http://192.168.1.11:8000/api";

  static const String signUpBuyer = "$server/register/buyer";
  static const String signUpSeller = "$server/register/seller";
  static const String login        = "$server/login";
  static const String fcmToken = "$server/auth/fcm-token";
  static const String changePassword     = "$server/auth/change-password";
  static const String forgotPasswordOTP  = "$server/auth/forgot-password";
  static const String verifyResetOTP     = "$server/auth/verify-otp";
  static const String resetPasswordOTP   = "$server/auth/reset-password";
  static const String sellerWallet             = "$server/seller/wallet";
  static const String sellerWalletTransactions = "$server/seller/wallet/transactions";
  static const String sellerWalletStats        = "$server/seller/wallet/stats";
  static const String sellerWithdrawRequests   = "$server/seller/wallet/withdrawals";
  static const String sellerWithdraw           = "$server/seller/wallet/withdraw";
}