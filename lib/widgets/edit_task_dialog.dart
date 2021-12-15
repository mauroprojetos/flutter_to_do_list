import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/util/services/tasks.service.dart';

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
      final response = await TasksService.updateTask(newData);
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
            await TasksService.deleteTask(task.id).then((response) async {
              var body =
                  jsonDecode(await response.transform(utf8.decoder).join());

              if (response.statusCode == 200 &&
                  body['message'] == 'Task deleted Successfully') {
                Navigator.pop(context, true);
              }
            });
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
