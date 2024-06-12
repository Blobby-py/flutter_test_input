import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test_input/Services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  fetchUserDetails() async {
    http.Response response = await AuthServices.fetchUserDetails();
    if (response.statusCode == 200) {
      setState(() {
        user = jsonDecode(response.body);
      });
    } else {
      print("Failed to fetch user details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Home Screen",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${user['id']}"),
            Text("Name: ${user['name']}"),
            Text("Email: ${user['email']}"),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

