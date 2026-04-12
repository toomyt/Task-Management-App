import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final String docId;
  final String name;
  final bool isDone;
  final List subtasks;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onAddSubtask;
  final Function(int) onToggleSubtask;
  final Function(int) onDeleteSubtask;

  const TaskTile({
    super.key,
    required this.docId,
    required this.name,
    required this.isDone,
    required this.subtasks,
    required this.onToggle,
    required this.onDelete,
    required this.onAddSubtask,
    required this.onToggleSubtask,
    required this.onDeleteSubtask,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: widget.isDone,
              onChanged: (_) => widget.onToggle(),
            ),
            title: Text(
              widget.name,
              style: TextStyle(
                decoration: widget.isDone ? TextDecoration.lineThrough : null,
                color: widget.isDone ? Colors.grey : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: 'Subtasks (${widget.subtasks.length})',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                children: [
                  ...widget.subtasks.asMap().entries.map((entry) {
                    final i = entry.key;
                    final sub = entry.value as Map<String, dynamic>;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Checkbox(
                        value: sub['isDone'] ?? false,
                        onChanged: (_) => widget.onToggleSubtask(i),
                      ),
                      title: Text(
                        sub['title'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: (sub['isDone'] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => widget.onDeleteSubtask(i),
                      ),
                    );
                  }),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskController,
                          decoration: const InputDecoration(
                            hintText: 'Add subtask...',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              widget.onAddSubtask(val.trim());
                              _subtaskController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          final val = _subtaskController.text.trim();
                          if (val.isNotEmpty) {
                            widget.onAddSubtask(val);
                            _subtaskController.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}