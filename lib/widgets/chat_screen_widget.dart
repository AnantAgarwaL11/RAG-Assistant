// lib/widgets/chat_screen_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/document_service.dart';
import '../models/chat_message.dart';

class ChatScreenWidget extends StatefulWidget {
  @override
  _ChatScreenWidgetState createState() => _ChatScreenWidgetState();
}

class _ChatScreenWidgetState extends State<ChatScreenWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatService, DocumentService>(
      builder: (context, chatService, documentService, child) {
        return Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chat with Documents',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${documentService.processedDocuments} documents ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: chatService.startNewSession,
                    tooltip: 'New Session',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () => _showClearChatDialog(context),
                    tooltip: 'Clear History',
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: chatService.messages.isEmpty
                  ? _buildEmptyState(context, documentService)
                  : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: chatService.messages.length,
                itemBuilder: (context, index) {
                  return _ChatMessageBubble(
                    message: chatService.messages[index],
                  );
                },
              ),
            ),

            // Loading indicator
            if (chatService.isLoading)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Thinking...'),
                  ],
                ),
              ),

            // Message input
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: documentService.processedDocuments > 0
                            ? 'Ask a question about your documents...'
                            : 'Please upload and process documents first',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      enabled: documentService.processedDocuments > 0 && !chatService.isLoading,
                      onSubmitted: (_) => _sendMessage(chatService, documentService),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: documentService.processedDocuments > 0 &&
                        !chatService.isLoading &&
                        _messageController.text.trim().isNotEmpty
                        ? () => _sendMessage(chatService, documentService)
                        : null,
                    child: Icon(Icons.send),
                    mini: true,
                    backgroundColor: Colors.blue[600],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, DocumentService documentService) {
    if (documentService.processedDocuments == 0) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 20),
              Text(
                'No documents available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upload and process documents first',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ask questions about your documents',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestedQueryChip('What are the main topics?', _messageController, () => _sendMessage(context.read<ChatService>(), context.read<DocumentService>())),
                _SuggestedQueryChip('Summarize key findings', _messageController, () => _sendMessage(context.read<ChatService>(), context.read<DocumentService>())),
                _SuggestedQueryChip('Compare methodologies', _messageController, () => _sendMessage(context.read<ChatService>(), context.read<DocumentService>())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatService chatService, DocumentService documentService) {
    if (_messageController.text.trim().isEmpty) return;

    String message = _messageController.text.trim();
    _messageController.clear();
    chatService.sendMessage(message);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat History'),
        content: Text('This will delete all chat messages. Continue?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear'),
            onPressed: () {
              context.read<ChatService>().clearAllMessages();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat history cleared')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestedQueryChip extends StatelessWidget {
  final String query;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _SuggestedQueryChip(this.query, this.controller, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(query, style: TextStyle(fontSize: 12)),
      onPressed: () {
        controller.text = query;
        onTap();
      },
      backgroundColor: Colors.blue[100],
      labelStyle: TextStyle(color: Colors.blue[700]),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Colors.blue[600]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: message.isUser
                    ? Radius.circular(4)
                    : Radius.circular(18),
                bottomLeft: message.isUser
                    ? Radius.circular(18)
                    : Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                if (message.confidence != null && !message.isUser) ...[
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Confidence: ${(message.confidence! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Timestamp
          SizedBox(height: 4),
          Text(
            message.timeFormatted,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),

          // Sources
          if (message.sources != null && message.sources!.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  childrenPadding: EdgeInsets.all(12),
                  leading: Icon(Icons.source, size: 18),
                  title: Text(
                    'Sources (${message.sources!.length})',
                    style: TextStyle(fontSize: 13),
                  ),
                  children: message.sources!.map((source) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, size: 14, color: Colors.blue[600]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${source.documentName}, page ${source.pageNumber}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          source.content.length > 100
                              ? '${source.content.substring(0, 100)}...'
                              : source.content,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}