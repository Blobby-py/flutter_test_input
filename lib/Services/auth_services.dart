import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart';

class AuthServices {
  static String? token;

  // Function to register a new user
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

    return response;
  }

  // Function to log the user in
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
      token = responseData['token'];
    }

    return response;
  }

  // Function to grab all the user data from backend
  static Future<http.Response> fetchUserDetails() async {
    var url = Uri.parse("${baseURL}auth/me");
    http.Response response = await http.get(
      url,
      headers: {
        ...headers,
        "Authorization": "Bearer $token",
      },
    );

    return response;
  }

  // Function to grab all the tasks connected to a specific user
  static Future<http.Response> fetchUserTasks(int userId) async {
    var url = Uri.parse("${baseURL}tasks/show/$userId");
    http.Response response = await http.get(
      url,
      headers: {
        ...headers,
        "Authorization": "Bearer $token",
      },
    );

    return response;
  }

  // Function to delete a specific task from backend
  static Future<http.Response> deleteTask(int taskId) async {
    var url = Uri.parse("${baseURL}tasks/destroy/$taskId");
    http.Response response = await http.delete(
      url,
      headers: {
        ...headers,
        "Authorization": "Bearer $token",
      },
    );

    print(response.body);
    return response;
  }

  // Function to create a new task
  static Future<http.Response> createTask(String taskName, String description, DateTime? startDate, DateTime? endDate, var userId) async {
    Map data = {
      "name": taskName,
      "description": description,
      "start_date": startDate?.toIso8601String(),
      "end_date": endDate?.toIso8601String(),
      "finished": false,
      "user_id":userId
    };

    var body = json.encode(data);
    var url = Uri.parse("${baseURL}tasks/store");
    http.Response response = await http.post(
      url,
      headers: {
        ...headers,
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",  // Specify that JSON file format is used
      },
      body: body,
    );

    return response;
  }

}

