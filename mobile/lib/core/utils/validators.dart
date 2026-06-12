/// Form and field validators for workshop service advisor flows.
abstract final class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? registrationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Registration number is required';
    }
    if (value.trim().length < 3) {
      return 'Enter a valid registration number';
    }
    return null;
  }

  static String? odometer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Odometer reading is required';
    }
    final reading = int.tryParse(value.replaceAll(',', '').trim());
    if (reading == null || reading < 0) {
      return 'Enter a valid odometer reading';
    }
    if (reading > 9999999) {
      return 'Odometer reading seems too high';
    }
    return null;
  }

  static String? positiveAmount(String? value, {String fieldName = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final amount = double.tryParse(value.replaceAll(',', '').trim());
    if (amount == null || amount < 0) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> rules) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  }
}
