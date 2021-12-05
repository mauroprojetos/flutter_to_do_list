import 'package:flutter/material.dart';
import 'package:to_do_list/util/services/api.dart';

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({Key? key}) : super(key: key);

  @override
  _NewTaskDialogState createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _newTaskFormKey = GlobalKey<FormState>();
  final TextEditingController _newTaskName = TextEditingController();

  bool isCompleted = false;

  _createTask() async {
    if (_newTaskFormKey.currentState!.validate()) {
      final response = await API.newTask(_newTaskName.text);

      if (response.statusCode == 200) {
        _newTaskName.clear();
        Navigator.pop(context, true);
        // _getTaskList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.pop(context, false);
          },
        ),
        TextButton(child: const Text('Salvar'), onPressed: () => _createTask()),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
