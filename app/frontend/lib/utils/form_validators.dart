/// Utility class containing form validation functions for the onboarding flow.
class FormValidators {
  /// Validates a first name field.
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'First name must be at least 2 characters';
    }
    
    if (trimmed.length > 50) {
      return 'First name must be less than 50 characters';
    }
    
    // Allow letters, spaces, hyphens, and apostrophes
    final namePattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!namePattern.hasMatch(trimmed)) {
      return 'First name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates a last name field (optional).
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Last name is optional
    }
    
    final trimmed = value.trim();
    if (trimmed.length > 50) {
      return 'Last name must be less than 50 characters';
    }
    
    // Allow letters, spaces, hyphens, and apostrophes
    final namePattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!namePattern.hasMatch(trimmed)) {
      return 'Last name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates a date of birth (optional).
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return null; // Date of birth is optional
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birthDate = DateTime(value.year, value.month, value.day);
    
    // Cannot be in the future
    if (birthDate.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }
    
    // Cannot be more than 18 years ago (for RESP eligibility)
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    if (birthDate.isBefore(eighteenYearsAgo)) {
      return 'Child must be under 18 years old for RESP eligibility';
    }
    
    return null;
  }

  /// Validates a slug field.
  static String? validateSlug(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL slug is required';
    }
    
    final trimmed = value.trim().toLowerCase();
    
    if (trimmed.length < 2) {
      return 'URL slug must be at least 2 characters';
    }
    
    if (trimmed.length > 50) {
      return 'URL slug must be less than 50 characters';
    }
    
    // Only allow lowercase letters, numbers, and hyphens
    final slugPattern = RegExp(r'^[a-z0-9-]+$');
    if (!slugPattern.hasMatch(trimmed)) {
      return 'URL slug can only contain lowercase letters, numbers, and hyphens';
    }
    
    // Cannot start or end with hyphen
    if (trimmed.startsWith('-') || trimmed.endsWith('-')) {
      return 'URL slug cannot start or end with a hyphen';
    }
    
    // Cannot have consecutive hyphens
    if (trimmed.contains('--')) {
      return 'URL slug cannot contain consecutive hyphens';
    }
    
    // Check for reserved words
    final reservedWords = [
      'admin', 'api', 'app', 'www', 'mail', 'ftp', 'localhost',
      'dashboard', 'login', 'signup', 'about', 'contact', 'help',
      'support', 'terms', 'privacy', 'legal', 'blog', 'news',
      'gift', 'gifts', 'payment', 'checkout', 'success', 'error',
      'null', 'undefined', 'true', 'false', 'test', 'demo'
    ];
    
    if (reservedWords.contains(trimmed)) {
      return 'This URL slug is reserved. Please choose a different one';
    }
    
    return null;
  }

  /// Validates a gift page headline.
  static String? validateHeadline(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Headline is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'Headline must be at least 5 characters';
    }
    
    if (trimmed.length > 100) {
      return 'Headline must be less than 100 characters';
    }
    
    return null;
  }

  /// Validates a gift page blurb/description.
  static String? validateBlurb(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Description must be at least 10 characters';
    }
    
    if (trimmed.length > 500) {
      return 'Description must be less than 500 characters';
    }
    
    return null;
  }

  /// Validates a savings goal amount.
  static String? validateGoalAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Goal amount is optional
    }
    
    final trimmed = value.trim();
    final amount = double.tryParse(trimmed);
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount < 0) {
      return 'Goal amount cannot be negative';
    }
    
    if (amount > 1000000) {
      return 'Goal amount cannot exceed \$1,000,000';
    }
    
    // Check for reasonable decimal places (max 2)
    final decimalPlaces = trimmed.contains('.') 
        ? trimmed.split('.')[1].length 
        : 0;
    
    if (decimalPlaces > 2) {
      return 'Amount can have at most 2 decimal places';
    }
    
    return null;
  }

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final trimmed = value.trim();
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    
    if (trimmed.length > 254) {
      return 'Email address is too long';
    }
    
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validates that two password fields match.
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates a file upload (for photo uploads).
  static String? validateFileUpload(String? fileName, int? fileSizeBytes) {
    if (fileName == null || fileName.isEmpty) {
      return null; // File upload is optional
    }
    
    // Check file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension = allowedExtensions.any(
      (ext) => fileName.toLowerCase().endsWith(ext)
    );
    
    if (!hasValidExtension) {
      return 'Please upload a valid image file (JPG, PNG, GIF, or WebP)';
    }
    
    // Check file size (max 5MB)
    if (fileSizeBytes != null && fileSizeBytes > 5 * 1024 * 1024) {
      return 'File size must be less than 5MB';
    }
    
    return null;
  }

  /// Sanitizes a string by trimming whitespace and removing extra spaces.
  static String sanitizeString(String? value) {
    if (value == null) return '';
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats a name by capitalizing the first letter of each word.
  static String formatName(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    
    final sanitized = sanitizeString(value);
    return sanitized.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats a slug by converting to lowercase and replacing spaces with hyphens.
  static String formatSlug(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}