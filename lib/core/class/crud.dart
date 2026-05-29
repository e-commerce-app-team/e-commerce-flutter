import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/functions/check_internet.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class Crud {

  Future<Either<StatusRequest, Map>> postData(String linkurl,
      Map <String, String> data) async {
    try {
      if (await checkInternet()) {
        var response = await http.post(
            Uri.parse(linkurl), body: data, headers: {
          'Accept': 'application/json',}).timeout(Duration(seconds: 15));
        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else if
         (response.statusCode == 422 || response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 429|| response.statusCode == 400) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return Left(StatusRequest.serverfailure);
        }
      } else {
        return Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }


  //****************************


  Future<Either<StatusRequest, Map>> postDataWithFiles(String linkurl,
      Map<String, String> data, Map<String, File> files) async {
    try {
      if (await checkInternet()) {
        var request = http.MultipartRequest("POST", Uri.parse(linkurl));
        request.headers.addAll({
          'Accept': 'application/json',
        });
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
              filename: basename(file.path)
          );
          request.files.add(multipartFile);
        }

        var myrequest = await request.send().timeout(const Duration(seconds: 15));;
        var response = await http.Response.fromStream(myrequest);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else if
        (response.statusCode == 422 || response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 429 || response.statusCode == 400) {
          Map responsebody = jsonDecode(response.body);
          return Right(responsebody);
        } else {
          return Left(StatusRequest.serverfailure);
        }
      } else {
        return Left(StatusRequest.offlinefailure);
      }
    } on TimeoutException {
      return const Left(StatusRequest.serverfailure);
    } on SocketException {
      return const Left(StatusRequest.offlinefailure);
    } catch (e) {
      return const Left(StatusRequest.serverfailure);
    }
  }
}
