import 'dart:async';
import 'dart:io';

Future<bool> checkInternet() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on TimeoutException {
    return false;
  } on SocketException {
    return false;
  }
}
