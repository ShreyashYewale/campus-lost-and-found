enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool debugLogging;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.debugLogging = false,
  });

  factory AppConfig.dev() {
    return AppConfig(
      environment: Environment.development,
      apiBaseUrl: 'http://localhost:3000/api/graphql',
      debugLogging: true,
    );
  }

  factory AppConfig.prod() {
    return AppConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.campuslostfound.com/graphql',
      debugLogging: false,
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
