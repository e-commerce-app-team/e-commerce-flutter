import 'package:e_commerce/core/constant/routes.dart';
import 'package:e_commerce/core/middleware/my_middleware.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/forgetpassword.dart';
import 'package:e_commerce/view/screen/auth/login.dart';
import 'package:e_commerce/view/screen/auth/select_account_type.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/resetpassword.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/success_resetpassword.dart';
import 'package:e_commerce/view/screen/auth/signup/signup_buyer.dart';
import 'package:e_commerce/view/screen/auth/signup/signup_seller.dart';
import 'package:e_commerce/view/screen/auth/success_signup.dart';
import 'package:e_commerce/view/screen/auth/forgetpassword/verifycode.dart';
import 'package:e_commerce/view/screen/auth/verifycodesignup.dart';
import 'package:e_commerce/view/screen/onboarding.dart';
import 'package:e_commerce/view/screen/seller/branches/branch_form_screen.dart';
import 'package:e_commerce/view/screen/seller/branches/branch_location_picker_screen.dart';
import 'package:e_commerce/view/screen/seller/branches/branches_screen.dart';
import 'package:e_commerce/view/screen/seller/dashboard/drawer/ads_screen.dart';
import 'package:e_commerce/view/screen/seller/dashboard/drawer/seller_coupons_screen.dart';
import 'package:e_commerce/view/screen/seller/dashboard/drawer/spin_wheel_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/change_password_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/invoices_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/shipping_settings_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/store_edit_screen.dart';
import 'package:e_commerce/view/screen/seller/profile/wallet_screen.dart';
import 'package:e_commerce/view/screen/seller/seller_main_screen.dart';
import 'package:e_commerce/view/screen/seller/staff/staff_screen.dart';
import 'package:e_commerce/view/screen/seller/support/support_center_screen.dart';
import 'package:e_commerce/view/screen/seller/support/ticket_details_screen.dart';
import 'package:e_commerce/view/screen/seller/support/tickets_screen.dart';
import 'package:e_commerce/view/widget/seller/seller_drawer.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';
import 'package:e_commerce/view/screen/seller/chat/chat_settings_screen.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? routes = [

  GetPage(name: "/", page: () => const OnBoarding(), middlewares: [

    MyMiddleWare()

  ]),

  GetPage(name: AppRoute.login, page: () => const Login()),

  GetPage(name: AppRoute.selectAccountType, page: () => const SelectAccountType()),

  GetPage(name: AppRoute.signUpBuyer, page: () => const SignUpBuyer()),

  GetPage(name: AppRoute.signUpSeller, page: () => const SignUpSeller()),

  GetPage(name: AppRoute.forgetPassword, page: () => const ForgetPassword()),

  GetPage(name: AppRoute.verfiyCode, page: () => const VerfiyCode()),

  GetPage(name: AppRoute.resetPassword, page: () => const ResetPassword()),

  GetPage(name: AppRoute.successResetpassword, page: () => const SuccessResetPassword()),

  GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),

  GetPage(name: AppRoute.verfiyCodeSignUp, page: () => const VerfiyCodeSignUp()),

  GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),
  GetPage(name: AppRoute.sellerMain, page: () => const SellerMainScreen()),
  GetPage(name: AppRoute.sellerDrawer, page: () => const SellerDrawer()),
  GetPage(name: AppRoute.spinWheele, page: () => const SpinWheelScreen()),
  GetPage(name: AppRoute.ads, page: () => const AdsScreen()),
  GetPage(name: AppRoute.sellerInvoices, page: () => const InvoicesScreen()),
  GetPage(name: AppRoute.changePassword, page: () => const ChangePasswordScreen()),
  GetPage(name: AppRoute.coupons, page: () => const SellerCouponsScreen()),
  GetPage(name: AppRoute.sellerWallet, page: () => const WalletScreen()),
  GetPage(name: AppRoute.storeEdit, page: () => const StoreEditScreen()),
  GetPage(name: AppRoute.shippingSettings, page: () => const ShippingSettingsScreen()),
  GetPage(name: AppRoute.sellerBranches, page: () => const BranchesScreen()),
  GetPage(name: AppRoute.branchForm,page: () => const BranchFormScreen()),
  GetPage(name: AppRoute.branchLocationPicker, page: () {
     final args = Get.arguments;
     return BranchLocationPickerScreen(
       initialLat: args?.latitude,
       initialLng: args?.longitude,
     );

   }),
  GetPage(name: AppRoute.sellerStaff, page: () => const StaffScreen()),
  GetPage(name: AppRoute.sellerSupport, page: () => const SupportCenterScreen()),
  GetPage(name: AppRoute.sellerTickets, page: () => const TicketsScreen()),
  GetPage(name: AppRoute.ticketDetails, page: () => const TicketDetailsScreen()),
  GetPage(name: AppRoute.chatSettings, page: () => ChatSettingsScreen(
    ctrl: Get.find<SellerChatController>(),
  )),
];
