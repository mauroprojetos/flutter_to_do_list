import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/signin.dart';
import 'package:to_do_list/util/services/user.service.dart';

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

      await UserService.create(newUser).then((response) async {
        if (response.statusCode == 200) {
          var body = jsonDecode(await response.transform(utf8.decoder).join());

          if (body['message'] == 'User Successfully Added') {
            currentUser = User.fromJson(body);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignIn(),
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
