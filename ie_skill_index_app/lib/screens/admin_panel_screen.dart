import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/api_service.dart';
import '../models/style_model.dart';
import '../models/operation_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Panel',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Admin Panel'),
                  content: const Text(
                    'Manage styles, operations, and other master data here. '
                    'Changes will be reflected immediately for all users.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Styles', icon: Icon(Icons.style)),
              Tab(text: 'Operations', icon: Icon(Icons.settings)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [StylesTab(), OperationsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// Styles Tab
class StylesTab extends StatefulWidget {
  const StylesTab({Key? key}) : super(key: key);

  @override
  State<StylesTab> createState() => _StylesTabState();
}

class _StylesTabState extends State<StylesTab> {
  final _firebaseService = FirebaseService();
  List<StyleModel> _styles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    setState(() => _isLoading = true);
    try {
      final styles = await _firebaseService.getStyles();
      setState(() {
        _styles = styles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditDialog({StyleModel? style}) async {
    final nameController = TextEditingController(text: style?.name ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(style == null ? 'Add Style' : 'Edit Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Style Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter style name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                if (style == null) {
                  await _firebaseService.addStyle(name);
                } else {
                  await _firebaseService.updateStyle(style.id, name);
                }
                Navigator.pop(context);
                _loadStyles();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        style == null
                            ? 'Style added successfully'
                            : 'Style updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(style == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStyle(StyleModel style) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Style'),
        content: Text('Are you sure you want to delete "${style.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.deleteStyle(style.id);
        _loadStyles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Style deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _styles.isEmpty
          ? const Center(
              child: Text('No styles found. Add one to get started.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                final style = _styles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    title: Text(
                      style.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(style: style),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStyle(style),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Operations Tab
class OperationsTab extends StatefulWidget {
  const OperationsTab({Key? key}) : super(key: key);

  @override
  State<OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends State<OperationsTab> {
  final _firebaseService = FirebaseService();
  List<OperationModel> _operations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOperations();
  }

  Future<void> _loadOperations() async {
    setState(() => _isLoading = true);
    try {
      final operations = await _firebaseService.getOperations();
      setState(() {
        _operations = operations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditDialog({OperationModel? operation}) async {
    final nameController = TextEditingController(text: operation?.name ?? '');
    final descController = TextEditingController(
      text: operation?.description ?? '',
    );
    final smvController = TextEditingController(
      text: operation != null ? operation.smv.toString() : '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(operation == null ? 'Add Operation' : 'Edit Operation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Operation Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: smvController,
                decoration: const InputDecoration(
                  labelText: 'SMV (Standard Minute Value)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 0.45',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descController.text.trim();
              final smv = double.tryParse(smvController.text.trim()) ?? 0.0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter operation name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (smv <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid SMV value'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                if (operation == null) {
                  await _firebaseService.addOperation(name, description, smv);
                } else {
                  await _firebaseService.updateOperation(
                    operation.id,
                    name,
                    description,
                    smv,
                  );
                }
                Navigator.pop(context);
                _loadOperations();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        operation == null
                            ? 'Operation added successfully'
                            : 'Operation updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(operation == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOperation(OperationModel operation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Operation'),
        content: Text('Are you sure you want to delete "${operation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.deleteOperation(operation.id);
        _loadOperations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operation deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _operations.isEmpty
          ? const Center(
              child: Text('No operations found. Add one to get started.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _operations.length,
              itemBuilder: (context, index) {
                final operation = _operations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    title: Text(
                      operation.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(operation.description),
                        const SizedBox(height: 4),
                        Text(
                          'SMV: ${operation.smv.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showAddEditDialog(operation: operation),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOperation(operation),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
