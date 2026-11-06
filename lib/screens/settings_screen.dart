import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/attendance_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Appearance Section ---
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),

              const SizedBox(height: 32),

              // --- Data Management Section ---
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Total Subjects Saved'),
                      trailing: Text(
                        '${attendanceProvider.subjects.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Data Persistence'),
                      subtitle: const Text('Data is saved locally on this device'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- About Section ---
              Text(
                'About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.apps),
                      title: Text('AttendEase'),
                      subtitle: Text('Attendance Calculator App'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.code),
                      title: Text('Version'),
                      trailing: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('Developed For'),
                      subtitle: const Text('UI Design - Flutter (CS506PC) External Lab'),
                      onTap: () {
                        // Just a fun easter egg
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Good luck with your viva!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}