import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ui_flutter_lab_external/models/subjects.dart';
import '../providers/attendance_provider.dart';
import '../utils/attendance_math.dart';
import 'subject_form_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  // Helper method to get the latest subject data
  Subject? _getSubject(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    try {
      return provider.subjects.firstWhere((s) => s.id == widget.subjectId);
    } catch (e) {
      return null; // Subject might have been deleted
    }
  }

  void _markAttendance(bool isPresent) {
    context.read<AttendanceProvider>().markAttendance(
      widget.subjectId,
      isPresent: isPresent,
    );

    // Show Undo SnackBar (Experiment 5 & 8: State and UI feedback)
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Clear previous
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as ${isPresent ? 'Present' : 'Absent'}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            context.read<AttendanceProvider>().undoAttendance(
              widget.subjectId,
              wasPresent: isPresent,
            );
          },
        ),
      ),
    );
  }

  void _deleteSubject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: const Text('This will permanently delete all attendance data for this subject.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AttendanceProvider>().deleteSubject(widget.subjectId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to subjects list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = _getSubject(context);

    // If subject is null, it means it was deleted while this screen was open
    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Not Found')),
        body: const Center(child: Text('This subject no longer exists.')),
      );
    }

    final percentage = AttendanceMath.currentPercentage(
      subject.attendedClasses,
      subject.totalClasses,
    );
    final isBelowTarget = percentage < subject.targetPercentage;
    final themeColor = isBelowTarget ? Colors.red : Colors.green;

    // Calculate Math Insights
    final needed = AttendanceMath.classesNeededToReach(
      subject.attendedClasses,
      subject.totalClasses,
      subject.targetPercentage,
    );
    final skips = AttendanceMath.safeSkips(
      subject.attendedClasses,
      subject.totalClasses,
      subject.targetPercentage,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectFormScreen(existingSubject: subject),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSubject,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. Big Animated Percentage Display (Exp 8) ---
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percentage),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Text(
                            '${value.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: value / 100,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                            color: themeColor,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- 2. Current Stats ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, 'Attended', '${subject.attendedClasses}'),
                      _buildStatItem(context, 'Total', '${subject.totalClasses}'),
                      _buildStatItem(context, 'Target', '${subject.targetPercentage}%'),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- 3. Math Insights (The "Calculator" part) ---
                  Text(
                    'Insights',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInsightRow(
                            context,
                            icon: Icons.arrow_upward,
                            title: 'Classes needed to reach target:',
                            value: needed == null
                                ? 'Impossible (Target is 100%)'
                                : needed == 0
                                ? 'Target Met!'
                                : '$needed classes',
                            valueColor: needed == null ? Colors.red : Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildInsightRow(
                            context,
                            icon: Icons.beach_access,
                            title: 'Safe skips remaining:',
                            value: skips == null
                                ? 'Infinite'
                                : skips == 0
                                ? 'None'
                                : '$skips classes',
                            valueColor: skips == 0 ? Colors.orange : Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 4. Mark Attendance Buttons ---
                  Text(
                    'Mark Today\'s Attendance',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _markAttendance(true),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Present'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _markAttendance(false),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.red,
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Absent'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the stats row
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // Helper widget for the insights card
  Widget _buildInsightRow(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}