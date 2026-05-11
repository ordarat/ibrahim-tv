import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBHVhQFFOyup2eBTAKDMWZFB5In07wMXOg",
      authDomain: "ibrahimtv-c0d5d.firebaseapp.com",
      projectId: "ibrahimtv-c0d5d",
      storageBucket: "ibrahimtv-c0d5d.firebasestorage.app",
      messagingSenderId: "658751407366",
      appId: "1:658751407366:web:5b34e69a4fd4de78330a87",
      // لێرەدا لینکە تایبەتەکەی داتابەیسەکەی تۆمان داناوە
      databaseURL: "https://ibrahimtv-c0d5d-default-rtdb.europe-west1.firebasedatabase.app", 
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ibrahim TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F18),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const HomeScreen(),
    );
  }
}
