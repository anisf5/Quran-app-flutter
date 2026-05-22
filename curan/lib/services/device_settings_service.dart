import 'dart:io';
import 'package:flutter/services.dart';

class DeviceSettingsService {
  static const _channel = MethodChannel('com.example.curan/settings');

  Future<bool> openSecuritySettings() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('openSecuritySettings');
        return true;
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('openSecuritySettings');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
