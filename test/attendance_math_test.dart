import 'package:flutter_test/flutter_test.dart';
import 'package:ui_flutter_lab_external/utils/attendance_math.dart';

void main() {
  group('Attendance Math Logic Tests', () {

    test('currentPercentage calculates correctly', () {
      // Normal case
      expect(AttendanceMath.currentPercentage(75, 100), 75.0);
      // 0 attended
      expect(AttendanceMath.currentPercentage(0, 50), 0.0);
      // 100% attended
      expect(AttendanceMath.currentPercentage(50, 50), 100.0);
      // Edge case: 0 total classes (should not divide by zero)
      expect(AttendanceMath.currentPercentage(0, 0), 0.0);
    });

    test('classesNeededToReach calculates correctly', () {
      // Already met target
      expect(AttendanceMath.classesNeededToReach(80, 100, 75), 0);
      // Needs 20 classes (70 -> 90 out of 120 = 75%)
      expect(AttendanceMath.classesNeededToReach(70, 100, 75), 20);
      // Impossible: target is 100% but a class was missed
      expect(AttendanceMath.classesNeededToReach(99, 100, 100), null);
    });

    test('safeSkips calculates correctly', () {
      // At 80% (80/100), target is 75%. Can skip 6 classes before hitting target.
      expect(AttendanceMath.safeSkips(80, 100, 75), 6);
      // Exactly at target, cannot skip any
      expect(AttendanceMath.safeSkips(75, 100, 75), 0);
      // Target is 0, can skip infinitely (represented as null)
      expect(AttendanceMath.safeSkips(50, 100, 0), null);
    });
  });
}