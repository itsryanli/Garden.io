import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gardenio/screen/home_screen.dart';
import 'package:gardenio/screen/login_or_register_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
            //if user is logged in
            if (snapshot.hasData) {
              return const HomeScreen();
            }

            //if user is NOT logged in
            else{
              return const LoginOrRegisterScreen();
            }
        },
      ),
    );
  }
}