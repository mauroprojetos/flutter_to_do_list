import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/util/services/tasks.service.dart';
import 'package:to_do_list/widgets/custom_drawer.dart';
import 'package:to_do_list/widgets/edit_task_dialog.dart';
import 'package:to_do_list/widgets/new_task_dialog.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool isLoading = true;
  List taskList = [];

  @override
  void initState() {
    super.initState();
    _getTaskList();
  }

  _getTaskList() {
    isLoading = true;

    TasksService.getTasks().then((response) async {
      if (response.statusCode == 200) {
        var body = jsonDecode(await response.transform(utf8.decoder).join());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return const NewTaskDialog();
                  },
                );

                if (result != null && result) {
                  _getTaskList();
                }
              },
            )
          : null,
      body: _taskList(),
    );
  }
}
