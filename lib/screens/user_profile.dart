import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/task_list.dart';
import 'package:to_do_list/util/services/api.dart';

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
