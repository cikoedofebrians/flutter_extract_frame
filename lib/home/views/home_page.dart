import 'package:flutter/material.dart';
import 'package:flutter_extract_frame/home/controllers/home_controller.dart';
import 'package:flutter_extract_frame/home/widgets/home_button.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const route = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    controller.imageData != null
                        ? Image.memory(controller.imageData!)
                        : const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HomeButton(
                            title: "Generate Images",
                            onPressed: controller.processImage,
                            subtitle: "May takes 1-2 minutes to complete",
                            color: Colors.red,
                            icon: Icons.photo,
                          ),
                          const SizedBox(height: 8),
                          HomeButton(
                            title: "Convert Images to MP4",
                            onPressed: controller.processVideoAndNavigate,
                            subtitle: "May takes 1-3 minutes to complete",
                            color: Colors.green,
                            icon: Icons.video_file,
                          ),
                          const SizedBox(height: 8),
                          HomeButton(
                            title: "Get Device Info",
                            onPressed: controller.getDeviceInfo,
                            subtitle: "Retrieve device information",
                            color: Colors.blue,
                            icon: Icons.settings_rounded,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "*Functionality only works on iOS platform",
                            style: Get.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: controller.isLoading,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
