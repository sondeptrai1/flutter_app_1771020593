import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App - 1771020593',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),

      /// 🔥 Firebase Auth tự quản lý đăng nhập / đăng xuất
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Đang kiểm tra trạng thái đăng nhập
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ Đã đăng nhập
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // ❌ Chưa đăng nhập
          return const LoginScreen();
        },
      ),
    );
  }
}
