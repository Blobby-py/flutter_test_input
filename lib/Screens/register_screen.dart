import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_test_input/Services/auth_services.dart";
import "package:flutter_test_input/rounded_button.dart";
import 'package:http/http.dart' as http;
import "../Services/globals.dart";
import "homescreen.dart";
import "login_screen.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _email = "";
  String _password = "";
  String _name = "";

  createAccountPressed() async {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_email);

    if (emailValid) {
      http.Response response = await AuthServices.register(_name, _email, _password);
      Map responseMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        http.Response loginResponse = await AuthServices.login(_email, _password);
        Map loginResponseMap = jsonDecode(loginResponse.body);

        if (loginResponse.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()),
          );
        } else {
          errorSnackBar(context, loginResponseMap.values.first);
        }
      } else {
        errorSnackBar(context, responseMap.values.first[0]);
      }
    } else {
      errorSnackBar(context, "Email Not Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Registration",
          style: TextStyle (
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )
        )
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(

          // Contains all input fields
          children: [

            // Inputfield for Name
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Name"
              ),
              onChanged: (value) {
                _name = value;
              }
            ),

            // Inputfield for Email
            const SizedBox(
              height: 20,
            ),
            TextField(
                decoration: const InputDecoration(
                    hintText: "Email"
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
                    hintText: "Password"
                ),
                onChanged: (value) {
                  _password = value;
                }
            ),

            // Create account button
            const SizedBox(
              height: 40
            ),
            RoundedButton(
              btnText: "Create Account",
              btnWidth: double.infinity, // Full width button
              btnTextStyle: const TextStyle(fontSize: 18), // Increased font size
              onBtnPressed: () {
                createAccountPressed();
              },
            ),



            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> const LoginScreen(),
                ));
              },
              child: const Text(
                "Already have an account",
                style: TextStyle (
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

          ],

        ),
      ),
    );
  }
}
