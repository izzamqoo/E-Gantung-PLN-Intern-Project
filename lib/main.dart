 // import 'package:egantung_fix/view/loginscreen.dart';
// import 'package:egantung_fix/view/registerScreen.dart';
import 'package:egantung_fix/view/HomeUserScreen.dart';
import 'package:egantung_fix/view/akun_screen.dart';
import 'package:egantung_fix/view/edit_profil_screen.dart';
import 'package:egantung_fix/view/ganti_password_screen.dart';
import 'package:egantung_fix/view/homescreen.dart';
import 'package:egantung_fix/view/user_login.dart';
import 'package:egantung_fix/view/user_register.dart';
import 'package:flutter/material.dart';
import 'view/loginscreen.dart';
import 'view/registerScreen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Gantung',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set halaman pertama saat app dibuka
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(), // jika sudah ada
        '/akun': (context) => const AkunScreen(),
        '/ubah-profil': (context) => const EditProfilScreen(),
        '/ganti-password': (context) => const GantiPasswordScreen(),
         '/userLogin': (context) => const UserLoginPage(),
         '/userRegister': (context) => const UserRegisterPage(),
         '/userHome': (context) => const HomeUserScreen(),
      },
    );
  }
}