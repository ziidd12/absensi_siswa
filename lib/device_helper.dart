import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'; // Tambahkan ini untuk kIsWeb

class DeviceHelper {
  static Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    // 1. Cek Web terlebih dahulu menggunakan kIsWeb
    // Ini mencegah error "Unsupported operation" dari Platform
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      // Karena Web tidak punya hardware ID unik yang permanen, 
      // kita gunakan hash dari userAgent atau vendor sebagai identitas.
      return "web_${webBrowserInfo.userAgent.hashCode}";
    }

    // 2. Jika bukan Web, baru aman untuk menggunakan Platform (Android/iOS)
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; 
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown_ios";
    }

    return "unknown_device";
  }
}