// lib/services/document_service.dart
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../models/document_model.dart';
import '../models/app_config.dart';
import 'storage_service.dart';

class DocumentService extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<DocumentModel> _documents = [];
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String _processingStatus = '';
  AppConfig _config = AppConfig();

  List<DocumentModel> get documents => _documents;
  bool get isProcessing => _isProcessing;
  double get processingProgress => _processingProgress;
  String get processingStatus => _processingStatus;
  AppConfig get config => _config;

  int get totalDocuments => _documents.length;
  int get processedDocuments => _documents.where((d) => d.isProcessed).length;
  int get totalPages => _documents.fold(0, (sum, doc) => sum + doc.pageCount);

  Future<void> initialize() async {
    await _loadDocuments();
    await _loadConfig();
  }

  Future<void> pickAndUploadDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        _isProcessing = true;
        _processingProgress = 0.0;
        notifyListeners();

        List<File> files = result.paths.map((path) => File(path!)).toList();

        for (int i = 0; i < files.length; i++) {
          File file = files[i];
          _processingStatus = 'Processing ${file.path.split('/').last}...';
          _processingProgress = (i + 1) / files.length;
          notifyListeners();

          await _processDocument(file);
        }

        _isProcessing = false;
        _processingStatus = 'Processing complete!';
        notifyListeners();

        await _saveDocuments();
      }
    } catch (e) {
      _isProcessing = false;
      _processingStatus = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _processDocument(File file) async {
    try {
      DocumentModel document = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filename: file.path.split('/').last,
        filePath: file.path,
        fileSize: await file.length(),
        uploadDate: DateTime.now(),
        isProcessed: false,
      );

      await _simulateProcessing(document);

      _documents.add(document);
      notifyListeners();
    } catch (e) {
      print('Error processing document: $e');
    }
  }

  Future<void> _simulateProcessing(DocumentModel document) async {
    await Future.delayed(Duration(seconds: 2));

    document.isProcessed = true;
    document.pageCount = 10;
    document.wordCount = 2500;
    document.chunkCount = 5;
    document.processedDate = DateTime.now();
    document.vectorId = 'mock_vector_${document.id}';
  }

  Future<void> _sendToBackendForProcessing(DocumentModel document) async {
    try {
      File file = File(document.filePath);
      List<int> fileBytes = await file.readAsBytes();
      String base64File = base64Encode(fileBytes);

      Map<String, dynamic> requestBody = {
        'filename': document.filename,
        'file_content': base64File,
        'chunk_size': _config.chunkSize,
        'chunk_overlap': _config.chunkOverlap,
        'extract_tables': true,
        'extract_images': true
      };

      final response = await http.post(
        Uri.parse('${_config.backendUrl}/documents/process-document'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config.apiKey}',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(minutes: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        document.isProcessed = true;
        document.pageCount = result['page_count'] ?? 0;
        document.wordCount = result['word_count'] ?? 0;
        document.chunkCount = result['chunk_count'] ?? 0;
        document.extractedText = result['extracted_text'] ?? '';
        document.metadata = Map<String, dynamic>.from(result['metadata'] ?? {});
        document.vectorId = result['vector_id'];
        document.processedDate = DateTime.now();
      } else {
        document.processingError = 'Backend processing failed: ${response.statusCode}';
      }
    } catch (e) {
      document.processingError = e.toString();
      print('Backend processing error: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      _documents.removeWhere((doc) => doc.id == documentId);
      await _saveDocuments();
      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> retryProcessing(String documentId) async {
    try {
      DocumentModel? document = _documents.firstWhere(
            (doc) => doc.id == documentId,
      );

      document.isProcessed = false;
      document.processingError = null;
      document.processedDate = null;

      _processingStatus = 'Retrying ${document.filename}...';
      notifyListeners();

      await _simulateProcessing(document);
      await _saveDocuments();
      notifyListeners();
    } catch (e) {
      print('Error retrying processing: $e');
    }
  }

  void updateConfig(AppConfig newConfig) {
    _config = newConfig;
    _saveConfig();
    notifyListeners();
  }

  Future<void> clearAllDocuments() async {
    _documents.clear();
    await _storageService.clearDocuments();
    notifyListeners();
  }

  Future<void> _loadDocuments() async {
    _documents = await _storageService.loadDocuments();
    notifyListeners();
  }

  Future<void> _saveDocuments() async {
    await _storageService.saveDocuments(_documents);
  }

  Future<void> _loadConfig() async {
    _config = await _storageService.loadAppConfig();
    notifyListeners();
  }

  Future<void> _saveConfig() async {
    await _storageService.saveAppConfig(_config);
  }
}