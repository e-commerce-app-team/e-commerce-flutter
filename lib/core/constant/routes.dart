class AppRoute {
  static const String login = "/login";
  static const String onBoarding = "/onboarding";
  static const String signUp = "/signup";
  static const String selectAccountType = "/selectAccountType";

  static const String signUpBuyer = "/signupbuyer";
  static const String signUpSeller = "/signupseller";
  static const String signUpCompany = "/signupcompany";
  static const String forgetPassword = "/forgetpassword";
  static const String verfiyCode = "/verfiycode";
  static const String resetPassword = "/resetpassword";
  static const String successSignUp = "/successsignup";
  static const String successResetpassword = "/successresetpassword";
  static const String checkemail = "/checkemail";
  static const String verfiyCodeSignUp = "/verfiycodesignup";
  static const String verifyCodeSellerSignUp = "/verifycodesellersignup";
  static const String sellerMain = "/sellermain";
  static const String sellerDrawer = "/sellerdrawer";
  static const String spinWheele = "/spinwheel";
  static const String ads = "/ads";
  static const String sellerInvoices = "/sellerinvoices";
  static const String changePassword = "/change-password";
  static const String coupons = "/coupons";
  static const String sellerWallet = "/wallet";
  static const String storeEdit = "/storeedit";
  static const String shippingSettings = "/shippingsettings";
  static const String sellerBranches        = "/seller/branches";
   static const String branchForm            = "/seller/branches/form";
   static const String branchLocationPicker  = "/seller/branches/location";

  static const String sellerStaff    = "/seller/staff";

  static const String sellerSupport = "/seller/support";
  static const String sellerTickets = "/seller/tickets";
  static const String ticketDetails = "/seller/tickets/details";

  static const String chatSettings = "/chat-settings";
  static const String languageSettings = "/seller/language-settings";
  static const String themeSettings    = "/seller/theme-settings";
  static const String sellerProfile = "/seller/profile";
  static const String buyerMain = "/buyerMain";
  static const String explore = "/explore";

  // ─── Staff Invitation ──────────────────────────────────────────────────────
  /// Route opened when a staff member clicks the invitation link in their email.
  /// Expects Get.arguments = {'token': '...', 'store_name': '...'}
  static const String staffAcceptInvite = "/staff/accept-invite";
}