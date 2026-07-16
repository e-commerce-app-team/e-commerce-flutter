class AppLink {
  static const String server = "http://192.168.1.12:8000/api";

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String signUpBuyer        = "$server/register/buyer";
  static const String signUpSeller       = "$server/register/seller";
  static const String login              = "$server/login";
  
  // ─── OTP & 2FA ────────────────────────────────────────────────────────
  static const String verifyLoginOtp     = "$server/auth/login/verify-otp";
  
  // Pre-Registration OTP (التحقق قبل إنشاء الحساب)
  static const String sendSignupOtp      = "$server/auth/signup/send-otp";
  static const String verifySignupOtp    = "$server/auth/signup/verify-otp-pre";
  
  static const String fcmToken           = "$server/auth/fcm-token";
  static const String changePassword     = "$server/auth/change-password";
  static const String forgotPasswordOTP  = "$server/auth/forgot-password";
  static const String verifyResetOTP     = "$server/auth/verify-otp";
  static const String resetPasswordOTP   = "$server/auth/reset-password";
  
  // Resend OTP (موحد لجميع العمليات)
  static const String resendOtp          = "$server/auth/resend-otp";

  // Toggle 2FA
  static const String toggle2FA          = "$server/user/toggle-2fa";

  // ─── Seller ───────────────────────────────────────────────────────────────
  // Wallet - الـ endpoints الموجودة فعلاً على الباك
  static const String sellerWalletBalance      = "$server/balance";         // GET - رصيد البائع
  static const String sellerWalletHistory      = "$server/history";         // GET - سجل السحوبات
  static const String sellerWithdraw           = "$server/payouts/instant-withdraw"; // POST - سحب
  // Wallet - endpoints مطلوبة من الباك تيم (لم تُنفَّذ بعد)
  static const String sellerWallet             = "$server/seller/wallet";       // TODO: غير موجود بعد
  static const String sellerWalletTransactions = "$server/seller/wallet/transactions"; // TODO: غير موجود بعد
  static const String sellerWalletStats        = "$server/seller/wallet/stats"; // TODO: غير موجود بعد
  static const String sellerWithdrawRequests   = "$server/seller/wallet/withdrawals"; // TODO: غير موجود بعد
  static const String sellerBranches           = "$server/merchant/branches";
  static const String sellerStaff              = "$server/seller/staff";
  static const String sellerStaffInvite        = "$server/seller/staff/invite";
  static const String staffAcceptInvite        = "$server/auth/staff/accept-invite";
  static const String sellerSupportTickets     = "$server/seller/support/tickets"; // TODO: غير موجود بعد
  static const String sellerOrders             = "$server/seller/orders"; // TODO: غير موجود
  static const String sellerConversations      = "$server/conversations";

  // ─── Ads (Vendor) ──────────────────────────────────────────────────────
  static const String sellerAdTypes      = "$server/ads/types";
  static const String sellerAdsIndex     = "$server/ads/indexAd";
  static const String sellerAdsStore     = "$server/ads/storeAd";
  static const String sellerAdsShow      = "$server/ads"; // append: /{id}/showAd
  static const String sellerAdsUpdate    = "$server/ads"; // append: /{id}/updateAd
  static const String sellerAdsDestroy   = "$server/ads"; // append: /{id}/destroyAd
  static const String sellerAdsDashboard = "$server/ads/dashboard/stats";

  // ─── Coupons (Vendor) ──────────────────────────────────────────────────
  static const String sellerCouponsIndex   = "$server/vendor/coupons/index";
  static const String sellerCouponsStore   = "$server/vendor/coupons/store";
  static const String sellerCouponsShow    = "$server/vendor/coupons"; // append: /{id}/show
  static const String sellerCouponsUpdate  = "$server/vendor/coupons"; // append: /{id}/update
  static const String sellerCouponsToggle  = "$server/vendor/coupons"; // append: /{id}/toggle
  static const String sellerCouponsDestroy = "$server/vendor/coupons"; // append: /{id}/destroy
  static const String sellerCouponsStats   = "$server/vendor/coupons"; // append: /{id}/stats


  // ─── Inventory (Products & Categories) ───────────────────────────────────
  static const String products               = "$server/products";
  static const String productsSearch         = "$server/products/search";
  static const String productsSort           = "$server/products/sort";
  static const String productsFilterCategory = "$server/products/filter-by-category";
  static const String productsFilterStatus   = "$server/products/filter-by-status";
  static const String productsFilterStock    = "$server/products/filter-by-stock";
  static const String productsBulkAction     = "$server/products/bulk-action";
  static const String variants               = "$server/variants";
  static const String categories             = "$server/categories";

  // ─── Departments (Merchant Categories) ──────────────────────────────────
  static const String departments           = "$server/merchant/departments";
  static const String departmentsStore      = "$server/merchant/departments/store";
  static const String departmentsToggle     = "$server/merchant/departments/toggle-visibility";
  static const String departmentsReorder    = "$server/merchant/departments/reorder";

  // ─── Orders ─────────────────────────────────────────────────────────────
  static const String orders              = "$server/my-orders";
  static const String ordersBadges        = "$server/orders/badges";
  static const String ordersAccept        = "$server/orders/accept";
  static const String ordersReject        = "$server/orders/reject";
  static const String ordersUpdateTime    = "$server/orders/update-time";
  static const String ordersReadyShipping = "$server/orders/ready-shipping";

  // ─── Helpers ──────────────────────────────────────────────────────────────
  /// Constructs a full URL to a Laravel storage-hosted file.
  /// Example: AppLink.storageUrl('products/images/abc.jpg')
  static String storageUrl(String path) =>
      "${server.replaceAll('/api', '')}/storage/$path";
  // ─── Profile (Store Settings) ──────────────────────────────────────────────
  // الباك يستخدم /seller/store-settings - نوجّه إليها
  static const String sellerProfile          = "$server/seller/store-settings"; // GET
  static const String sellerProfileUpdate    = "$server/seller/store-settings/update"; // POST
  // Shipping - مطلوب من الباك تيم (غير موجود بعد)
  static const String sellerShippingSettings = "$server/seller/shipping-settings"; // TODO: غير موجود بعد

  // ─── Chat ──────────────────────────────────────────────────────────────────
  static const String chatQuickReplies    = "$server/chat/quick-replies";
  static const String chatAutoReplies     = "$server/chat/auto-replies";
  static const String chatBlockUser       = "$server/chat/block-user";
  static const String chatUnblockUser     = "$server/chat/unblock-user";
  static const String chatBlockedUsers    = "$server/chat/blocked-users";
  static const String chatReportUser      = "$server/chat/report-user";
  static const String chatFirebaseAuth    = "$server/chat/firebase-token";

  // ─── Invoices & Tax (NEW) ─────────────────────────────────────────────────
  static const String invoices            = "$server/invoices";
  static const String invoiceOrderDetail  = "$server/invoices/order"; // append: /{orderId}
  static const String invoiceCommission   = "$server/invoices/commission";
  static const String invoiceTaxReport    = "$server/invoices/tax-report";
  static const String adminSettings       = "$server/admin/settings";
}