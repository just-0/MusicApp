import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chivero/components/my_button.dart';
import 'package:chivero/components/my_textfield.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key}); // No 'const' aquí

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUserIn () async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
       password: passwordController.text
      );
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 50),
              Text(
                "¡Bienvenido de vuelta!",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),
              MyTextfield(
                controller: emailController,
                hintText: "Correo del Usuario",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                controller: passwordController,
                hintText: "Contraseña",
                obscureText: true,
              ),
              const SizedBox(height: 50),
              MyButton(
                onTap: signUserIn,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
