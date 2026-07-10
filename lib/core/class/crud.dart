import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/check_internet.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Crud {

  Map<String, String> _setHeaders(Map<String, String>? customHeaders) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }


  Future<Either<StatusRequest, Map>> getData(String linkurl, {Map<String, String>? headers}) async {
    try {
      if (await checkInternet()) {
        var response = await http.get(
          Uri.parse(linkurl),
          headers: _setHeaders(headers),
        ).timeout(const Duration(seconds: 15));

        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }


  Future<Either<StatusRequest, Map>> postData(String linkurl, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      if (await checkInternet()) {
        var response = await http.post(
          Uri.parse(linkurl),
          body: jsonEncode(data),
          headers: _setHeaders(headers),
        ).timeout(const Duration(seconds: 15));

        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }


  Future<Either<StatusRequest, Map>> postDataWithFiles(String linkurl, Map<String, String> data, Map<String, File> files, {Map<String, String>? headers}) async {
    try {
      if (await checkInternet()) {
        var request = http.MultipartRequest("POST", Uri.parse(linkurl));

        Map<String, String> finalHeaders = {'Accept': 'application/json'};
        if (headers != null) finalHeaders.addAll(headers);
        request.headers.addAll(finalHeaders);

        request.fields.addAll(data);

        for (var entry in files.entries) {
          var file = entry.value;
          var stream = http.ByteStream(file.openRead());
          stream.cast();
          var length = await file.length();

          var multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: basename(file.path),
          );
          request.files.add(multipartFile);
        }

        var myrequest = await request.send().timeout(const Duration(seconds: 15));
        var response = await http.Response.fromStream(myrequest);

        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  /// HTTP DELETE — used for deleting products.
  Future<Either<StatusRequest, Map>> deleteData(
    String linkurl, {
    Map<String, String>? headers,
  }) async {
    try {
      if (await checkInternet()) {
        var response = await http
            .delete(Uri.parse(linkurl), headers: _setHeaders(headers))
            .timeout(const Duration(seconds: 15));
        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  /// HTTP PATCH — used for partial resource updates.
  Future<Either<StatusRequest, Map>> patchData(
    String linkurl,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      if (await checkInternet()) {
        var response = await http.patch(
          Uri.parse(linkurl),
          body: jsonEncode(data),
          headers: _setHeaders(headers),
        ).timeout(const Duration(seconds: 15));
        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  /// HTTP PUT — used for resource updates.
  Future<Either<StatusRequest, Map>> putData(
    String linkurl,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      if (await checkInternet()) {
        var response = await http.put(
          Uri.parse(linkurl),
          body: jsonEncode(data),
          headers: _setHeaders(headers),
        ).timeout(const Duration(seconds: 15));
        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  /// HTTP PUT multipart — used for updating products with images.
  Future<Either<StatusRequest, Map>> putDataWithFiles(
    String linkurl,
    Map<String, String> data,
    Map<String, File> files, {
    Map<String, String>? headers,
  }) async {
    try {
      if (await checkInternet()) {
        // Use POST with _method=PUT to bypass Laravel multipart PUT limitation
        var request = http.MultipartRequest("POST", Uri.parse(linkurl));
        data['_method'] = 'PUT';

        Map<String, String> finalHeaders = {'Accept': 'application/json'};
        if (headers != null) finalHeaders.addAll(headers);
        request.headers.addAll(finalHeaders);

        request.fields.addAll(data);

        for (var entry in files.entries) {
          var file = entry.value;
          var stream = http.ByteStream(file.openRead());
          stream.cast();
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            entry.key,
            stream,
            length,
            filename: basename(file.path),
          );
          request.files.add(multipartFile);
        }

        var myrequest =
            await request.send().timeout(const Duration(seconds: 30));
        var response = await http.Response.fromStream(myrequest);
        return _handleResponse(response);
      } else {
        return const Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }

  Either<StatusRequest, Map> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      dynamic decoded = jsonDecode(response.body);
      Map responsebody = decoded is List ? {'data': decoded} : decoded;
      return Right(responsebody);
    } else if (response.statusCode == 422 || response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 429 || response.statusCode == 400) {
      dynamic decoded = jsonDecode(response.body);
      Map responsebody = decoded is List ? {'data': decoded} : decoded;
      return Right(responsebody);
    } else {
      return const Left(StatusRequest.serverfailure);
    }
  }
}