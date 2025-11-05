import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../providers/assessment_provider.dart';
import '../widgets/timer_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentProvider(),
      child: const AssessmentScreenContent(),
    );
  }
}

class AssessmentScreenContent extends StatefulWidget {
  const AssessmentScreenContent({Key? key}) : super(key: key);

  @override
  State<AssessmentScreenContent> createState() =>
      _AssessmentScreenContentState();
}

class _AssessmentScreenContentState extends State<AssessmentScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _teamMemberController = TextEditingController();
  final _epfController = TextEditingController();
  final _goodGarmentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _teamMemberController.dispose();
    _epfController.dispose();
    _goodGarmentsController.dispose();
    super.dispose();
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<AssessmentProvider>();

    // Validate at least one timer has run
    if (provider.getRunTimersCount() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please run at least one timer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate number of good garments is entered
    if (_goodGarmentsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter number of good garments'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final numberOfGoodGarments =
        int.tryParse(_goodGarmentsController.text) ?? 0;

    try {
      await provider.saveAssessment(
        teamMember: _teamMemberController.text,
        epf: _epfController.text,
        numberOfGoodGarments: numberOfGoodGarments,
      );

      if (mounted) {
        // Navigate to results screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(assessment: provider.lastSavedAssessment!),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'New Assessment'),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Style Selection
                  _buildSectionTitle('Style Selection'),
                  DropdownSearch<String>(
                    items: (filter, infiniteScrollProps) =>
                        provider.styles.map((style) => style.id).toList(),
                    itemAsString: (String? id) {
                      if (id == null) return '';
                      final style = provider.styles.firstWhere(
                        (s) => s.id == id,
                        orElse: () => provider.styles.first,
                      );
                      return style.name;
                    },
                    selectedItem: provider.selectedStyleId,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search styles...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Select Style',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedStyle(value);
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select a style' : null,
                  ),
                  const SizedBox(height: 16),

                  // Operation Selection
                  DropdownSearch<String>(
                    items: (filter, infiniteScrollProps) => provider.operations
                        .map((operation) => operation.id)
                        .toList(),
                    itemAsString: (String? id) {
                      if (id == null) return '';
                      final operation = provider.operations.firstWhere(
                        (o) => o.id == id,
                        orElse: () => provider.operations.first,
                      );
                      return '${operation.name} (SMV: ${operation.smv.toStringAsFixed(2)})';
                    },
                    selectedItem: provider.selectedOperationId,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search operations...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Select Operation',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setSelectedOperation(value);
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Please select an operation' : null,
                  ),
                  const SizedBox(height: 24),

                  // Shift, Module, IE Selection
                  _buildSectionTitle('Work Details'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<String>(
                          items: (filter, infiniteScrollProps) => ['A', 'B'],
                          itemAsString: (String? shift) =>
                              shift != null ? 'Shift $shift' : '',
                          selectedItem: provider.selectedShift,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: const TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search shift...',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          decoratorProps: const DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Shift',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              provider.setSelectedShift(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownSearch<int>(
                          items: (filter, infiniteScrollProps) =>
                              List.generate(26, (index) => index + 1),
                          itemAsString: (int? module) =>
                              module != null ? 'Module $module' : '',
                          selectedItem: provider.selectedModule,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: const TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search module...',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          decoratorProps: const DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Module',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              provider.setSelectedModule(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Team Member & EPF
                  TextFormField(
                    controller: _teamMemberController,
                    decoration: const InputDecoration(
                      labelText: 'Team Member Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter team member name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _epfController,
                    decoration: const InputDecoration(
                      labelText: 'EPF Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter EPF number'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Date Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Date: ${provider.getFormattedDate()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timers Section
                  _buildSectionTitle('Timers (Start, Pause, Stop, Reset)'),
                  const Text(
                    'Only run timers will be included in average calculation',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    10,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TimerWidget(timerIndex: index),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Number of Good Garments
                  _buildSectionTitle('Quality Control'),
                  TextFormField(
                    controller: _goodGarmentsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Good Garments',
                      border: OutlineInputBorder(),
                      helperText: 'Enter the count of defect-free garments',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of good garments';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: provider.isSaving ? null : _submitAssessment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Calculate & Save Assessment',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
