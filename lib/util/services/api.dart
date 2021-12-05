import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:to_do_list/constants/app_constants.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/user.dart';

class API {
  // --- USER ---

  // LOGIN
  static Future login(String username, String password) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
    };

    return await http.post(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/user/login/'),
      headers: requestHeaders,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
  }

  // NEW
  static Future newUser(User user) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
    };

    return await http.post(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/user/new/'),
      headers: requestHeaders,
      body: jsonEncode({
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "password": user.password
      }),
    );
  }

  // UPDATE
  static Future updateUser(User user) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': currentUser.token!
    };

    return await http.put(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/user/update/'),
      headers: requestHeaders,
      body: jsonEncode({
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "password": user.password,
        "picture": user.picture,
      }),
    );
  }

  // --- TASKS ---

  // SEARCH
  static Future getTasks() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': currentUser.token.toString()
    };

    return await http.post(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/task/search/'),
      headers: requestHeaders,
    );
  }

  // NEW
  static Future newTask(String taskname) async {
    Map<String, String> requestHeaders = {
      'content-type': 'application/json',
      'Authorization': currentUser.token.toString()
    };
    return await http.post(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/task/new/'),
      headers: requestHeaders,
      body: jsonEncode({
        "name": taskname,
      }),
    );
  }

  // UPDATE
  static Future updateTask(Task task) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': currentUser.token!
    };

    return await http.put(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/task/update/'),
      headers: requestHeaders,
      body: jsonEncode({
        "id": task.id,
        "name": task.name,
        "realized": task.realized,
      }),
    );
  }

  // DELETE
  static Future deleteTask(int taskId) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': currentUser.token!
    };
    return await http.delete(
      Uri.parse('${BaseUrl().avdToLocalhost}/api/task/delete/'),
      headers: requestHeaders,
      body: jsonEncode({
        "id": taskId,
      }),
    );
  }
}
