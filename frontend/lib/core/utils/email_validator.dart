class EmailValidator {
  static bool isCampusEmail(String email, {required List<String> allowedDomains}) {
    final normalized = email.trim().toLowerCase();
    if (!normalized.contains('@')) return false;

    final domain = normalized.split('@').last;
    return allowedDomains.any((allowed) => domain == allowed.toLowerCase());
  }

  static String? validationMessage(String email, {required List<String> allowedDomains}) {
    if (email.trim().isEmpty) return 'Please enter an email';

    if (!email.contains('@')) return 'Please enter a valid email';

    if (!isCampusEmail(email, allowedDomains: allowedDomains)) {
      final domains = allowedDomains.map((domain) => '@$domain').join(', ');
      return 'Use your campus email ($domains)';
    }

    return null;
  }
}
