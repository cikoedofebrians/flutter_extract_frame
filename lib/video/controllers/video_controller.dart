import 'dart:io';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideController extends GetxController {
  late final String videoPath;

  late final Rx<VideoPlayerController> _videoPlayerController;
  VideoPlayerController get videoPlayerController =>
      _videoPlayerController.value;

  final RxBool _isPlaying = true.obs;
  bool get isPlaying => _isPlaying.value;

  @override
  void onInit() async {
    videoPath = Get.arguments;
    _videoPlayerController = VideoPlayerController.file(File(videoPath)).obs;
    _videoPlayerController.value.addListener(_onVideoPlayerChanged);
    super.onInit();
  }

  @override
  void onReady() async {
    await _videoPlayerController.value.initialize();
    _isPlaying.value = false;
    super.onReady();
  }

  void _onVideoPlayerChanged() {
    if ((videoPlayerController.value.isPlaying && !isPlaying) ||
        !videoPlayerController.value.isPlaying && isPlaying) {
      _isPlaying.value = !isPlaying;
    }
  }

  @override
  void onClose() {
    _videoPlayerController.value.dispose();
    super.onClose();
  }
}
