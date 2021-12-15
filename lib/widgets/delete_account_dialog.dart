import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/util/services/users.service.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _deleteAccountForm = GlobalKey<FormState>();
  late TextEditingController _currentPassword;

  @override
  void initState() {
    _currentPassword = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _currentPassword.dispose();
    super.dispose();
  }

  _deleteAccount() async {
    if (_deleteAccountForm.currentState!.validate()) {
      User user = currentUser;
      user.password = _currentPassword.text;

      HttpClientResponse response = await UserService.delete(user);

      if (response.statusCode == 200) {
        var responseBody =
            jsonDecode(await response.transform(utf8.decoder).join());

        final String message = responseBody['message'];

        final snackBar = SnackBar(
          content: Text(message),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        if (message == 'User Successfully Deleted') {
          Navigator.pop(context, true);
        }
      } else {
        const snackBar = SnackBar(
          content: Text('Serviço indisponível'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Deseja continuar?'),
      content: Form(
        key: _deleteAccountForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ao preencher o campo senha e pressionar "Continuar", sua conta e suas tarefas serão excluídos.',
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _currentPassword,
              decoration: const InputDecoration(
                label: Text('Senha'),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Preencha o campo "Senha"';
                }
                return null;
              },
            ),
          ],
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
          child: const Text('Continuar'),
          onPressed: () => _deleteAccount(),
        ),
      ],
    );
  }
}
