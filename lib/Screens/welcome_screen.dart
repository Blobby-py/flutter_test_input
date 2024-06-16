import 'dart:ui';
import 'package:flutter/material.dart';
import '../rounded_button.dart';
import 'login_screen.dart';
import 'story_screen.dart'; // Importeer het nieuwe scherm

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterView view = WidgetsBinding.instance!.platformDispatcher!.views.first;
    Size size = view.physicalSize;
    double height = size.height / 9;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Zorg ervoor dat je een achtergrondafbeelding hebt in je assets-map
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.0), // Semi-transparante overlay
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start, // Lijn de inhoud bovenaan uit
            children: [
              SizedBox(height: height), // Ruimte vanaf de bovenkant van het scherm
              FractionallySizedBox(
                widthFactor: 0.6, // 60% van de schermbreedte
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Items horizontaal uitrekken
                    children: [
                      const Text(
                        "Welcome,\ntraveller",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32, // Vergroot lettergrootte
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      RoundedButton(
                        btnText: "Login",
                        btnWidth: double.infinity, // Volledige breedte van de knop
                        btnTextStyle: const TextStyle(fontSize: 18), // Vergroot lettergrootte
                        onBtnPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      RoundedButton(
                        btnText: "Register",
                        btnWidth: double.infinity, // Volledige breedte van de knop
                        btnTextStyle: const TextStyle(fontSize: 18), // Vergroot lettergrootte
                        onBtnPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StoryScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
