import 'dart:convert';
import 'dart:io';

import 'package:to_do_list/constants/app_constants.dart';
import 'package:to_do_list/models/user.dart';

class UserService {
  // SIGNUP
  static Future create(User user) async {
    final client = HttpClient();
    return await client
        .postUrl(Uri.parse('$baseUrl/api/user/new/'))
        .then((HttpClientRequest request) async {
      request.headers.add(
        'Content-type',
        'application/json',
        preserveHeaderCase: true,
      );
      final body = jsonEncode({
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "password": user.password
      });

      request.write(body);
      return request.close();
    });
  }

  // SIGNIN
  static Future read(String username, String password) async {
    final client = HttpClient();
    return await client
        .postUrl(Uri.parse('$baseUrl/api/user/login/'))
        .then((HttpClientRequest request) async {
      request.headers.add(
        'Content-type',
        'application/json',
        preserveHeaderCase: true,
      );
      final body = jsonEncode({
        'username': username,
        'password': password,
      });

      request.write(body);
      return request.close();
    });
  }

  // USER PROFILE - UPDATE
  static Future update(User user) async {
    final client = HttpClient();
    return await client
        .putUrl(Uri.parse('$baseUrl/api/user/update/'))
        .then((HttpClientRequest request) async {
      request.headers.add(
        'Content-type',
        'application/json',
        preserveHeaderCase: true,
      );
      request.headers.add(
        'Authorization',
        currentUser.token.toString(),
        preserveHeaderCase: true,
      );
      final body = jsonEncode({
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "password": user.password,
        "picture": user.picture,
      });

      request.write(body);
      return request.close();
    });
  }

  static Future updateuserpass(User user, List<String> newData) async {
    final client = HttpClient();
    return await client
        .putUrl(Uri.parse('$baseUrl/api/user/updateuserpass/'))
        .then((HttpClientRequest request) async {
      request.headers.add(
        'Content-type',
        'application/json',
        preserveHeaderCase: true,
      );
      request.headers.add(
        'Authorization',
        currentUser.token.toString(),
        preserveHeaderCase: true,
      );
      final body = jsonEncode({
        "username": user.username,
        "password": user.password,
        "new_username": newData[0],
        "new_password": newData[1],
      });

      request.write(body);
      return request.close();
    });
  }

  // USER PROFILE - DELETE
  static Future delete(User user) async {
    final client = HttpClient();
    return await client
        .deleteUrl(Uri.parse('$baseUrl/api/user/delete/'))
        .then((HttpClientRequest request) async {
      request.headers.add(
        'Content-type',
        'application/json',
        preserveHeaderCase: true,
      );
      request.headers.add(
        'Authorization',
        currentUser.token.toString(),
        preserveHeaderCase: true,
      );
      final body = jsonEncode({
        'username': user.username,
        'password': user.password,
      });

      request.write(body);
      return request.close();
    });
  }
}
