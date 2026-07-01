class AppLink {
  static const String server = "http://192.168.1.12:8000/api";

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String signUpBuyer        = "$server/register/buyer";
  static const String signUpSeller       = "$server/register/seller";
  static const String login              = "$server/login";
  static const String fcmToken           = "$server/auth/fcm-token";
  static const String changePassword     = "$server/auth/change-password";
  static const String forgotPasswordOTP  = "$server/auth/forgot-password";
  static const String verifyResetOTP     = "$server/auth/verify-otp";
  static const String resetPasswordOTP   = "$server/auth/reset-password";

  // ─── Seller ───────────────────────────────────────────────────────────────
  static const String sellerWallet             = "$server/seller/wallet";
  static const String sellerWalletTransactions = "$server/seller/wallet/transactions";
  static const String sellerWalletStats        = "$server/seller/wallet/stats";
  static const String sellerWithdrawRequests   = "$server/seller/wallet/withdrawals";
  static const String sellerWithdraw           = "$server/seller/wallet/withdraw";
  static const String sellerBranches           = "$server/seller/branches";
  static const String sellerStaff              = "$server/seller/staff";
  static const String sellerStaffInvite        = "$server/seller/staff/invite";
  static const String sellerSupportTickets     = "$server/seller/support/tickets";
  static const String sellerOrders             = "$server/seller/orders";
  static const String sellerConversations      = "$server/conversations";

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
}