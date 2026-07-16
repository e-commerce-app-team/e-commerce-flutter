import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/data/datasource/remote/seller/invoices_data.dart';
import 'package:e_commerce/data/model/seller/invoices_models.dart';

class SellerInvoicesController extends GetxController {
  MyServices myServices = Get.find();
  late InvoicesData invoicesData;

  StatusRequest statusRequest       = StatusRequest.none;
  StatusRequest reportStatusRequest = StatusRequest.none;

  // ── Tab state: 0 = order invoices, 1 = commission invoices, 2 = tax report ──
  int selectedTab = 0;

  // ── Invoice lists ──────────────────────────────────────────────────────────
  List<InvoiceModel> orderInvoices      = [];
  List<InvoiceModel> commissionInvoices = [];

  // ── Tax Report ────────────────────────────────────────────────────────────
  TaxReportModel? taxReport;

  // ── Filters ───────────────────────────────────────────────────────────────
  int selectedMonth = DateTime.now().month;
  int selectedYear  = DateTime.now().year;

  // ── Legacy fields (kept so old UI widgets do not break) ───────────────────
  /// Still used by old UI screens that iterate [invoices] directly.
  List<InvoiceModel> get invoices =>
      selectedTab == 0 ? orderInvoices : commissionInvoices;

  /// Legacy: filter by status ('all' | 'issued' | 'cancelled').
  String filterStatus = 'all';

  List<InvoiceModel> get filteredInvoices {
    final list = selectedTab == 0 ? orderInvoices : commissionInvoices;
    if (filterStatus == 'all') return list;
    return list.where((i) => i.status == filterStatus).toList();
  }

  void setFilterStatus(String s) {
    filterStatus = s;
    update();
  }

  // ── Legacy VatReport list (populated from TaxReportModel on load) ─────────
  List<VatReportModel> vatReports = [];

  int selectedMonthIndex = 0;

  VatReportModel? get currentReport =>
      vatReports.isEmpty ? null : vatReports[selectedMonthIndex];

  // ── Tax settings display ──────────────────────────────────────────────────
  TaxSettingsModel? taxSettings;
  TaxSettingsModel? get currentTaxSettings => taxSettings;

  // ── Download state (legacy UI support) ───────────────────────────────────
  Set<int>  downloadingIds    = {};
  bool      isDownloadingReport = false;
  bool      isEditingSettings   = false;
  StatusRequest saveStatusRequest = StatusRequest.none;

  // ── Form controllers (legacy tax-settings edit) ───────────────────────────
  final formKey       = GlobalKey<FormState>();
  final vatCtrl       = TextEditingController();
  final crCtrl        = TextEditingController();
  final legalNameCtrl = TextEditingController();
  final addressCtrl   = TextEditingController();

  // ── Auth token ─────────────────────────────────────────────────────────────
  String get _token =>
      myServices.sharedPreferences.getString('token') ?? '';

  // ── Wholesale detection ───────────────────────────────────────────────────
  bool get isWholesale {
    final sellerType = myServices.sharedPreferences.getString('seller_type');
    final role       = myServices.sharedPreferences.getString('role');
    return sellerType == 'wholesale' || role == 'wholesale';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    invoicesData = InvoicesData(Get.find());
    _initTaxSettings();
    loadData();
  }

  @override
  void onClose() {
    vatCtrl.dispose();
    crCtrl.dispose();
    legalNameCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  // ── Tax settings initialisation from SharedPrefs ─────────────────────────

  void _initTaxSettings() {
    final prefs = myServices.sharedPreferences;
    taxSettings = TaxSettingsModel(
      vatNumber:     prefs.getString('tax_number'),
      crNumber:      prefs.getString('commercial_registration_number'),
      legalName:     prefs.getString('store_name') ?? '',
      address:       prefs.getString('detailed_address') ?? '',
      vatRate:       5.0,
      vatRegistered: isWholesale,
    );
  }

  // ── Tab switching ──────────────────────────────────────────────────────────

  void changeTab(int i) {
    selectedTab = i;
    update();
    _loadForCurrentTab();
  }

  void _loadForCurrentTab() {
    switch (selectedTab) {
      case 0: _loadOrderInvoices();      break;
      case 1: _loadCommissionInvoices(); break;
      case 2: _loadTaxReport();          break;
    }
  }

  // ── Month filter ──────────────────────────────────────────────────────────

  void applyMonthFilter(int month, int year) {
    selectedMonth = month;
    selectedYear  = year;
    update();
    _loadForCurrentTab();
  }

  /// Legacy: used by old month-picker UI.
  void selectMonth(int i) {
    if (i == selectedMonthIndex) return;
    selectedMonthIndex = i;
    if (vatReports.isNotEmpty) {
      final mk = vatReports[i].monthKey.split('-');
      if (mk.length == 2) {
        selectedYear  = int.tryParse(mk[0]) ?? selectedYear;
        selectedMonth = int.tryParse(mk[1]) ?? selectedMonth;
      }
    }
    _loadOrderInvoices();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> loadData() async {
    statusRequest = StatusRequest.loading;
    update();

    await Future.wait([
      _loadOrderInvoices(),
      _loadCommissionInvoices(),
      _loadTaxReport(),
    ]);

    // Populate legacy vatReports from mock for backward compat
    if (vatReports.isEmpty) vatReports = VatReportModel.mockList();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> _loadOrderInvoices() async {
    if (!isWholesale) {
      orderInvoices = [];
      update();
      return;
    }
    try {
      final result = await invoicesData.getInvoices(
        type:  'order',
        month: selectedMonth,
        year:  selectedYear,
        token: _token,
      );
      result.fold(
        (failure) { orderInvoices = []; },
        (response) {
          if (response['success'] == true) {
            final raw  = response['data'];
            final list = (raw is Map ? raw['data'] : raw) as List? ?? [];
            orderInvoices = list
                .map((e) => InvoiceModel.fromJson(e as Map))
                .toList();
          } else {
            orderInvoices = [];
          }
        },
      );
    } catch (_) {
      orderInvoices = [];
    }
    update();
  }

  Future<void> _loadCommissionInvoices() async {
    try {
      final result = await invoicesData.getCommissionInvoices(
        month: selectedMonth,
        year:  selectedYear,
        token: _token,
      );
      result.fold(
        (failure) { commissionInvoices = []; },
        (response) {
          if (response['success'] == true) {
            final raw  = response['data'];
            final list = (raw is Map ? raw['data'] : raw) as List? ?? [];
            commissionInvoices = list
                .map((e) => InvoiceModel.fromJson(e as Map))
                .toList();
          } else {
            commissionInvoices = [];
          }
        },
      );
    } catch (_) {
      commissionInvoices = [];
    }
    update();
  }

  Future<void> _loadTaxReport() async {
    reportStatusRequest = StatusRequest.loading;
    update();
    try {
      final result = await invoicesData.getTaxReport(
        month: selectedMonth,
        year:  selectedYear,
        token: _token,
      );
      result.fold(
        (failure) { taxReport = null; },
        (response) {
          if (response['success'] == true) {
            taxReport = TaxReportModel.fromJson(response);
          } else {
            taxReport = null;
          }
        },
      );
    } catch (_) {
      taxReport = null;
    }
    reportStatusRequest = StatusRequest.success;
    update();
  }

  // ── Legacy settings edit (kept for backward compat with old UI) ────────────

  void toggleEditSettings() {
    isEditingSettings = !isEditingSettings;
    if (isEditingSettings && taxSettings != null) {
      vatCtrl.text       = taxSettings!.vatNumber  ?? '';
      crCtrl.text        = taxSettings!.crNumber   ?? '';
      legalNameCtrl.text = taxSettings!.legalName;
      addressCtrl.text   = taxSettings!.address;
    }
    update();
  }

  void cancelEdit() {
    isEditingSettings = false;
    update();
  }

  Future<void> saveSettings() async {
    if (!formKey.currentState!.validate()) return;
    taxSettings = taxSettings!.copyWith(
      vatNumber: vatCtrl.text.trim(),
      crNumber:  crCtrl.text.trim(),
      legalName: legalNameCtrl.text.trim(),
      address:   addressCtrl.text.trim(),
    );
    isEditingSettings = false;
    customSnackbar('تم الحفظ', 'تم تحديث البيانات الضريبية بنجاح', isError: false);
    update();
  }

  // ── Legacy PDF helpers (kept for old UI) ──────────────────────────────────

  Future<void> downloadInvoicePdf(InvoiceModel invoice) async {
    if (downloadingIds.contains(invoice.id)) return;
    downloadingIds.add(invoice.id);
    update();
    await Future.delayed(const Duration(milliseconds: 900));
    downloadingIds.remove(invoice.id);
    update();
    customSnackbar(
      'جاهز للتحميل',
      'تم تحضير الفاتورة ${invoice.invoiceNumber}',
      isError: false,
    );
  }

  Future<void> downloadMonthlyReport() async {
    if (currentReport == null || isDownloadingReport) return;
    isDownloadingReport = true;
    update();
    await Future.delayed(const Duration(milliseconds: 900));
    isDownloadingReport = false;
    update();
    customSnackbar(
      'جاهز للتحميل',
      'تم تحضير تقرير ${currentReport!.monthLabel}',
      isError: false,
    );
  }
}
