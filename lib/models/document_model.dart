class DocumentModel {
  String id;
  String filename;
  String filePath;
  int fileSize;
  DateTime uploadDate;
  bool isProcessed;
  int pageCount;
  int wordCount;
  int chunkCount;
  String? extractedText;
  Map<String, dynamic>? metadata;
  String? vectorId;
  String? processingError;
  DateTime? processedDate;

  DocumentModel({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.fileSize,
    required this.uploadDate,
    this.isProcessed = false,
    this.pageCount = 0,
    this.wordCount = 0,
    this.chunkCount = 0,
    this.extractedText,
    this.metadata,
    this.vectorId,
    this.processingError,
    this.processedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'filePath': filePath,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'isProcessed': isProcessed,
      'pageCount': pageCount,
      'wordCount': wordCount,
      'chunkCount': chunkCount,
      'extractedText': extractedText,
      'metadata': metadata,
      'vectorId': vectorId,
      'processingError': processingError,
      'processedDate': processedDate?.toIso8601String(),
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      filename: json['filename'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      uploadDate: DateTime.parse(json['uploadDate']),
      isProcessed: json['isProcessed'] ?? false,
      pageCount: json['pageCount'] ?? 0,
      wordCount: json['wordCount'] ?? 0,
      chunkCount: json['chunkCount'] ?? 0,
      extractedText: json['extractedText'],
      metadata: json['metadata'],
      vectorId: json['vectorId'],
      processingError: json['processingError'],
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'])
          : null,
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    return filename.split('.').last.toLowerCase();
  }

  String get uploadDateFormatted {
    return '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
  }

  bool get hasError => processingError != null;
}