import 'package:get/get.dart';

class FrameController extends GetxController {
  late final List<String> imagePaths;
  late final int expectedNumberOfImages;

  late final int imageWidth;
  late final int imageHeight;

  @override
  void onInit() {
    imagePaths = Get.arguments['imagePaths'];
    expectedNumberOfImages = Get.arguments['expectedNumberOfImages'];
    imageHeight = Get.arguments['imageHeight'];
    imageWidth = Get.arguments['imageWidth'];
    super.onInit();
  }
}
