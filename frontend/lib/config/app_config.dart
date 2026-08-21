enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool debugLogging;
  final List<String> allowedEmailDomains;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.debugLogging = false,
    this.allowedEmailDomains = const ['campus.edu'],
  });

  factory AppConfig.dev() {
    return AppConfig(
      environment: Environment.development,
      apiBaseUrl: 'http://localhost:3000/api/graphql',
      debugLogging: true,
      allowedEmailDomains: const ['campus.edu'],
    );
  }

  factory AppConfig.prod() {
    return AppConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.campuslostfound.com/api/graphql',
      debugLogging: false,
      allowedEmailDomains: const ['campus.edu'],
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
