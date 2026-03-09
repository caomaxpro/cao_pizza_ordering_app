import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_widget/flutter_custom_widget.dart';
import 'package:pizza_ordering_app/navigation/stack_navigation.dart';
import 'package:pizza_ordering_app/screen/customization/custom_screen.dart';
import 'package:pizza_ordering_app/screen/menu/menu.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop: set window options for Linux (example)
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    if (Platform.isLinux) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(416, 900),
        center: false,
        alwaysOnTop: true,
        backgroundColor: Color(0xFF1E1E1E),
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        windowButtonVisibility: true,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (context, child) {
        return MaterialApp(
          title: 'Pizza Ordering App',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: StackNavigator(screens: [MenuScreen()]),
        );
      },
    );
  }
}
