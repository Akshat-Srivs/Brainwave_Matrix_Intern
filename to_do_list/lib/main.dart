import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> _todoItems = [];

  // Load tasks when the app starts
  @override
  void initState() {
    super.initState();
    _loadTasksFromMemory();
  }

  Future<void> _saveTasksToMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = _todoItems.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('todo_list', taskList);
  }

  Future<void> _loadTasksFromMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('todo_list');

    if (taskList != null) {
      setState(() {
        _todoItems = taskList.map((task) => Task.fromJson(jsonDecode(task))).toList();
      });
    }
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add(Task(title: task));
      });
      _saveTasksToMemory();
      _showSnackBar('Task added!');
    }
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTasksToMemory();
    _showSnackBar('Task completed and removed!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _displayAddTodoDialog() {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new task'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(
              hintText: 'Enter the Task here',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addTodoItem(_textFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoList() {
    if (_todoItems.isEmpty) {
      return Center(
        child: Text(
          'No tasks available, add some!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoItems[index], index);
      },
    );
  }

  Widget _buildTodoItem(Task task, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: CheckboxListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        value: task.isCompleted,
        activeColor: Colors.teal,
        onChanged: (bool? value) {
          setState(() {
            task.isCompleted = value ?? false;
            if (task.isCompleted) {
              _removeTodoItem(index);
            }
          });
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple To-Do App'),
        centerTitle: true,
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayAddTodoDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
        backgroundColor: Colors.teal,
      ),
    );
  }
}
