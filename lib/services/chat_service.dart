// lib/services/chat_service.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/chat_message.dart';
import '../models/app_config.dart';
import 'storage_service.dart';

class ChatService extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentSessionId = '';
  AppConfig _config = AppConfig();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get currentSessionId => _currentSessionId;
  AppConfig get config => _config;

  Future<void> initialize() async {
    await _loadChatHistory();
    await _loadConfig();
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    ChatMessage userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    await _simulateAIResponse(messageText);

    _isLoading = false;
    notifyListeners();
    await _saveChatHistory();
  }

  Future<void> _simulateAIResponse(String userMessage) async {
    await Future.delayed(Duration(seconds: 2));

    String aiResponse = _generateMockResponse(userMessage);

    List<DocumentSource> mockSources = [
      DocumentSource(
        documentId: 'doc_1',
        documentName: 'research_paper.pdf',
        content: 'Based on comprehensive analysis, the key findings indicate significant trends...',
        pageNumber: 3,
        similarity: 0.92,
      ),
    ];

    ChatMessage aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
      sources: mockSources,
      confidence: 0.88,
    );

    _messages.add(aiMessage);
  }

  String _generateMockResponse(String userMessage) {
    String message = userMessage.toLowerCase();

    if (message.contains('key findings') || message.contains('main findings')) {
      return 'Based on the processed documents, the key findings include:\n\n1. Market trends show 23% growth in digital adoption\n2. Customer behavior patterns indicate preference for mobile-first solutions\n3. Strategic recommendations focus on user experience optimization\n\nThese insights are drawn from comprehensive analysis across multiple data sources.';
    } else if (message.contains('summarize') || message.contains('summary')) {
      return 'Here\'s a comprehensive summary of your documents:\n\nThe research presents a detailed analysis of current market conditions, emerging trends, and strategic opportunities. Key themes include digital transformation, customer engagement strategies, and performance optimization techniques.';
    } else if (message.contains('topics') || message.contains('themes')) {
      return 'The main topics covered in your documents include:\n\n• Digital transformation strategies\n• Market analysis and trends\n• Customer behavior insights\n• Performance metrics and KPIs\n• Implementation recommendations\n\nEach topic is supported by data-driven analysis and practical examples.';
    } else {
      return 'I understand you\'re asking about "${userMessage}". Based on the processed documents, I can provide relevant insights. The analysis shows comprehensive coverage of this topic with supporting evidence and practical recommendations.';
    }
  }

  Future<void> _sendToBackendAPI(String messageText) async {
    try {
      final response = await http.post(
        Uri.parse('${_config.backendUrl}/chat/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config.apiKey}',
        },
        body: jsonEncode({
          'message': messageText,
          'session_id': _currentSessionId,
          'model_type': _config.modelType,
          'max_tokens': _config.maxTokens,
          'temperature': _config.temperature,
        }),
      ).timeout(Duration(minutes: 2));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        ChatMessage aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: result['response'],
          isUser: false,
          timestamp: DateTime.now(),
          sessionId: _currentSessionId,
          sources: (result['sources'] as List?)
              ?.map((source) => DocumentSource.fromJson(source))
              .toList(),
          confidence: result['confidence']?.toDouble(),
        );

        _messages.add(aiMessage);
      }
    } catch (e) {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I couldn\'t connect to the server.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
        error: e.toString(),
      ));
    }
  }

  void updateConfig(AppConfig newConfig) {
    _config = newConfig;
    _saveConfig();
    notifyListeners();
  }

  Future<void> clearAllMessages() async {
    _messages.clear();
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await _storageService.clearChatHistory();
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((msg) => msg.id == messageId);
    await _saveChatHistory();
    notifyListeners();
  }

  Future<void> startNewSession() async {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    notifyListeners();
  }

  List<ChatMessage> getSessionMessages(String sessionId) {
    return _messages.where((msg) => msg.sessionId == sessionId).toList();
  }

  List<String> getUniqueSessions() {
    return _messages.map((msg) => msg.sessionId).toSet().toList();
  }

  Future<void> _loadChatHistory() async {
    _messages = await _storageService.loadChatHistory();
    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    await _storageService.saveChatHistory(_messages);
  }

  Future<void> _loadConfig() async {
    _config = await _storageService.loadAppConfig();
    notifyListeners();
  }

  Future<void> _saveConfig() async {
    await _storageService.saveAppConfig(_config);
  }
}