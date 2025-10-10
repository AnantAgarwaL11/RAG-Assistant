// lib/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'RAG Document Assistant';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered document processing and querying';

  // API Configuration
  static const String defaultBackendUrl = 'http://10.0.2.2:8000/api'; // Android emulator localhost
  static const String defaultApiKey = 'my-secret-rag-key-2024';

  // Processing Configuration
  static const int defaultChunkSize = 1000;
  static const int defaultChunkOverlap = 200;
  static const int defaultBatchSize = 10;
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1000;

  // File Constraints
  static const int maxFileSizeMB = 100;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  static const List<String> supportedExtensions = ['pdf', 'doc', 'docx'];
  static const List<String> supportedMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  // UI Constants
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);

  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Status Colors
  static const Color processedColor = Color(0xFF4CAF50);
  static const Color processingColor = Color(0xFFFF9800);
  static const Color errorStatusColor = Color(0xFFF44336);
  static const Color pendingColor = Color(0xFF9E9E9E);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration veryLongAnimation = Duration(seconds: 1);

  // Model Types
  static const List<String> availableModels = [
    'OpenAI GPT-3.5',
    'OpenAI GPT-4',
    'HuggingFace Mistral',
    'HuggingFace Flan-T5',
  ];

  // Embedding Models
  static const List<String> availableEmbeddingModels = [
    'sentence-transformers/all-MiniLM-L6-v2',
    'sentence-transformers/all-mpnet-base-v2',
    'sentence-transformers/multi-qa-MiniLM-L6-cos-v1',
  ];

  // Status Messages
  static const String processingStarted = 'Starting document processing...';
  static const String processingComplete = 'Document processing completed!';
  static const String processingError = 'Error occurred during processing';
  static const String noInternetConnection = 'No internet connection available';
  static const String apiError = 'API request failed';
  static const String noDocumentsFound = 'No documents found';
  static const String uploadSuccess = 'Document uploaded successfully';
  static const String deleteSuccess = 'Document deleted successfully';
  static const String configSaved = 'Configuration saved successfully';

  // Validation Messages
  static const String invalidFileType = 'Invalid file type. Please select PDF or Word documents.';
  static const String fileTooLarge = 'File is too large. Maximum size is 100MB.';
  static const String noFileSelected = 'No file selected';
  static const String emptyMessage = 'Please enter a message';

  // Suggested Queries
  static const List<String> suggestedQueries = [
    'What are the main topics?',
    'Summarize key findings',
    'Compare methodologies',
    'List important dates',
    'Extract key statistics',
    'What are the conclusions?',
  ];

  // Storage Keys (for SharedPreferences)
  static const String configKey = 'app_config';
  static const String documentsKey = 'documents_list';
  static const String chatHistoryKey = 'chat_history';
  static const String settingsKey = 'app_settings';

  // API Endpoints
  static const String processDocumentEndpoint = '/documents/process-document';
  static const String chatEndpoint = '/chat/';
  static const String documentsEndpoint = '/documents';
  static const String analyticsEndpoint = '/analytics/';
  static const String exportEndpoint = '/analytics/export-vector-store';
  static const String importEndpoint = '/analytics/import-vector-store';
  static const String clearDataEndpoint = '/analytics/clear-all-data';

  // Timeouts
  static const Duration apiTimeout = Duration(minutes: 10);
  static const Duration chatTimeout = Duration(minutes: 2);
  static const Duration uploadTimeout = Duration(minutes: 15);

  // Limits
  static const int maxChatHistory = 100;
  static const int maxDocuments = 1000;
  static const int maxSearchResults = 50;
  static const int maxRecentDocuments = 5;

  // File Names
  static const String documentsFileName = 'documents.json';
  static const String chatHistoryFileName = 'chat_history.json';
  static const String configFileName = 'config.json';

  // Text Styles (can be used throughout the app)
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 48.0;
  static const double extraLargeIconSize = 80.0;

  // Helper Methods
  static String getFileTypeLabel(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      default:
        return 'Document';
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processed':
        return processedColor;
      case 'processing':
        return processingColor;
      case 'error':
        return errorStatusColor;
      default:
        return pendingColor;
    }
  }

  static IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}