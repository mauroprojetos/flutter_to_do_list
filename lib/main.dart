import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// AVD TO LOCALHOST
const String baseUrl = 'http://10.0.2.2:8080/php-api-to-do-list';

class User {
  User(
    this.id,
    this.name,
    this.email,
    this.token,
  );

  final int id;
  final String name;
  final String email;
  final String token;

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        token = json['token'];
}

class Task {
  int id;
  int userId;
  String name;
  String date;
  int realized;

  Task(
    this.id,
    this.userId,
    this.name,
    this.date,
    this.realized,
  );

  Task.fromJson(Map json)
      : id = json['id'],
        userId = json['userId'],
        name = json['name'],
        date = json['date'],
        realized = json['realized'];
}

class API {
  // TASKS

  // SEARCH
  static Future getTasks() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': '123'
    };

    return await http.post(
      Uri.parse('$baseUrl/api/task/search/'),
      headers: requestHeaders,
    );
  }

  // NEW
  static Future newTask(String taskname) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': '123'
    };
    return await http.post(
      Uri.parse('$baseUrl/api/task/new/'),
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
      'Authorization': '123'
    };

    return await http.put(
      Uri.parse('$baseUrl/api/task/update/'),
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
      'Authorization': '123'
    };
    return await http.delete(
      Uri.parse('$baseUrl/api/task/delete/'),
      headers: requestHeaders,
      body: jsonEncode({
        "id": taskId,
      }),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const TaskList(),
    );
  }
}

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool isLoading = true;
  List taskList = [];

  final _newTaskFormKey = GlobalKey<FormState>();
  final TextEditingController _newTaskName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getTaskList();
  }

  _getTaskList() {
    isLoading = true;

    API.getTasks().then((response) {
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        setState(() {
          taskList = body[0] == null
              ? []
              : body.map((model) => Task.fromJson(model)).toList();
          isLoading = false;
        });
      }
    });
  }

  _taskList() {
    if (!isLoading) {
      return taskList.isEmpty
          ? const Center(
              child: Text('Não há tarefas criadas'),
            )
          : ListView.separated(
              itemCount: taskList.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return _taskTile(context, index);
              },
            );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  _taskTile(BuildContext context, index) {
    final task = taskList[index];
    return ListTile(
      title: Text(task.name),
      onTap: () async {
        var update = await showDialog(
          context: context,
          builder: (_) => EditTaskDialog(task: task),
        );

        if (update != null && update) {
          _getTaskList();
        }
      },
      leading: task.realized == 0
          ? const Icon(Icons.check_box_outline_blank)
          : const Icon(Icons.check_box_outlined),
    );
  }

  _createTask() async {
    if (_newTaskFormKey.currentState!.validate()) {
      final response = await API.newTask(_newTaskName.text);

      if (response.statusCode == 200) {
        _newTaskName.clear();
        Navigator.pop(context, true);
        _getTaskList();
      }
    }
  }

  _newTaskDialog() {
    return AlertDialog(
      title: const Text('Nova Tarefa'),
      content: Form(
        key: _newTaskFormKey,
        child: TextFormField(
          controller: _newTaskName,
          decoration: const InputDecoration(
            label: Text('Título'),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Preencha o título da tarefa';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            _newTaskName.clear();
            Navigator.pop(context, true);
          },
        ),
        TextButton(child: const Text('Salvar'), onPressed: () => _createTask()),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _newTaskDialog(),
                );
              },
            )
          : null,
      body: _taskList(),
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  const EditTaskDialog({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _editTaskFormKey = GlobalKey<FormState>();
  final TextEditingController _taskName = TextEditingController();

  bool isCompleted = false;

  _saveTask(Task task) async {
    if (_editTaskFormKey.currentState!.validate()) {
      Task newData = task;

      newData.name = _taskName.text;
      newData.realized = isCompleted ? 1 : 0;

      final response = await API.updateTask(newData);
      if (response.statusCode == 200) {
        _taskName.clear();
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void initState() {
    isCompleted = widget.task.realized == 0 ? false : true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    setState(() {
      _taskName.text = task.name;
    });

    return AlertDialog(
      title: const Text('Editar Tarefa'),
      content: Form(
        key: _editTaskFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _taskName,
              decoration: const InputDecoration(
                label: Text('Título'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Preencha o título da tarefa';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tarefa concluída'),
                Switch(
                  value: isCompleted,
                  onChanged: _changeSwitch,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Excluir',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            final response = await API.deleteTask(task.id);

            var body = json.decode(response.body);

            if (response.statusCode == 200 &&
                body['message'] == 'Task deleted Successfully') {
              Navigator.pop(context, true);
            }
          },
        ),
        TextButton(
            child: const Text('Salvar'), onPressed: () => _saveTask(task)),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }

  void _changeSwitch(bool value) {
    setState(() {
      isCompleted = value;
    });
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          TextButton(
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              print('test');
            },
          )
        ],
      ),
      body: Container(),
    );
  }
}
