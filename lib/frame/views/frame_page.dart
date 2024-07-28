import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_extract_frame/frame/controllers/frame_controller.dart';
import 'package:flutter_extract_frame/frame/widgets/progress_bar.dart';
import 'package:get/get.dart';

class FramePage extends StatelessWidget {
  const FramePage({super.key});

  static const route = '/frame-page';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FrameController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: Get.back,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Processed Images",
                style: Get.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const ProgressView(),
              const SizedBox(height: 8),
              Expanded(
                  child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      controller.imageWidth / controller.imageHeight,
                ),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(
                      controller.imagePaths[index],
                    ),
                    cacheHeight: controller.imageHeight ~/ 10,
                    cacheWidth: controller.imageWidth ~/ 10,
                    fit: BoxFit.cover,
                  ),
                ),
                itemCount: controller.imagePaths.length,
              ))
            ],
          ),
        ),
      ),
    );
  }
}
