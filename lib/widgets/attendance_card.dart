import 'package:flutter/material.dart';
import 'package:ui_flutter_lab_external/models/subjects.dart';
import 'package:ui_flutter_lab_external/utils/attendance_math.dart';

class AttendanceCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const AttendanceCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = AttendanceMath.currentPercentage(
      subject.attendedClasses,
      subject.totalClasses,
    );

    // Determine color based on target
    final isBelowTarget = percentage < subject.targetPercentage;
    final color = isBelowTarget ? Colors.red : Colors.green;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attended: ${subject.attendedClasses} / ${subject.totalClasses}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Target: ${subject.targetPercentage}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Animated Progress Bar (Experiment 8)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}