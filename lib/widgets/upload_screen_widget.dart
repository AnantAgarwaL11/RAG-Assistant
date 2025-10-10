// lib/widgets/upload_screen_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/document_service.dart';
import '../models/document_model.dart';

class UploadScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentService>(
      builder: (context, documentService, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Upload Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 80,
                          color: Colors.blue[600],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Upload Documents',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select PDF or Word documents to process',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: documentService.isProcessing
                              ? null
                              : documentService.pickAndUploadDocuments,
                          icon: Icon(Icons.file_upload),
                          label: Text('Select Documents'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Processing Status
                if (documentService.isProcessing) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing Documents',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: documentService.processingProgress,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            documentService.processingStatus,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(documentService.processingProgress * 100).toStringAsFixed(1)}% Complete',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Quick Stats
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Statistics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatCard(
                              title: 'Total',
                              value: documentService.totalDocuments.toString(),
                              icon: Icons.description,
                              color: Colors.blue,
                            ),
                            _StatCard(
                              title: 'Processed',
                              value: documentService.processedDocuments.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _StatCard(
                              title: 'Pages',
                              value: documentService.totalPages.toString(),
                              icon: Icons.pages,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Recent Documents
                if (documentService.documents.isNotEmpty) ...[
                  Text(
                    'Recent Documents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...documentService.documents.take(5).map((document) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: document.isProcessed
                              ? Colors.green[100]
                              : document.hasError
                              ? Colors.red[100]
                              : Colors.orange[100],
                          child: Icon(
                            document.fileExtension == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.description,
                            color: document.isProcessed
                                ? Colors.green[700]
                                : document.hasError
                                ? Colors.red[700]
                                : Colors.orange[700],
                          ),
                        ),
                        title: Text(
                          document.filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${document.fileSizeFormatted} • ${document.uploadDateFormatted}',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: _getStatusIcon(document),
                        onTap: () => _showDocumentDetails(context, document),
                      ),
                    );
                  }).toList(),
                ] else ...[
                  SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No documents uploaded yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload your first document to get started',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(DocumentModel document) {
    if (document.isProcessed) {
      return Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else if (document.hasError) {
      return Icon(Icons.error, color: Colors.red, size: 24);
    } else {
      return Icon(Icons.hourglass_empty, color: Colors.orange, size: 24);
    }
  }

  void _showDocumentDetails(BuildContext context, DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.filename),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('File Size', document.fileSizeFormatted),
              _DetailRow('Upload Date', document.uploadDateFormatted),
              _DetailRow('Status', document.isProcessed ? 'Processed' :
              document.hasError ? 'Error' : 'Processing'),

              if (document.isProcessed) ...[
                Divider(height: 24),
                _DetailRow('Pages', document.pageCount.toString()),
                _DetailRow('Words', document.wordCount.toString()),
                _DetailRow('Chunks', document.chunkCount.toString()),
              ],

              if (document.hasError) ...[
                Divider(height: 24),
                Text(
                  'Error Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    document.processingError ?? 'Unknown error',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (document.hasError)
            TextButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<DocumentService>().retryProcessing(document.id);
              },
            ),
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}