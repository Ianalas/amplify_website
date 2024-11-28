import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jvynboxollnhsfbacebb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2eW5ib3hvbGxuaHNmYmFjZWJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI4MTEyMzgsImV4cCI6MjA0ODM4NzIzOH0.2oQRgcHdnqsLTxKY-ASzG243WFCXNpG_qrmh3lp6je0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase ToDo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'To-Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final supabase = Supabase.instance.client;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final response = await supabase.from('todos').select();
    setState(() {
      _tasks = response as List<dynamic>;
    });
  }

  Future<void> _addTask() async {
    if (_controller.text.isNotEmpty) {
      await supabase.from('todos').insert({'title': _controller.text, 'is_complete': false});
      _controller.clear();
      _fetchTasks();
    }
  }

  Future<void> _removeTask(int id) async {
    await supabase.from('todos').delete().eq('id', id);
    _fetchTasks();
  }

  Future<void> _toggleTaskCompletion(int id, bool isComplete) async {
    await supabase.from('todos').update({'is_complete': !isComplete}).eq('id', id);
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(task['title']),
                    trailing: Checkbox(
                      value: task['is_complete'],
                      onChanged: (value) => _toggleTaskCompletion(task['id'], task['is_complete']),
                    ),
                    onLongPress: () => _removeTask(task['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
