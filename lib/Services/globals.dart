import 'package:flutter/material.dart';

<<<<<<< HEAD
const String baseURL = "http://192.168.178.72:8000/api/";  // link to laravel website
=======
const String baseURL = "http://145.101.75.218:8000/api/";  // link to laravel website
>>>>>>> 279b24f (Frontend flutter files uploaded)
const Map<String, String> headers = {"Content-type":"application/json"};

errorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      duration: const Duration(seconds: 3),
    )
  );
}