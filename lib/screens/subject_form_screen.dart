import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:ui_flutter_lab_external/models/subjects.dart';
import '../providers/attendance_provider.dart';
import '../utils/validators.dart';

class SubjectFormScreen extends StatefulWidget {
  // If this is null, we are adding. If it has a value, we are editing.
  final Subject? existingSubject;

  const SubjectFormScreen({super.key, this.existingSubject});

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _attendedController;
  late TextEditingController _totalController;
  late TextEditingController _targetController;

  bool get isEditing => widget.existingSubject != null;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if editing
    final subject = widget.existingSubject;
    _nameController = TextEditingController(text: subject?.name ?? '');
    _attendedController = TextEditingController(text: subject?.attendedClasses.toString() ?? '0');
    _totalController = TextEditingController(text: subject?.totalClasses.toString() ?? '0');
    _targetController = TextEditingController(text: subject?.targetPercentage.toString() ?? '75');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _attendedController.dispose();
    _totalController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveSubject() {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    final name = _nameController.text.trim();
    final attended = int.parse(_attendedController.text);
    final total = int.parse(_totalController.text);
    final target = int.parse(_targetController.text);

    // Read provider without listening (we don't need to rebuild this screen)
    final provider = context.read<AttendanceProvider>();

    if (isEditing) {
      // Update existing
      final updatedSubject = widget.existingSubject!.copyWith(
        name: name,
        attendedClasses: attended,
        totalClasses: total,
        targetPercentage: target,
      );
      provider.updateSubject(updatedSubject);
    } else {
      // Add new
      final newSubject = Subject(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
        name: name,
        attendedClasses: attended,
        totalClasses: total,
        targetPercentage: target,
      );
      provider.addSubject(newSubject);
    }

    // Close the screen and go back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add New Subject'),
      ),
      // Make it responsive and scrollable for small screens / keyboards
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g., Operating Systems',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => AppValidators.validateName(value),
                    ),
                    const SizedBox(height: 16),

                    // Attended Field
                    TextFormField(
                      controller: _attendedController,
                      decoration: const InputDecoration(
                        labelText: 'Classes Attended',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.check_circle_outline),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => AppValidators.validateNumber(value, 'Attended classes'),
                    ),
                    const SizedBox(height: 16),

                    // Total Field
                    TextFormField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Total Classes Conducted',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        // Pass the currently typed attended value for cross-validation
                        final attended = int.tryParse(_attendedController.text) ?? 0;
                        return AppValidators.validateTotalClasses(value, attended);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Target Field
                    TextFormField(
                      controller: _targetController,
                      decoration: const InputDecoration(
                        labelText: 'Target Percentage (%)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => AppValidators.validateTarget(value),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    FilledButton.icon(
                      onPressed: _saveSubject,
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Save Changes' : 'Add Subject'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}