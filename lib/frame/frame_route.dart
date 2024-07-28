import 'package:flutter_extract_frame/frame/controllers/frame_binding.dart';
import 'package:flutter_extract_frame/frame/views/frame_page.dart';
import 'package:get/get.dart';

final frameRoute = GetPage(
    name: FramePage.route,
    page: () => const FramePage(),
    binding: FrameBinding());
