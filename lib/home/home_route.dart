import 'package:flutter_extract_frame/home/controllers/home_binding.dart';
import 'package:flutter_extract_frame/home/views/home_page.dart';
import 'package:get/route_manager.dart';

final homeRoute = GetPage(
  name: HomePage.route,
  page: () => const HomePage(),
  binding: HomeBinding(),
);
