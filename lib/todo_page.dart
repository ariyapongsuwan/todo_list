import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> _tasks = [];

  void _addTask(String task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _editTask(int index, String newTask) {
    setState(() {
      _tasks[index] = newTask;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showEditDialog(int index) {
    final controller = TextEditingController(text: _tasks[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("แก้ไขโน้ต"),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editTask(index, controller.text);
            },
            child: const Text("บันทึก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(onSubmit: _addTask),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.black,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('ไม่มีงานในรายการ'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => Dismissible(
                key: Key(_tasks[index]),
                onDismissed: (_) => _deleteTask(index),
                background: Container(color: Colors.red),
                child: ListTile(
                  title: Text(_tasks[index]),
                  onTap: () => _showEditDialog(index),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มโน้ตใหม่',
      ),
    );
  }
}

class AddNotePage extends StatefulWidget {
  final Function(String) onSubmit;

  const AddNotePage({super.key, required this.onSubmit});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSubmit(_controller.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มโน้ตใหม่'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'พิมพ์โน้ตของคุณ'),
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
