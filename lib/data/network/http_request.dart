import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:firebase_auths/common/helpers.dart';
import 'package:http/http.dart' as http;

enum Exceptions { socketErr, serverErr, err, noData, authError }

class HttpReq {
  static final HttpReq _instance = HttpReq._internal();

  factory HttpReq() => _instance;

  HttpReq._internal();

  static const String _appJson = 'application/json';
  static String baseUrl = 'https://www.mocky.io/v2/';

  static Future<Either<Exceptions, String>> getRequest(String endPoint) async {
    try {
      bool networkStat = await Helpers.isInternetAvailable(enableToast: false);
      if (!networkStat) return const Left(Exceptions.socketErr);
      var response = await http.get(
        Uri.parse(baseUrl + endPoint),
        headers: <String, String>{
          HttpHeaders.acceptHeader: _appJson,
          HttpHeaders.contentTypeHeader: _appJson,
        },
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        return Right(response.body);
      }
      if (response.statusCode == 500) {
        return const Left(Exceptions.serverErr);
      }
    } catch (_) {
      return const Left(Exceptions.err);
    }
    return const Left(Exceptions.err);
  }
}
