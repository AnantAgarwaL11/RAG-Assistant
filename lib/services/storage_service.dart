import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';
import '../models/chat_message.dart';
import '../models/app_config.dart';

class StorageService extends ChangeNotifier {
  static const String _documentsFileName = 'documents.json';
  static const String _chatHistoryFileName = 'chat_history.json';
  static const String _configKey = 'app_config';

  Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Document storage
  Future<List<DocumentModel>> loadDocuments() async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_documentsFileName');

      if (!await file.exists()) {
        return [];
      }

      String content = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading documents: $e');
      return [];
    }
  }

  Future<void> saveDocuments(List<DocumentModel> documents) async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_documentsFileName');

      List<Map<String, dynamic>> jsonList =
      documents.map((doc) => doc.toJson()).toList();

      await file.writeAsString(jsonEncode(jsonList));
      notifyListeners();
    } catch (e) {
      print('Error saving documents: $e');
    }
  }

  Future<void> clearDocuments() async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_documentsFileName');
      if (await file.exists()) {
        await file.delete();
      }
      notifyListeners();
    } catch (e) {
      print('Error clearing documents: $e');
    }
  }

  // Chat history storage
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_chatHistoryFileName');

      if (!await file.exists()) {
        return [];
      }

      String content = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_chatHistoryFileName');

      List<Map<String, dynamic>> jsonList =
      messages.map((msg) => msg.toJson()).toList();

      await file.writeAsString(jsonEncode(jsonList));
      notifyListeners();
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  Future<void> clearChatHistory() async {
    try {
      String dir = await getDocumentsDirectory();
      File file = File('$dir/$_chatHistoryFileName');
      if (await file.exists()) {
        await file.delete();
      }
      notifyListeners();
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  // Configuration storage (using SharedPreferences for simplicity)
  Future<AppConfig> loadAppConfig() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? configJson = prefs.getString(_configKey);

      if (configJson != null) {
        Map<String, dynamic> json = jsonDecode(configJson);
        return AppConfig.fromJson(json);
      }

      return AppConfig(); // Return default config
    } catch (e) {
      print('Error loading app config: $e');
      return AppConfig(); // Return default config
    }
  }

  Future<void> saveAppConfig(AppConfig config) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String configJson = jsonEncode(config.toJson());
      await prefs.setString(_configKey, configJson);
      notifyListeners();
    } catch (e) {
      print('Error saving app config: $e');
    }
  }

  // Utility methods
  Future<int> getTotalStorageSize() async {
    try {
      String dir = await getDocumentsDirectory();
      Directory directory = Directory(dir);
      int totalSize = 0;

      if (await directory.exists()) {
        await for (FileSystemEntity entity in directory.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('Error calculating storage size: $e');
      return 0;
    }
  }

  Future<void> cleanupOldFiles() async {
    try {
      String dir = await getDocumentsDirectory();
      Directory directory = Directory(dir);
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: 30));

      if (await directory.exists()) {
        await for (FileSystemEntity entity in directory.list()) {
          if (entity is File &&
              !entity.path.contains(_documentsFileName) &&
              !entity.path.contains(_chatHistoryFileName)) {
            FileStat stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error cleaning up old files: $e');
    }
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      int totalSize = await getTotalStorageSize();
      int documentCount = (await loadDocuments()).length;
      int messageCount = (await loadChatHistory()).length;

      return {
        'totalSize': totalSize,
        'documentCount': documentCount,
        'messageCount': messageCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {
        'totalSize': 0,
        'documentCount': 0,
        'messageCount': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}