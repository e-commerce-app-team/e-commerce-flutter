/*import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerInvoicesData {
  Crud crud;
  SellerInvoicesData(this.crud);

  /// GET /seller/invoices?month=YYYY-MM
  Future<dynamic> getInvoices({String? monthKey}) async {
    return await crud.postData(
      AppLink.sellerInvoices,
      monthKey != null ? {'month': monthKey} : {},
    );
  }

  /// GET /seller/invoices/vat-reports
  Future<dynamic> getVatReports() async {
    return await crud.postData(AppLink.sellerVatReports, {});
  }

  /// GET /seller/tax-settings
  Future<dynamic> getTaxSettings() async {
    return await crud.postData(AppLink.sellerTaxSettings, {});
  }

  /// POST /seller/tax-settings
  Future<dynamic> updateTaxSettings(Map<String, String> data) async {
    return await crud.postData(AppLink.sellerTaxSettings, data);
  }

  /// GET /seller/invoices/{id}/pdf  →  returns download URL
  Future<dynamic> getInvoicePdfUrl(int invoiceId) async {
    return await crud.postData(
      '${AppLink.sellerInvoices}/$invoiceId/pdf',
      {},
    );
  }

  /// GET /seller/invoices/report/{monthKey}/pdf
  Future<dynamic> getMonthlyReportUrl(String monthKey) async {
    return await crud.postData(
      '${AppLink.sellerInvoices}/report/$monthKey/pdf',
      {},
    );
  }
}*/
