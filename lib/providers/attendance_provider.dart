import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_flutter_lab_external/models/subjects.dart';

class AttendanceProvider extends ChangeNotifier {
  // The private list of subjects
  List<Subject> _subjects = [];
  bool _isLoading = true;

  // Getters
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  // Key for local storage
  static const String _storageKey = 'attend_ease_subjects';

  // Constructor: load data immediately when Provider is initialized
  AttendanceProvider() {
    loadSubjects();
  }

  // --- Persistence (Shared Preferences) ---

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        _subjects = decodedList.map((json) => Subject.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading subjects: $e');
      // In a real app, you might want to show an error state here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(
        _subjects.map((subject) => subject.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving subjects: $e');
    }
  }

  // --- CRUD Operations ---

  void addSubject(Subject subject) {
    _subjects.add(subject);
    _saveSubjects();
    notifyListeners(); // This tells the UI to rebuild
  }

  void updateSubject(Subject updatedSubject) {
    final index = _subjects.indexWhere((s) => s.id == updatedSubject.id);
    if (index != -1) {
      _subjects[index] = updatedSubject;
      _saveSubjects();
      notifyListeners();
    }
  }

  void deleteSubject(String id) {
    _subjects.removeWhere((subject) => subject.id == id);
    _saveSubjects();
    notifyListeners();
  }

  // --- Attendance Logic ---

  void markAttendance(String id, {required bool isPresent}) {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      final current = _subjects[index];

      _subjects[index] = current.copyWith(
        totalClasses: current.totalClasses + 1,
        attendedClasses: isPresent ? current.attendedClasses + 1 : current.attendedClasses,
      );

      _saveSubjects();
      notifyListeners();
    }
  }

  // (Optional but helpful) Undo the last mark if the user clicked the wrong button
  void undoAttendance(String id, {required bool wasPresent}) {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      final current = _subjects[index];

      // Prevent going below 0
      if (current.totalClasses > 0) {
        _subjects[index] = current.copyWith(
          totalClasses: current.totalClasses - 1,
          attendedClasses: (wasPresent && current.attendedClasses > 0)
              ? current.attendedClasses - 1
              : current.attendedClasses,
        );

        _saveSubjects();
        notifyListeners();
      }
    }
  }
}