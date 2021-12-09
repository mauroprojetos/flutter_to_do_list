import 'dart:convert';
import 'dart:io';

import 'package:to_do_list/constants/app_constants.dart';
import 'package:to_do_list/models/user.dart';

class UserService {
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
}
