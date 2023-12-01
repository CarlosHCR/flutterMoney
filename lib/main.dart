import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prova_2/views/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCRd6aiIFf8ZUUFFTfwkkmNz0SahpA6y8o",
          appId: "1:676424367905:android:c08f77658cfcfba01a0860",
          messagingSenderId: "676424367905",
          projectId: "prova-f3cb2"));


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpPage(),
    );
  }
}
