import 'package:flutter_extract_frame/video/controllers/video_binding.dart';
import 'package:flutter_extract_frame/video/views/video_page.dart';
import 'package:get/get.dart';

final videoRoute = GetPage(
  name: VideoPage.route,
  page: () => const VideoPage(),
  binding: VideoBinding(),
);
