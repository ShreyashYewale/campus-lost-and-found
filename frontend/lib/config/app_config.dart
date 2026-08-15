enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String googleClientId;
  final bool debugLogging;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.googleClientId,
    this.debugLogging = false,
  });

  factory AppConfig.dev() {
    return AppConfig(
      environment: Environment.development,
      apiBaseUrl: 'http://localhost:4000/graphql',
      googleClientId: 'YOUR_GOOGLE_CLIENT_ID_DEV',
      debugLogging: true,
    );
  }

  factory AppConfig.prod() {
    return AppConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.campuslostfound.com/graphql',
      googleClientId: 'YOUR_GOOGLE_CLIENT_ID_PROD',
      debugLogging: false,
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
}
