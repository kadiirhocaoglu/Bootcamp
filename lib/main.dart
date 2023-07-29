import 'package:bootcamp/repository/user_repository/messaging_service.dart';
import 'package:bootcamp/routes/routes.dart';
import 'package:bootcamp/screens/auth/auth/auth_screen.dart';
import 'package:bootcamp/screens/home/home_screen.dart';
import 'package:bootcamp/screens/home/needs_screen.dart';
import 'package:bootcamp/screens/profile/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  

runApp(
    MultiProvider(
      providers: [
        Provider<MessagingService>(
          create: (_) => MessagingService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
  


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: Routes.home,
      routes: {
        Routes.help: (context) => const HomeScreen(),
        Routes.need: (context) => const NeedsScreen(),
        Routes.profile: (context) => const ProfileScreen(),

      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.blue),
      home: const AuthScreen(),
    );
  }
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print('Bildirim alındı: ${message.notification?.body}');
}