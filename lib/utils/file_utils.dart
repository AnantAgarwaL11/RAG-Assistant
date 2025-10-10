// lib/utils/file_utils.dart
import 'dart:io';
import 'dart:convert';

class FileUtils {
  /// Convert file to base64 string
  static Future<String> fileToBase64(File file) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      return base64Encode(fileBytes);
    } catch (e) {
      throw Exception('Error converting file to base64: $e');
    }
  }

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    if (!filename.contains('.')) return '';
    return filename.split('.').last.toLowerCase();
  }

  /// Check if file type is supported
  static bool isSupportedFileType(String filename) {
    String extension = getFileExtension(filename);
    return ['pdf', 'doc', 'docx'].contains(extension);
  }

  /// Format DateTime in readable format
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get relative time string (e.g., "2 minutes ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Validate file size (max 100MB)
  static bool isFileSizeValid(int bytes, {int maxSizeMB = 100}) {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return bytes <= maxBytes;
  }

  /// Get file icon based on extension
  static String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'txt':
        return '📃';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      default:
        return '📁';
    }
  }

  /// Sanitize filename (remove special characters)
  static String sanitizeFilename(String filename) {
    return filename.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
  }

  /// Extract filename from path
  static String getFilenameFromPath(String path) {
    return path.split('/').last;
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete file
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Copy file to new location
  static Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      print('Error copying file: $e');
      return false;
    }
  }
}