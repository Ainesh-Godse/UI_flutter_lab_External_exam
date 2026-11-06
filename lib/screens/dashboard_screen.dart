import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ui_flutter_lab_external/providers/attendance_provider.dart';
import 'package:ui_flutter_lab_external/services/quote_service.dart';
import 'package:ui_flutter_lab_external/widgets/responsive_scaffold.dart';
import 'subjects_screen.dart';
import 'calculator_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final QuoteService _quoteService = QuoteService();
  late Future<Map<String, String>> _quoteFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the quote as soon as the screen loads (Exp 9)
    _quoteFuture = _quoteService.fetchRandomQuote();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // List of titles for the AppBar based on the selected tab
  final List<String> _titles = [
    'Dashboard',
    'Your Subjects',
    'Attendance Calculator',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    // This is the responsive shell we created earlier (Exp 3 & 6)
    return ResponsiveScaffold(
      title: _titles[_currentIndex],
      selectedIndex: _currentIndex,
      onDestinationSelected: _onDestinationSelected,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(context),
          const SubjectsScreen(),
          const CalculatorScreen(),
          const SettingsScreen(),
        ],
      ),
    );
  }

  // --- TAB 0: Dashboard Content ---
  Widget _buildDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. API Quote Card (Experiment 9)
          _buildApiQuoteCard(),

          const SizedBox(height: 24),

          // 2. Overall Stats Card
          _buildOverallStats(context),

          const SizedBox(height: 24),

          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // 3. Quick Actions (Navigate to other tabs)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _onDestinationSelected(1), // Go to Subjects
                icon: const Icon(Icons.list),
                label: const Text('Manage Subjects'),
              ),
              ElevatedButton.icon(
                onPressed: () => _onDestinationSelected(2), // Go to Calculator
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Attendance'),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGETS FOR THE DASHBOARD ---

  Widget _buildApiQuoteCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, String>>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 16),
                  Text('Loading daily motivation...'),
                ],
              );
            }

            // Error State
            if (snapshot.hasError) {
              return Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Could not load quote. Check your connection.')),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _quoteFuture = _quoteService.fetchRandomQuote();
                      });
                    },
                  )
                ],
              );
            }

            // Success State
            final data = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${data['text']}"',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '- ${data['author']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context) {
    // Watch the provider to get the latest data
    final attendanceProvider = context.watch<AttendanceProvider>();
    final subjects = attendanceProvider.subjects;

    // Calculate overall stats
    int totalAttended = 0;
    int totalClasses = 0;

    for (var sub in subjects) {
      totalAttended += sub.attendedClasses;
      totalClasses += sub.totalClasses;
    }

    double overallPercentage = 0;
    if (totalClasses > 0) {
      overallPercentage = (totalAttended / totalClasses) * 100;
    }

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total Subjects', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${subjects.length}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Overall Attendance', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${overallPercentage.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}