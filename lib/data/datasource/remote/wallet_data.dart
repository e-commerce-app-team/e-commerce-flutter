import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/link_api.dart';

class WalletDataSource {
  final Crud crud;
  WalletDataSource(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<Either<StatusRequest, Map>> summary(String token) =>
      crud.getData(AppLink.walletSummary, headers: _auth(token));
  Future<Either<StatusRequest, Map>> history(String token) =>
      crud.getData(AppLink.walletTransactions, headers: _auth(token));
  Future<Either<StatusRequest, Map>> requestDeposit(
    String token,
    double amount,
  ) => crud.postData(AppLink.walletDepositRequests, {
    'amount': amount,
    'payment_method': 'manual',
  }, headers: _auth(token));
  Future<Either<StatusRequest, Map>> requestWithdrawal(
    String token,
    double amount, {
    String method = 'manual',
    String account = 'Manual',
  }) => crud.postData(AppLink.walletWithdrawals, {
    'amount': amount,
    'payout_method': method,
    'payout_account': account,
  }, headers: _auth(token));
  Future<Either<StatusRequest, Map>> myQr(String token) =>
      crud.getData(AppLink.walletQr, headers: _auth(token));
  Future<Either<StatusRequest, Map>> resolveQr(String token, String payload) =>
      crud.postData(AppLink.walletQrResolve, {
        'payload': payload,
      }, headers: _auth(token));
  Future<Either<StatusRequest, Map>> transfer(
    String token,
    String recipientToken,
    double amount,
  ) => crud.postData(AppLink.walletTransfers, {
    'recipient_token': recipientToken,
    'amount': amount,
    'idempotency_key': '${DateTime.now().microsecondsSinceEpoch}',
  }, headers: _auth(token));
  Future<Either<StatusRequest, Map>> recipients(String token, String query) =>
      crud.getData(
        '${AppLink.walletRecipients}?query=${Uri.encodeQueryComponent(query)}',
        headers: _auth(token),
      );
  Future<Either<StatusRequest, Map>> payOrder(String token, String orderId) =>
      crud.postData(AppLink.buyerPayOrder(orderId), {}, headers: _auth(token));
  Future<Either<StatusRequest, Map>> orderPaymentQr(
    String token,
    String subOrderId,
  ) => crud.postData(
    AppLink.subOrderPaymentQr(subOrderId.replaceAll(RegExp(r'[^0-9]'), '')),
    {},
    headers: _auth(token),
  );
}
