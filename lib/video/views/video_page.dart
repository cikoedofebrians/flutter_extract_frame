import 'package:flutter/material.dart';
import 'package:flutter_extract_frame/video/controllers/video_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends GetView<VideController> {
  const VideoPage({super.key});

  static const route = '/video-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: Get.back,
                child: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            Obx(
              () => AspectRatio(
                aspectRatio: controller.videoPlayerController.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(
                      controller.videoPlayerController,
                    ),
                    AnimatedOpacity(
                      opacity: controller.isPlaying ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: controller.isPlaying
                            ? controller.videoPlayerController.pause
                            : controller.videoPlayerController.play,
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black.withOpacity(0.7),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
