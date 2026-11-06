import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ui_flutter_lab_external/providers/attendance_provider.dart';
import 'package:ui_flutter_lab_external/providers/theme_provider.dart';
import 'package:ui_flutter_lab_external/screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AttendEaseApp(),
    ),
  );
}

class AttendEaseApp extends StatelessWidget {
  const AttendEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This listens to the ThemeProvider to toggle light/dark mode
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AttendEase',
      debugShowCheckedModeBanner: false,

      // Theme Setup (Experiment 6: Themes)
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),

      // Navigation Setup (Experiment 4: Named Routes)
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        // We will add other routes here as we build the screens
      },
    );
  }
}