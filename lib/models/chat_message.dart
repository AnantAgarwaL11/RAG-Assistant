class ChatMessage {
  String id;
  String text;
  bool isUser;
  DateTime timestamp;
  String sessionId;
  List<DocumentSource>? sources;
  double? confidence;
  String? error;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
    this.sources,
    this.confidence,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
      'sources': sources?.map((s) => s.toJson()).toList(),
      'confidence': confidence,
      'error': error,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
      sources: (json['sources'] as List?)
          ?.map((s) => DocumentSource.fromJson(s))
          .toList(),
      confidence: json['confidence']?.toDouble(),
      error: json['error'],
    );
  }

  String get timeFormatted {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class DocumentSource {
  String documentId;
  String documentName;
  String content;
  int pageNumber;
  double similarity;

  DocumentSource({
    required this.documentId,
    required this.documentName,
    required this.content,
    required this.pageNumber,
    required this.similarity,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'documentName': documentName,
      'content': content,
      'pageNumber': pageNumber,
      'similarity': similarity,
    };
  }

  factory DocumentSource.fromJson(Map<String, dynamic> json) {
    return DocumentSource(
      documentId: json['documentId'] ?? '',
      documentName: json['documentName'] ?? '',
      content: json['content'] ?? '',
      pageNumber: json['pageNumber'] ?? 1,
      similarity: json['similarity']?.toDouble() ?? 0.0,
    );
  }
}