import 'package:flutter/material.dart';
import 'package:flutter_extract_frame/app_route.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Extract Frame',
      getPages: appRoute,
    );
  }
}
