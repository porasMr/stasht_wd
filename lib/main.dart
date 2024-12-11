import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

// Import your app-specific screens
import 'package:stasht/modules/create_memory/create_memory.dart';
import 'package:stasht/modules/login_signup/presentation/pages/forgot_password_screen.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_in.dart';
import 'package:stasht/modules/login_signup/presentation/pages/sign_up.dart';
import 'package:stasht/modules/onboarding/onboarding_screen.dart';
import 'package:stasht/modules/photos/photos_screen.dart';
import 'package:stasht/modules/splash/pages/splash_screen.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/pref_utils.dart';
import 'package:stasht/utils/welcome_screen.dart';

import 'bottom_bar_visibility_provider.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue
    ..userInteractions = true
    ..dismissOnTap = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully");
    FirebaseApp app = Firebase.app();
    FirebaseOptions options = app.options;
    debugPrint("Firebase Project ID: ${options.appId}");
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }
  await PrefUtils.instance.init();
 await dotenv.load(fileName: "assets/.env");

   configLoading();

  runApp(
    ChangeNotifierProvider(
      create: (context) => BottomBarVisibilityProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Declare a GlobalKey for Navigator
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      builder: EasyLoading.init(),
      navigatorKey: navigatorKey, // Pass the navigatorKey here
      routes: <String, WidgetBuilder>{
        '/WelComeScreen': (BuildContext context) => const WelcomeScreen(),
        '/SignIn': (BuildContext context) => const SignIn(),
        '/ForgotPassword': (BuildContext context) => const ForgotPassword(),
        '/Signup': (BuildContext context) => const Signup(),
        '/PhotosView': (BuildContext context) => PhotosView(photosList: [],isSkip: false,),
        '/MyProfileScreen': (BuildContext context) => const OnboardScreen(),
        '/CreateMemoryScreen': (BuildContext context) =>
            CreateMemoryScreen(photosList: [], future: [], isBack: false),
      },
      theme: ThemeData(
        fontFamily: robotoRegular,
        primaryColor: AppColors.primaryColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }

}

