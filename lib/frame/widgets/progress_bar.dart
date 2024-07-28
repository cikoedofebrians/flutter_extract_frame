import 'package:flutter/material.dart';
import 'package:flutter_extract_frame/frame/controllers/frame_controller.dart';
import 'package:get/get.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FrameController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Stack(
          children: [
            Container(
              width: Get.width - 32,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              width: (Get.width - 32) *
                  (controller.imagePaths.length /
                      controller.expectedNumberOfImages),
              height: 6,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
            "${((controller.imagePaths.length / controller.expectedNumberOfImages) * 100).toStringAsFixed(0)}%"),
      ],
    );
  }
}
