import 'package:employee_info/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';


SharedPreferences? sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  initFirebase();

  runApp(const MyApp());
}

void initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var _firebaseMessaging = FirebaseMessaging.instance;
  _firebaseMessaging.requestPermission();
  _firebaseMessaging.subscribeToTopic("allDevices");
  initForegroundMessages();
  initOpendAppBackgroundMessages();



  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void initForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message data: ${message.data}");
  });
}

void initOpendAppBackgroundMessages() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Message: ${message.data}");
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sharedPreferences?.setString('notify', "yes");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amira Markets',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
