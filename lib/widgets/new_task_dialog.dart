import 'dart:io';

import 'package:flutter/material.dart';
import 'package:to_do_list/util/services/tasks.service.dart';

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({Key? key}) : super(key: key);

  @override
  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _newTaskFormKey = GlobalKey<FormState>();
  late TextEditingController _newTaskName;
  late FocusNode _newTaskNameFocusNode;

  _createTask() async {
    if (_newTaskFormKey.currentState!.validate()) {
      HttpClientResponse response =
          await TasksService.newTask(_newTaskName.text);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _newTaskName = TextEditingController();
    _newTaskNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _newTaskName.dispose();
    _newTaskNameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Tarefa'),
      actionsAlignment: MainAxisAlignment.spaceAround,
      content: Form(
        key: _newTaskFormKey,
        child: TextFormField(
          controller: _newTaskName,
          focusNode: _newTaskNameFocusNode,
          autofocus: true,
          decoration: const InputDecoration(
            label: Text('Título'),
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (_) => _createTask(),
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
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('Salvar'),
          onPressed: () => _createTask(),
        ),
      ],
    );
  }
}
