import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  // send email button to reset password
  void resetPassword() async {
    //showing loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: user.email!);

      // pop the loading circle
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // show success message
      showMessage("Password Reset Email Sent!");
      
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // show error message
      showMessage(e.code);
    }
  }

  // message to user
  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green[200],
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: Container(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              // First Content Box
              const Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),

              Container(
                color: Colors.lightGreen[100],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: Container(
                        alignment: Alignment.center,
                        child: Text.rich(
                          TextSpan(
                            text: 'Email:  ',
                            style: const TextStyle(
                              fontWeight: FontWeight
                                  .normal, 
                            ),
                            children: [
                              TextSpan(
                                text: user.email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: resetPassword,
                      child: const Text('Reset Password'),
                    ),
                  ],
                ),
              ),

              // Vertical Space
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
