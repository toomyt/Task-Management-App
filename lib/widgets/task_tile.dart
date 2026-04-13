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
    return Dismissible(
      key: Key(widget.docId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task?'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      // ── Fix 1: child belongs inside Dismissible, closing ) was missing ──
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            ListTile(
              onTap: widget.onToggle,
              leading: IgnorePointer(
                child: Checkbox(
                  value: widget.isDone,
                  onChanged: (_) {},
                ),
              ),
              title: Text(
                widget.name,
                style: TextStyle(
                  decoration:
                      widget.isDone ? TextDecoration.lineThrough : null,
                  color: widget.isDone ? Colors.grey : null,
                ),
              ),
              // ── Fix 2: removed delete IconButton, swipe handles deletion now
              trailing: IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
                tooltip: 'Subtasks (${widget.subtasks.length})',
                onPressed: () => setState(() => _expanded = !_expanded),
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
                      final subTitle = (sub['title'] as String?) ?? '';
                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: Checkbox(
                          value: (sub['isDone'] as bool?) ?? false,
                          onChanged: (_) => widget.onToggleSubtask(i),
                        ),
                        title: Text(
                          subTitle.isEmpty ? '(no title)' : subTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                            decoration: (sub['isDone'] as bool? ?? false)
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
      ),
    );
  }
}