import 'dart:convert';
import 'dart:io';

import 'package:to_do_list/constants/app_constants.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/user.dart';

class TasksService {
  // SEARCH
  static Future getTasks() async {
    final client = HttpClient();

    return await client
        .postUrl(Uri.parse('$baseUrl/api/task/search/'))
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

      return request.close();
    });
  }

  // NEW
  static Future newTask(String taskname) async {
    final client = HttpClient();
    return await client
        .postUrl(Uri.parse('$baseUrl/api/task/new/'))
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
        "name": taskname,
      });

      request.write(body);
      return request.close();
    });
  }

  // UPDATE
  static Future updateTask(Task task) async {
    final client = HttpClient();
    return await client
        .putUrl(Uri.parse('$baseUrl/api/task/update/'))
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
        "id": task.id,
        "name": task.name,
        "realized": task.realized,
      });

      request.write(body);
      return request.close();
    });
  }

  // DELETE
  static Future deleteTask(int taskId) async {
    final client = HttpClient();
    return await client
        .deleteUrl(Uri.parse('$baseUrl/api/task/delete/'))
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
        "id": taskId,
      });

      request.write(body);
      return request.close();
    });
  }
}
