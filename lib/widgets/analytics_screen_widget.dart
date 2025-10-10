// lib/widgets/analytics_screen_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/document_service.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class AnalyticsScreenWidget extends StatefulWidget {
  @override
  _AnalyticsScreenWidgetState createState() => _AnalyticsScreenWidgetState();
}

class _AnalyticsScreenWidgetState extends State<AnalyticsScreenWidget> {
  int _storageSize = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  Future<void> _loadStorageStats() async {
    setState(() => _isLoading = true);
    final storageService = context.read<StorageService>();
    final size = await storageService.getTotalStorageSize();
    setState(() {
      _storageSize = size;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<DocumentService, ChatService, StorageService>(
      builder: (context, docService, chatService, storageService, child) {
        final totalDocs = docService.totalDocuments;
        final processedDocs = docService.processedDocuments;
        final totalPages = docService.totalPages;
        final totalMessages = chatService.messages.length;
        final totalWords = docService.documents.fold<int>(
            0, (sum, doc) => sum + doc.wordCount);
        final totalChunks = docService.documents.fold<int>(
            0, (sum, doc) => sum + doc.chunkCount);

        Map<String, int> docsByType = {};
        for (var doc in docService.documents) {
          String type = doc.fileExtension.toUpperCase();
          docsByType[type] = (docsByType[type] ?? 0) + 1;
        }

        return RefreshIndicator(
          onRefresh: _loadStorageStats,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                      title: 'Documents',
                      value: totalDocs.toString(),
                      subtitle: '$processedDocs processed',
                      icon: Icons.description,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Success Rate',
                      value: totalDocs > 0
                          ? '${((processedDocs / totalDocs) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      subtitle: 'Processing success',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Storage Used',
                      value: storageService.formatFileSize(_storageSize),
                      subtitle: 'Local storage',
                      icon: Icons.storage,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Chat Messages',
                      value: totalMessages.toString(),
                      subtitle: '${chatService.getUniqueSessions().length} sessions',
                      icon: Icons.chat,
                      color: Colors.purple,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Document Analysis
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Analysis',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 16),
                        if (docsByType.isEmpty)
                          Text('No documents processed yet', style: TextStyle(color: Colors.grey[600]))
                        else
                          ...docsByType.entries.map((entry) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: entry.key == 'PDF' ? Colors.red[400] : Colors.blue[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('${entry.key}: '),
                                Text('${entry.value} files', style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  totalPages.toString(),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                                ),
                                Text('Total Pages', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  totalWords.toString(),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                ),
                                Text('Total Words', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  totalChunks.toString(),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                                ),
                                Text('Total Chunks', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // System Info
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Storage Usage',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.cleaning_services, size: 16),
                              label: Text('Cleanup'),
                              onPressed: () async {
                                await storageService.cleanupOldFiles();
                                _loadStorageStats();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Cleanup completed')),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _storageSize / (100 * 1024 * 1024),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${storageService.formatFileSize(_storageSize)} used',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 12),
                        Text(
                          'Last Processing',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        Text(
                          docService.documents.isNotEmpty &&
                              docService.documents.any((d) => d.processedDate != null)
                              ? _formatDate(docService.documents
                              .where((d) => d.processedDate != null)
                              .map((d) => d.processedDate!)
                              .reduce((a, b) => a.isAfter(b) ? a : b))
                              : 'No processing yet',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.download, size: 16),
                                label: Text('Export', style: TextStyle(fontSize: 13)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Export feature coming soon!')),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.upload, size: 16),
                                label: Text('Import', style: TextStyle(fontSize: 13)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Import feature coming soon!')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}