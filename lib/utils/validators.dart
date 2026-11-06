class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? validateTotalClasses(String? value, int? attended) {
    final baseError = validateNumber(value, 'Total classes');
    if (baseError != null) return baseError;

    final total = int.parse(value!);
    if (attended != null && total < attended) {
      return 'Total cannot be less than attended';
    }
    return null;
  }

  static String? validateTarget(String? value) {
    final baseError = validateNumber(value, 'Target');
    if (baseError != null) return baseError;

    final target = int.parse(value!);
    if (target < 0 || target > 100) {
      return 'Target must be between 0 and 100';
    }
    return null;
  }
}