class AppValidators {
  AppValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    final age = now.year - value.year -
        ((now.month > value.month ||
                (now.month == value.month && now.day >= value.day))
            ? 0
            : 1);
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    return null;
  }

  static String? validateListeningGoal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Goal is required';
    }
    final hours = double.tryParse(value);
    if (hours == null || hours <= 0) {
      return 'Enter a valid number of hours';
    }
    if (hours > 744) {
      return 'Hours cannot exceed 744 (hours in a month)';
    }
    return null;
  }
}
