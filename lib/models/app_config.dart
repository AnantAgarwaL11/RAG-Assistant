class AppConfig {
  String backendUrl;
  String apiKey;
  String modelType;
  int chunkSize;
  int chunkOverlap;
  int batchSize;
  double temperature;
  int maxTokens;

  AppConfig({
    this.backendUrl = 'http://10.0.2.2:8000/api', // Android emulator localhost
    this.apiKey = 'my-secret-rag-key-2024',
    this.modelType = 'OpenAI GPT-3.5',
    this.chunkSize = 1000,
    this.chunkOverlap = 200,
    this.batchSize = 10,
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  Map<String, dynamic> toJson() {
    return {
      'backendUrl': backendUrl,
      'apiKey': apiKey,
      'modelType': modelType,
      'chunkSize': chunkSize,
      'chunkOverlap': chunkOverlap,
      'batchSize': batchSize,
      'temperature': temperature,
      'maxTokens': maxTokens,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      backendUrl: json['backendUrl'] ?? 'http://10.0.2.2:8000/api',
      apiKey: json['apiKey'] ?? 'my-secret-rag-key-2024',
      modelType: json['modelType'] ?? 'OpenAI GPT-3.5',
      chunkSize: json['chunkSize'] ?? 1000,
      chunkOverlap: json['chunkOverlap'] ?? 200,
      batchSize: json['batchSize'] ?? 10,
      temperature: json['temperature']?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] ?? 1000,
    );
  }

  AppConfig copyWith({
    String? backendUrl,
    String? apiKey,
    String? modelType,
    int? chunkSize,
    int? chunkOverlap,
    int? batchSize,
    double? temperature,
    int? maxTokens,
  }) {
    return AppConfig(
      backendUrl: backendUrl ?? this.backendUrl,
      apiKey: apiKey ?? this.apiKey,
      modelType: modelType ?? this.modelType,
      chunkSize: chunkSize ?? this.chunkSize,
      chunkOverlap: chunkOverlap ?? this.chunkOverlap,
      batchSize: batchSize ?? this.batchSize,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }
}