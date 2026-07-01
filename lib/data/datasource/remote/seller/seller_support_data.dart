import 'dart:io';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/link_api.dart';

class SellerSupportData {
  final Crud crud;
  SellerSupportData(this.crud);

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<dynamic> getTickets(String token) async =>
      await crud.getData(AppLink.sellerSupportTickets, headers: _auth(token));

  Future<dynamic> createTicket(
    String token, {
    required Map<String, String> data,
    required Map<String, File> files,
  }) async =>
      await crud.postDataWithFiles(
        AppLink.sellerSupportTickets,
        data,
        files,
        headers: _auth(token),
      );

  Future<dynamic> getTicketMessages(String token, int ticketId) async =>
      await crud.getData(
        '${AppLink.sellerSupportTickets}/$ticketId',
        headers: _auth(token),
      );

  Future<dynamic> replyToTicket(
    String token,
    int ticketId, {
    required Map<String, String> data,
    required Map<String, File> files,
  }) async =>
      await crud.postDataWithFiles(
        '${AppLink.sellerSupportTickets}/$ticketId/reply',
        data,
        files,
        headers: _auth(token),
      );
}
