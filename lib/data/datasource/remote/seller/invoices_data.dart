import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class InvoicesData {
  final Crud crud;
  InvoicesData(this.crud);

  /// GET /invoices?type=order|commission&month=M&year=Y
  Future<Either<StatusRequest, Map>> getInvoices({
    String? type,
    int? month,
    int? year,
    String? token,
  }) async {
    final url = StringBuffer(AppLink.invoices);
    final params = <String>[];
    if (type  != null) params.add('type=$type');
    if (month != null) params.add('month=$month');
    if (year  != null) params.add('year=$year');
    if (params.isNotEmpty) url.write('?${params.join('&')}');

    return await crud.getData(
      url.toString(),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }

  /// GET /invoices/order/{orderId}
  Future<Either<StatusRequest, Map>> getOrderInvoice(
    int orderId, {
    String? token,
  }) async {
    return await crud.getData(
      '${AppLink.invoiceOrderDetail}/$orderId',
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }

  /// GET /invoices/commission?month=M&year=Y
  Future<Either<StatusRequest, Map>> getCommissionInvoices({
    int? month,
    int? year,
    String? token,
  }) async {
    final url = StringBuffer(AppLink.invoiceCommission);
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year  != null) params.add('year=$year');
    if (params.isNotEmpty) url.write('?${params.join('&')}');

    return await crud.getData(
      url.toString(),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }

  /// GET /invoices/tax-report?month=M&year=Y
  Future<Either<StatusRequest, Map>> getTaxReport({
    int? month,
    int? year,
    String? token,
  }) async {
    final url = StringBuffer(AppLink.invoiceTaxReport);
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year  != null) params.add('year=$year');
    if (params.isNotEmpty) url.write('?${params.join('&')}');

    return await crud.getData(
      url.toString(),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }
}
