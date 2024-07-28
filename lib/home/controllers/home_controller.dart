import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_extract_frame/frame/views/frame_page.dart';
import 'package:flutter_extract_frame/video/views/video_page.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';

class HomeController extends GetxController {
  final Rxn<Uint8List> _imageData = Rxn();

  Uint8List? get imageData => _imageData.value;

  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  loadingState() => _isLoading.value = true;

  unloadingState() => _isLoading.value = false;

  static const MethodChannel _imageChannel = MethodChannel('imageChannel');
  static const MethodChannel _deviceChannel = MethodChannel('deviceChannel');

  @override
  void onInit() async {
    await loadImage();
    super.onInit();
  }

  Future<void> loadImage() async {
    _imageData.value = await getImageBytes('assets/image.jpg');
    decodeImage(imageData!);
  }

  RxList<Uint8List> imageList = <Uint8List>[].obs;

  processImage() async {
    if (isLoading) return;
    loadingState();
    try {
      final decodedImage = decodeImage(imageData!);
      if (decodedImage == null) return;
      final Map<String, dynamic> arguments = {
        'image': imageData,
        'fps': 20,
        'width': decodedImage.width,
        'height': decodedImage.height,
        'duration': 10,
      };
      final List<Object?> processedImagesPaths =
          await _imageChannel.invokeMethod('processImage', arguments);

      Get.toNamed(FramePage.route, arguments: {
        'imagePaths': processedImagesPaths.cast<String>(),
        'expectedNumberOfImages': 20 * 10,
        'imageHeight': decodedImage.height,
        'imageWidth': decodedImage.width,
      });

      unloadingState();
    } catch (e) {
      unloadingState();
      Get.snackbar("ERROR", e.toString());
    }
  }

  processVideoAndNavigate() async {
    if (isLoading) return;
    loadingState();
    try {
      if (imageData != null) {
        final decodedImage = decodeImage(imageData!);
        if (decodedImage != null) {
          final processedVideo = await processImageToVideo(
            image: imageData!,
            fps: 20,
            width: decodedImage.width,
            height: decodedImage.height,
            duration: 10,
          );

          if (processedVideo != null) {
            Get.toNamed(VideoPage.route, arguments: processedVideo);
          }
        }
      }
      unloadingState();
    } catch (e) {
      unloadingState();
      Get.snackbar("ERROR", e.toString());
    }
  }

  Future<void> getDeviceInfo() async {
    final deviceInfo = await _deviceChannel.invokeMethod('deviceInfo');
    showModalBottomSheet(
      showDragHandle: true,
      context: Get.context!,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Device Name",
                style: Get.textTheme.titleMedium,
              ),
              Text(deviceInfo['deviceName']),
              const SizedBox(height: 12),
              Text(
                "iOS Version",
                style: Get.textTheme.titleMedium,
              ),
              Text(deviceInfo['systemVersion']),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> processImageToVideo({
    required Uint8List image,
    required int fps,
    required int width,
    required int height,
    required double duration,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'image': image,
        'fps': fps,
        'width': width,
        'height': height,
        'duration': duration,
      };
      final String? processedVideo =
          await _imageChannel.invokeMethod('processVideo', arguments);
      return processedVideo;
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> getImageBytes(String imagePath) async {
    final ByteData byteData = await rootBundle.load(imagePath);
    return byteData.buffer.asUint8List();
  }
}
