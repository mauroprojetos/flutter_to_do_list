import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/util/services/users.service.dart';

class UpdateAuthDialog extends StatefulWidget {
  const UpdateAuthDialog({Key? key}) : super(key: key);

  @override
  _UpdateAuthDialogState createState() => _UpdateAuthDialogState();
}

class _UpdateAuthDialogState extends State<UpdateAuthDialog> {
  final _updatePasswordFormKey = GlobalKey<FormState>();

  late TextEditingController _newUsernameController;
  late TextEditingController _newPasswordController;
  late TextEditingController _repeatNewPasswordController;

  List<String> _newUserData = [];

  @override
  void initState() {
    _newUsernameController = TextEditingController();
    _newPasswordController = TextEditingController();
    _repeatNewPasswordController = TextEditingController();

    _newUsernameController.text = currentUser.username.toString();

    super.initState();
  }

  _updatePassword() async {
    if (_updatePasswordFormKey.currentState!.validate()) {
      _newUserData = [_newUsernameController.text, _newPasswordController.text];

      HttpClientResponse response =
          await UserService.updateuserpass(currentUser, _newUserData);

      if (response.statusCode == 200) {
        var responseBody =
            jsonDecode(await response.transform(utf8.decoder).join());

        final String message = responseBody['message'];

        final snackBar = SnackBar(
          content: Text(message),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        if (message == 'Username/password Successfully Updated') {
          Navigator.pop(context, _newUserData);
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
    return AlertDialog(
      title: const Text('Alterar Usuário / Senha'),
      content: SingleChildScrollView(
        child: Form(
          key: _updatePasswordFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newUsernameController,
                decoration: const InputDecoration(
                  label: Text('Usuário'),
                  border: OutlineInputBorder(),
                ),
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
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  label: Text('Nova Senha'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preencha o campo "Nova Senha"';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _repeatNewPasswordController,
                decoration: const InputDecoration(
                  label: Text('Repetir Nova Senha'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Preencha o campo "Senha Atual"';
                  }
                  if (value != _newPasswordController.text.toString()) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
              (states) => Colors.red.shade100,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        TextButton(
          child: const Text('Alterar'),
          onPressed: () {
            _updatePassword();
          },
        ),
      ],
    );
  }
}
