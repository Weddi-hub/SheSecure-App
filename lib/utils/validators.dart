class Validators {
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Name validator
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z ]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Phone validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  // Confirm password validator
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Age validator
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 13) {
      return 'You must be at least 13 years old';
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // Emergency contact validator
  static String? emergencyContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emergency contact is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }

    return null;
  }

  // Address validator
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    return null;
  }

  // PIN validator (for app security)
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }

    final pinRegex = RegExp(r'^[0-9]{4,6}$');
    if (!pinRegex.hasMatch(value)) {
      return 'PIN must be 4-6 digits';
    }

    return null;
  }

  // OTP validator
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    final otpRegex = RegExp(r'^[0-9]{6}$');
    if (!otpRegex.hasMatch(value)) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  // Generic required field validator
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Date validator
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }

    return null;
  }

  // File size validator (for image uploads)
  static String? fileSize(List<int>? bytes, int maxSizeInMB) {
    if (bytes == null) {
      return 'File is required';
    }

    final sizeInMB = bytes.length / (1024 * 1024);
    if (sizeInMB > maxSizeInMB) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }

    return null;
  }

  // Multiple validators
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // Real-time email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    return emailRegex.hasMatch(email);
  }

  // Real-time phone validation
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // Password strength checker
  static double passwordStrength(String password) {
    double strength = 0.0;

    // Length
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Complexity
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    return strength.clamp(0.0, 1.0);
  }

  // Get password strength label
  static String passwordStrengthLabel(String password) {
    final strength = passwordStrength(password);

    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  // Get password strength color
  static int passwordStrengthColor(String password) {
    final strength = passwordStrength(password);

    if (strength < 0.3) return 0xFFEA4335; // Red
    if (strength < 0.6) return 0xFFFBBC05; // Yellow
    if (strength < 0.8) return 0xFF34A853; // Green
    return 0xFF4285F4; // Blue
  }
}