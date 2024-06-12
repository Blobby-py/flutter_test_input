import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test_input/Services/auth_services.dart';
import 'package:flutter_test_input/Services/globals.dart';
import 'package:flutter_test_input/rounded_button.dart';
import 'package:http/http.dart' as http;

import 'homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = "";
  String _password = "";

  loginPressed() async {
    if (_email.isNotEmpty && _password.isNotEmpty) {
      http.Response response = await AuthServices.login(_email, _password);
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()),
        );
      } else {
        errorSnackBar(context, responseMap.values.first);
      }
    } else {
      errorSnackBar(context, "Please Enter All Required Fields");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Top black bar that says "Login"
      appBar: AppBar (
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            // Inputfield for Email
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter your Email"
              ),
              onChanged: (value) {
                _email = value;
              }
            ),

            // Inputfield for Password
            const SizedBox(
              height: 20,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                  hintText: "Enter your Password"
              ),
              onChanged: (value) {
                _password = value;
              }
            ),

            // Login Button
            const SizedBox(
              height: 20,
            ),
            RoundedButton(
              btnText: "LOGIN",
              onBtnPressed:() => loginPressed(),
            ),

          ],
        ),
      )
    );
  }
}
