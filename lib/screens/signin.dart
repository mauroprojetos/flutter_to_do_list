import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/signup.dart';
import 'package:to_do_list/screens/task_list.dart';
import 'package:to_do_list/util/services/api.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _loginFormKey = GlobalKey<FormState>();
  late TextEditingController _usernameEditingController;
  late TextEditingController _passwordEditingController;
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();

    _usernameEditingController = TextEditingController();
    _passwordEditingController = TextEditingController();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _usernameEditingController.dispose();
    _passwordEditingController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  _login() async {
    if (_loginFormKey.currentState!.validate()) {
      await API
          .login(
              _usernameEditingController.text, _passwordEditingController.text)
          .then((response) async {
        var body = jsonDecode(await response.transform(utf8.decoder).join());
        if (response.statusCode == 200) {
          if (body['message'] == null) {
            currentUser = User.fromJson(body);
            currentUser.username = _usernameEditingController.text;
            currentUser.password = _passwordEditingController.text;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskList(),
              ),
            );
          } else {
            final snackBar = SnackBar(
              content: Text(body['message']),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          const snackBar = SnackBar(
            content: Text('Serviço indisponível'),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
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
                      controller: _usernameEditingController,
                      textInputAction: TextInputAction.next,
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
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: _passwordEditingController,
                      focusNode: _passwordFocusNode,
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
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    ElevatedButton(
                      child: const Text('Entrar'),
                      onPressed: () => _login(),
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
