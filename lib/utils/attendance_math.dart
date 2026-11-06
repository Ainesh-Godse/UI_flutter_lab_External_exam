class AttendanceMath {
  /// Returns the current attendance percentage (0.0 to 100.0).
  /// Returns 0.0 if total classes is 0.
  static double currentPercentage(int attended, int total) {
    if (total <= 0) return 0.0;
    return (attended / total) * 100;
  }

  /// Calculates how many consecutive future classes a student MUST attend
  /// to reach the target percentage.
  /// Returns 0 if the target is already met.
  /// Returns null if it is mathematically impossible (e.g., target is 100% but a class was already missed).
  static int? classesNeededToReach(int attended, int total, int targetPercentage) {
    if (targetPercentage <= 0) return 0;
    if (currentPercentage(attended, total) >= targetPercentage) return 0;

    // If target is 100%, and they have missed even 1 class, it's impossible.
    if (targetPercentage >= 100) {
      if (attended == total) return 0;
      return null;
    }

    double target = targetPercentage / 100.0;

    // Formula: x = (target * total - attended) / (1 - target)
    double needed = ((target * total) - attended) / (1 - target);

    return needed.ceil();
  }

  /// Calculates how many future classes a student can safely skip (bunk)
  /// while still staying above or equal to the target percentage.
  /// Returns null if the target is 0 (meaning infinite skips).
  static int? safeSkips(int attended, int total, int targetPercentage) {
    if (targetPercentage <= 0) return null;
    if (targetPercentage >= 100) return 0;

    double target = targetPercentage / 100.0;

    // Max total classes allowed without dropping below target
    int maxAllowedTotal = (attended / target).floor();

    int skips = maxAllowedTotal - total;

    return skips > 0 ? skips : 0;
  }
}