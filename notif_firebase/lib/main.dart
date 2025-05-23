import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notif_firebase/firebase_options.dart';
import 'package:notif_firebase/pages/home_page.dart';
import 'package:notif_firebase/pages/home.dart';
import 'package:notif_firebase/pages/login.dart';
import 'package:notif_firebase/pages/register.dart';
import 'package:notif_firebase/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'login',
      routes: {
        'home': (context) => const HomePage(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'account': (context) => const HomeScreen(),
      },
    );
  }
}
