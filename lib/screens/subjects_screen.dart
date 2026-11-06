import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../widgets/attendance_card.dart';
import '../widgets/empty_state.dart';
import 'subject_form_screen.dart';
import 'subject_detail_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for real-time updates
    final attendanceProvider = context.watch<AttendanceProvider>();

    // Show loading spinner if data is still being fetched from SharedPreferences
    if (attendanceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Top Action Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${attendanceProvider.subjects.length} Subjects',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the Form Screen to add a new subject
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubjectFormScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Subject'),
              ),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: attendanceProvider.subjects.isEmpty
              ? const EmptyState(
            icon: Icons.book_outlined,
            title: 'No Subjects Yet',
            message: 'Click "Add Subject" to start tracking your attendance.',
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: attendanceProvider.subjects.length,
            itemBuilder: (context, index) {
              final subject = attendanceProvider.subjects[index];

              return AttendanceCard(
                subject: subject,
                onTap: () {
                  // Navigate to the Detail Screen to mark attendance
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectDetailScreen(subjectId: subject.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}