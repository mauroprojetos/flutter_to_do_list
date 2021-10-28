import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// AVD TO LOCALHOST
const String baseUrl = 'http://10.0.2.2:8080/php-api-to-do-list';

class User {
  User({
    this.name,
    this.email,
    this.password,
    this.id,
    this.username,
    this.token,
  });

  int? id;
  String? name;
  String? email;
  String? username;
  String? password;
  String? token;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        username: json["username"],
        password: json["password"],
        token: json["token"],
      );
}

class Task {
  final int id;
  final int userId;
  final String name;
  final DateTime date;
  final int realized;

  Task({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.realized,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"] as int,
        userId: json["userId"] as int,
        name: json["name"] as String,
        date: DateTime.parse(json["date"]),
        realized: json["realized"] as int,
      );
}

User currentUser = User();

class API {
  // --- USER ---

  // LOGIN
  static Future login(String username, String password) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
    };

    return await http.post(
      Uri.parse('$baseUrl/api/user/login/'),
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
      Uri.parse('$baseUrl/api/user/new/'),
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
      Uri.parse('$baseUrl/api/user/update/'),
      headers: requestHeaders,
      body: jsonEncode({
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "password": user.password
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
      Uri.parse('$baseUrl/api/task/search/'),
      headers: requestHeaders,
    );
  }

  // NEW
  static Future newTask(String taskname) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Authorization': currentUser.token!
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
      'Authorization': currentUser.token!
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
      'Authorization': currentUser.token!
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
      home: currentUser.token == null ? const SignIn() : const TaskList(),
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
        final body = jsonDecode(response.body);

        try {
          final parsed = body.cast<Map<String, dynamic>>();
          setState(() {
            taskList = parsed.map<Task>((json) => Task.fromJson(json)).toList();
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            taskList = [];
            isLoading = false;
          });
        }
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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(currentUser.name!),
              accountEmail: Text(currentUser.email!),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUser.name![0].toUpperCase(),
                  style: const TextStyle(fontSize: 32.0),
                ),
                radius: 50.0,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListTile(
                    title: const Text('Meu Perfil'),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfile(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Sair'),
                    leading: const Icon(Icons.logout),
                    onTap: () {
                      currentUser = User();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignIn(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
      Task newData = Task(
        id: task.id,
        userId: task.userId,
        name: _taskName.text,
        date: task.date,
        realized: isCompleted ? 1 : 0,
      );
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

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  _login() async {
    if (_loginFormKey.currentState!.validate()) {
      final response = await API.login(_username.text, _password.text);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 && parsed['message'] == null) {
        currentUser = User.fromJson(parsed);
        currentUser.username = _username.text;
        currentUser.password = _password.text;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskList(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: Text(parsed['message']),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.check_circle_sharp,
                    size: (MediaQuery.of(context).size.width / 3),
                  ),
                  const Text(
                    'To-do',
                    style: TextStyle(fontSize: 32.0),
                  )
                ],
              ),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(
                        label: Text('Usuário'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha o campo "Usuário"';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(
                        label: Text('Senha'),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Preencha o campo "Senha"';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    ElevatedButton(
                      child: const Text('Entrar'),
                      onPressed: () {
                        _login();
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem uma conta?'),
                  TextButton(
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUp(),
                        ),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _signupFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  _signup() async {
    if (_signupFormKey.currentState!.validate()) {
      User newUser = User(
        name: _name.text,
        username: _username.text,
        email: _email.text,
        password: _password.text,
      );

      final response = await API.newUser(newUser);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          parsed['message'] == 'User Successfully Added') {
        currentUser = User.fromJson(parsed);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignIn(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: Text(parsed['message']),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _signupFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "Nome"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(
                    label: Text('Usuário'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "Usuário"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    label: Text('E-mail'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "E-mail"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                    label: Text('Senha'),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "Senha"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
                ElevatedButton(
                  child: const Text('Cadastrar'),
                  onPressed: () => _signup(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _userEditFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();

  _editUser() async {
    if (_userEditFormKey.currentState!.validate()) {
      User newUserData = User(
        name: _name.text,
        email: _email.text,
        username: currentUser.username,
        password: currentUser.password,
      );

      final response = await API.updateUser(newUserData);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          parsed['message'] == 'User Successfully Updated') {
        setState(() {
          currentUser.name = newUserData.name;
          currentUser.email = newUserData.email;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskList(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: Text(parsed['message']),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    _name.text = currentUser.name!;
    _email.text = currentUser.email!;
    super.initState();
  }

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
            onPressed: () => _editUser(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _userEditFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "Nome"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    label: Text('E-mail'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "E-mail"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
