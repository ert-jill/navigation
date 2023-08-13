import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navigator/common/services/geolocation_service.dart';

import 'index.dart';

class HomeController extends GetxController {
  // Location location = Location();
  GeoLocationService geoLocationService = Get.put(GeoLocationService());

  /// 在 onInit() 之后调用 1 帧。这是进入的理想场所
  @override
  void onReady() {
    super.onReady();
  }

  /// 在 [onDelete] 方法之前调用。
  @override
  void onClose() {
    super.onClose();
  }

  /// dispose 释放内存
  @override
  void dispose() {
    super.dispose();
  }
}
