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
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  _login() async {
    if (_loginFormKey.currentState!.validate()) {
      final response = await API.login(_username.text, _password.text);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['message'] == null) {
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
      } else {
        const snackBar = SnackBar(
          content: Text('Serviço indisponível'),
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
