/// Supported application build environments
enum Environment {
  dev,
  staging,
  prod,
}

extension EnvironmentX on Environment {
  bool get isDev => this == Environment.dev;
  bool get isStaging => this == Environment.staging;
  bool get isProd => this == Environment.prod;
  
  String get name => toString().split('.').last;
}
