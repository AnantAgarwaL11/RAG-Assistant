// lib/widgets/documents_screen_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/document_service.dart';
import '../models/document_model.dart';

class DocumentsScreenWidget extends StatefulWidget {
  @override
  _DocumentsScreenWidgetState createState() => _DocumentsScreenWidgetState();
}

class _DocumentsScreenWidgetState extends State<DocumentsScreenWidget> {
  String _searchQuery = '';
  String _filterType = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentService>(
      builder: (context, documentService, child) {
        List<DocumentModel> filteredDocuments = _getFilteredDocuments(documentService.documents);

        return Column(
          children: [
            // Search and Filter
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filterType,
                          isExpanded: true,
                          items: ['All', 'PDF', 'Word', 'Processed', 'Error']
                              .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() => _filterType = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Document List
            Expanded(
              child: filteredDocuments.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: doc.isProcessed
                                    ? Colors.green[100]
                                    : doc.hasError ? Colors.red[100] : Colors.orange[100],
                                child: Icon(
                                  doc.fileExtension == 'pdf' ? Icons.picture_as_pdf : Icons.description,
                                  color: doc.isProcessed
                                      ? Colors.green[700]
                                      : doc.hasError ? Colors.red[700] : Colors.orange[700],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.filename,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${doc.fileSizeFormatted} • ${doc.uploadDateFormatted}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _confirmDelete(context, doc, documentService);
                                  } else if (value == 'retry') {
                                    documentService.retryProcessing(doc.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (doc.hasError)
                                    PopupMenuItem(
                                      value: 'retry',
                                      child: Row(
                                        children: [
                                          Icon(Icons.refresh, size: 18),
                                          SizedBox(width: 8),
                                          Text('Retry'),
                                        ],
                                      ),
                                    ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (doc.isProcessed)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                                  SizedBox(width: 6),
                                  Text(
                                    '${doc.pageCount} pages • ${doc.wordCount} words • ${doc.chunkCount} chunks',
                                    style: TextStyle(fontSize: 11, color: Colors.green[700]),
                                  ),
                                ],
                              ),
                            )
                          else if (doc.hasError)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.error, size: 16, color: Colors.red[700]),
                                      SizedBox(width: 6),
                                      Text('Processing failed', style: TextStyle(fontSize: 11, color: Colors.red[700])),
                                    ],
                                  ),
                                  if (doc.processingError != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      doc.processingError!,
                                      style: TextStyle(fontSize: 10, color: Colors.red[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 6),
                                  Text('Processing...', style: TextStyle(fontSize: 11, color: Colors.orange[700])),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<DocumentModel> _getFilteredDocuments(List<DocumentModel> documents) {
    List<DocumentModel> filtered = documents;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doc) =>
          doc.filename.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    switch (_filterType) {
      case 'PDF':
        filtered = filtered.where((doc) => doc.fileExtension == 'pdf').toList();
        break;
      case 'Word':
        filtered = filtered.where((doc) =>
        doc.fileExtension == 'doc' || doc.fileExtension == 'docx').toList();
        break;
      case 'Processed':
        filtered = filtered.where((doc) => doc.isProcessed).toList();
        break;
      case 'Error':
        filtered = filtered.where((doc) => doc.hasError).toList();
        break;
    }

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No documents found' : 'No documents uploaded',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filter'
                : 'Upload your first document to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentModel document, DocumentService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.filename}"?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
            onPressed: () {
              service.deleteDocument(document.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Document deleted')),
              );
            },
          ),
        ],
      ),
    );
  }
}