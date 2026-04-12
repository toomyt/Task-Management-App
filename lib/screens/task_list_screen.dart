import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  final CollectionReference _tasksRef =
      FirebaseFirestore.instance.collection('tasks');


  Future<void> _addTask() async {
    final name = _taskController.text.trim();
    if (name.isEmpty) return;

    await _tasksRef.add({
      'name': name,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(), 
      'subtasks': [],                             
    });

    _taskController.clear(); 
  }

  Future<void> _toggleTask(String docId, bool current) async {
    await _tasksRef.doc(docId).update({'isDone': !current});
  }

  Future<void> _deleteTask(String docId) async {
    await _tasksRef.doc(docId).delete();
  }

  Future<void> _addSubtask(String docId, List subtasks, String title) async {
    final updated = [...subtasks, {'title': title, 'isDone': false}];
    await _tasksRef.doc(docId).update({'subtasks': updated});
  }

  Future<void> _toggleSubtask(String docId, List subtasks, int index) async {
    final updated = List<Map<String, dynamic>>.from(
      subtasks.map((s) => Map<String, dynamic>.from(s)),
    );
    updated[index]['isDone'] = !updated[index]['isDone'];
    await _tasksRef.doc(docId).update({'subtasks': updated});
  }

  Future<void> _deleteSubtask(String docId, List subtasks, int index) async {
    final updated = List.from(subtasks)..removeAt(index);
    await _tasksRef.doc(docId).update({'subtasks': updated});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'New task...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tasksRef
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one!'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return TaskTile(
                      docId: doc.id,
                      name: data['name'] ?? '',
                      isDone: data['isDone'] ?? false,
                      subtasks: List.from(data['subtasks'] ?? []),
                      onToggle: () => _toggleTask(doc.id, data['isDone']),
                      onDelete: () => _deleteTask(doc.id),
                      onAddSubtask: (title) =>
                          _addSubtask(doc.id, data['subtasks'] ?? [], title),
                      onToggleSubtask: (i) =>
                          _toggleSubtask(doc.id, data['subtasks'] ?? [], i),
                      onDeleteSubtask: (i) =>
                          _deleteSubtask(doc.id, data['subtasks'] ?? [], i),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}