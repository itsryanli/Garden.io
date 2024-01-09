import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:gardenio/components/my_button.dart";
import "package:gardenio/components/my_textfield.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // email editing controller
  final emailController = TextEditingController();

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
          .sendPasswordResetEmail(email: emailController.text.trim());

      // pop the loading circle
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // show success message
      showMessage("Password Reset Email Sent!");

      Future.delayed(const Duration(seconds: 2), () {
      // navigate back to login page
      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
    });
      
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
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Image.asset(
                  'assets/logo.png', // Update with your image asset path
                  width: 80,
                  height: 80,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Receive an email to reset your password!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                //email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscuretext: false,
                ),

                const SizedBox(height: 25),

                // reset password button
                MyButton(
                  text: "Reset Password",
                  onTap: resetPassword,
                ),

                const SizedBox(height: 25),

                // back to login page?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Login to your account?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Go back now',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
