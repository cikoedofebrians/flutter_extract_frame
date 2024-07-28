import 'package:flutter_extract_frame/video/controllers/video_controller.dart';
import 'package:get/get.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideController());
  }
}
