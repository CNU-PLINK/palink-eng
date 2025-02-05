import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:palink_v2/domain/model/user/user.dart';
import 'package:palink_v2/domain/usecase/login_usecase.dart';
import 'package:palink_v2/presentation/screens/auth/view/login_view.dart';
import 'package:palink_v2/presentation/screens/chatting/view/chat_sample.dart';
import 'package:palink_v2/presentation/screens/chatting/view/quest_sample.dart';
import 'package:palink_v2/presentation/screens/main_screens.dart';
import 'package:sizing/sizing.dart';

import 'di/locator.dart';

Future<void> main() async {
  await dotenv.load(fileName: "lib/config/.env");
  await setupLocator();
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SizingBuilder(
      builder: () => GetMaterialApp(
        color: Colors.white,
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => _initialScreen()), // Set initial route
          GetPage(name: '/login', page: () => LoginView()), // Login screen route
          GetPage(name: '/main', page: () => const MainScreens()), // Main screen route
          GetPage(name: '/chat', page: () => ChatSample()), // Chat screen route
          GetPage(name: '/quest', page: () => QuestSample()), // Quest screen route
        ],
      ),
    );
  }

  // Function to determine the initial screen (Check for auto-login)
  Widget _initialScreen() {
    return FutureBuilder<User?>(
      future: _checkAutoLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          return const MainScreens(); // Navigate to the main screen upon successful auto-login
        } else {
          return LoginView(); // Navigate to the login screen upon failed auto-login
        }
      },
    );
  }

  // Function to check for auto-login
  Future<User?> _checkAutoLogin() async {
    final loginUseCase = GetIt.instance<LoginUseCase>();
    return await loginUseCase.checkAutoLogin();
  }
}
