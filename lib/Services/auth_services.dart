import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart';

class AuthServices {
  static String? token; // Variable to store the token

  // Register new user
  static Future<http.Response> register(String name, String email, String password) async {
    Map data = {
      "name": name,
      "email": email,
      "password": password,
    };

    var body = json.encode(data);
    var url = Uri.parse("${baseURL}auth/register");
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print(response.body);
    return response;
  }

  // Login user
  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };

    var body = json.encode(data);
    var url = Uri.parse("${baseURL}auth/login");
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      token = responseData['token']; // Save the token
    }

    print(response.body);
    return response;
  }

  // Fetch user details
  static Future<http.Response> fetchUserDetails() async {
    var url = Uri.parse("${baseURL}auth/me");
    http.Response response = await http.get(
      url,
      headers: {
        ...headers,
        "Authorization": "Bearer $token", // Add the token to the headers
      },
    );

    print(response.body);
    return response;
  }
}
