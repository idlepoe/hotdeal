import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hotdeal/screens/list_screen.dart';

Future<void> main() async {
  CustomImageCache();
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hotdeal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: false,
      ),
      home: ListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }


}

class CustomImageCache extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    print('createImageCache start');
    ImageCache imageCache = super.createImageCache();
    // Set your image cache size
    imageCache.maximumSizeBytes = 2000 * 1024 * 1024; //200mb 이상->캐시클리어

    return imageCache;
  }
}