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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<QueryDocumentSnapshot> _docs = [];

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _onSnapshotReceived(List<QueryDocumentSnapshot> newDocs) {
    for (int i = _docs.length - 1; i >= 0; i--) {
      final wasRemoved = !newDocs.any((d) => d.id == _docs[i].id);
      if (wasRemoved) {
        final removed = _docs[i];
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildAnimatedTile(removed, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    for (int i = 0; i < newDocs.length; i++) {
      final isNew = !_docs.any((d) => d.id == newDocs[i].id);
      if (isNew) {
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    setState(() => _docs = newDocs);
  }

  Widget _buildAnimatedTile(
    QueryDocumentSnapshot doc,
    Animation<double> animation,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: TaskTile(
          docId: doc.id,
          name: (data['name'] as String?) ?? '',
          isDone: (data['isDone'] as bool?) ?? false,
          subtasks: List.from(data['subtasks'] ?? []),
          onToggle: () =>
              _toggleTask(doc.id, (data['isDone'] as bool?) ?? false),
          onDelete: () => _deleteTask(doc.id),
          onAddSubtask: (title) =>
              _addSubtask(doc.id, data['subtasks'] ?? [], title),
          onToggleSubtask: (i) =>
              _toggleSubtask(doc.id, data['subtasks'] ?? [], i),
          onDeleteSubtask: (i) =>
              _deleteSubtask(doc.id, data['subtasks'] ?? [], i),
        ),
      ),
    );
  }

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
    updated[index]['isDone'] = !(updated[index]['isDone'] as bool? ?? false);
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
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _docs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onSnapshotReceived(snapshot.data!.docs);
                  });
                }

                if (_docs.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one!'));
                }

                return AnimatedList(
                  key: _listKey,
                  initialItemCount: _docs.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _docs.length) return const SizedBox.shrink();
                    return _buildAnimatedTile(_docs[index], animation);
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