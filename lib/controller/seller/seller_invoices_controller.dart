import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/custom_snackbar.dart';
import 'package:e_commerce/data/model/seller/invoices_models.dart';

class SellerInvoicesController extends GetxController {

  StatusRequest statusRequest     = StatusRequest.none;
  StatusRequest saveStatusRequest = StatusRequest.none;

  TaxSettingsModel?    taxSettings;
  List<InvoiceModel>   invoices   = [];
  List<VatReportModel> vatReports = [];

  int    selectedMonthIndex  = 0;
  String filterStatus        = 'all';
  bool   isEditingSettings   = false;
  Set<int> downloadingIds    = {};
  bool   isDownloadingReport = false;

  List<InvoiceModel> get filteredInvoices {
    if (filterStatus == 'all') return invoices;
    return invoices.where((i) => i.status == filterStatus).toList();
  }

  VatReportModel? get currentReport =>
      vatReports.isEmpty ? null : vatReports[selectedMonthIndex];

  final formKey       = GlobalKey<FormState>();
  final vatCtrl       = TextEditingController();
  final crCtrl        = TextEditingController();
  final legalNameCtrl = TextEditingController();
  final addressCtrl   = TextEditingController();


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

  void selectMonth(int i) {
    if (i == selectedMonthIndex) return;
    selectedMonthIndex = i;
    _loadInvoicesForMonth();
  }

  void setFilterStatus(String s) {
    filterStatus = s;
    update();
  }

  Future<void> saveSettings() async {
    if (!formKey.currentState!.validate()) return;
    saveStatusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 700));
    // TODO: await invoicesData.updateTaxSettings(data);

    taxSettings = taxSettings!.copyWith(
      vatNumber:  vatCtrl.text.trim(),
      crNumber:   crCtrl.text.trim(),
      legalName:  legalNameCtrl.text.trim(),
      address:    addressCtrl.text.trim(),
    );
    isEditingSettings = false;
    saveStatusRequest = StatusRequest.success;
    customSnackbar('تم الحفظ', 'تم تحديث البيانات الضريبية بنجاح', isError: false);
    update();
  }

  Future<void> downloadInvoicePdf(InvoiceModel invoice) async {
    if (downloadingIds.contains(invoice.id)) return;
    downloadingIds.add(invoice.id);
    update();

    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: final path = await invoicesData.downloadPdf(invoice.id);

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
    // TODO: final path = await invoicesData.downloadMonthlyReport(currentReport!.monthKey);
    // await OpenFile.open(path);

    isDownloadingReport = false;
    update();
    customSnackbar(
      'جاهز للتحميل',
      'تم تحضير تقرير ${currentReport!.monthLabel}',
      isError: false,
    );
  }

  // ── Data Loading ──────────────────────────────────────────

  Future<void> loadData() async {
    statusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(milliseconds: 700));
    // TODO: var res = await invoicesData.getData();

  //  taxSettings = TaxSettingsModel.mock();
    vatReports  = VatReportModel.mockList();
    invoices    = InvoiceModel.mockList();

    statusRequest = StatusRequest.success;
    update();
  }

  Future<void> _loadInvoicesForMonth() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: invoices = await invoicesData.getInvoices(monthKey: vatReports[selectedMonthIndex].monthKey);
    invoices = InvoiceModel.mockList();
    update();
  }

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
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
}
