import 'dart:io';

import 'package:firebase_auths/common/extensions.dart';

class Helpers {
  static double convertToDouble(var value) {
    double val = 0.0;
    if (value == null) return val;
    switch (value.runtimeType) {
      case int:
        val = value.toDouble();
        break;
      case String:
        val = double.tryParse(value) ?? val;
        break;

      default:
        val = value;
    }
    return val;
  }

  static int convertToInt(var value, {int defaultVal = 0}) {
    int val = defaultVal;
    if (value == null) return val;
    switch (value.runtimeType) {
      case double:
        return value.toInt();

      case String:
        return int.tryParse(value) ?? val;

      default:
        return value;
    }
  }

  static Future<bool> isInternetAvailable({bool enableToast = true}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        if (enableToast) "No Internet".showToast;
        return false;
      }
    } on SocketException catch (_) {
      if (enableToast) "No Internet".showToast;
      return false;
    }
  }
}
