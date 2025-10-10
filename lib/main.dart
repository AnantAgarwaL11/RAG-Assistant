import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/document_service.dart';
import 'services/chat_service.dart';
import 'services/storage_service.dart';
import 'widgets/upload_screen_widget.dart';
import 'widgets/chat_screen_widget.dart';
import 'widgets/documents_screen_widget.dart';
import 'widgets/analytics_screen_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'RAG Document Assistant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFF1976D2),
            unselectedItemColor: Colors.grey[600],
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    UploadScreenWidget(),
    ChatScreenWidget(),
    DocumentsScreenWidget(),
    AnalyticsScreenWidget(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize services when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentService>().initialize();
      context.read<ChatService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RAG Document Assistant'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.api, color: Colors.blue[600]),
                title: Text('API Configuration'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showApiConfigDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.tune, color: Colors.orange[600]),
                title: Text('Processing Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showProcessingConfigDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.storage, color: Colors.green[600]),
                title: Text('Storage Management'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showStorageDialog(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showApiConfigDialog(BuildContext context) {
    final apiKeyController = TextEditingController();
    final backendUrlController = TextEditingController();
    String selectedModel = 'OpenAI GPT-3.5';

    // Load current config
    final documentService = context.read<DocumentService>();
    apiKeyController.text = documentService.config.apiKey;
    backendUrlController.text = documentService.config.backendUrl;
    selectedModel = documentService.config.modelType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('API Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: backendUrlController,
                decoration: InputDecoration(
                  labelText: 'Backend URL',
                  hintText: 'http://10.0.2.2:8000/api',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'your-api-key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedModel,
                decoration: InputDecoration(
                  labelText: 'Model Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'OpenAI GPT-3.5',
                  'OpenAI GPT-4',
                  'HuggingFace Mistral',
                  'HuggingFace Flan-T5',
                ].map((model) => DropdownMenuItem(
                  value: model,
                  child: Text(model),
                )).toList(),
                onChanged: (value) => selectedModel = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () {
              final newConfig = documentService.config.copyWith(
                backendUrl: backendUrlController.text,
                apiKey: apiKeyController.text,
                modelType: selectedModel,
              );
              documentService.updateConfig(newConfig);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configuration saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProcessingConfigDialog(BuildContext context) {
    final documentService = context.read<DocumentService>();
    double chunkSize = documentService.config.chunkSize.toDouble();
    double chunkOverlap = documentService.config.chunkOverlap.toDouble();
    int batchSize = documentService.config.batchSize;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Processing Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chunk Size: ${chunkSize.toInt()}'),
              Slider(
                value: chunkSize,
                min: 500,
                max: 2000,
                divisions: 15,
                onChanged: (value) => setState(() => chunkSize = value),
              ),
              SizedBox(height: 16),
              Text('Chunk Overlap: ${chunkOverlap.toInt()}'),
              Slider(
                value: chunkOverlap,
                min: 50,
                max: 500,
                divisions: 18,
                onChanged: (value) => setState(() => chunkOverlap = value),
              ),
              SizedBox(height: 16),
              Text('Batch Size: $batchSize'),
              Slider(
                value: batchSize.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: (value) => setState(() => batchSize = value.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final newConfig = documentService.config.copyWith(
                  chunkSize: chunkSize.toInt(),
                  chunkOverlap: chunkOverlap.toInt(),
                  batchSize: batchSize,
                );
                documentService.updateConfig(newConfig);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Processing settings saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download, color: Colors.blue),
              title: Text('Export Data'),
              subtitle: Text('Backup your documents and chats'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export functionality coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.upload, color: Colors.green),
              title: Text('Import Data'),
              subtitle: Text('Restore from backup'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import functionality coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text('Clear All Data'),
              subtitle: Text('Delete everything (irreversible)'),
              onTap: () => _showClearDataConfirmation(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    Navigator.of(context).pop(); // Close storage dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'This will permanently delete all documents and chat history. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All Data'),
            onPressed: () {
              context.read<DocumentService>().clearAllDocuments();
              context.read<ChatService>().clearAllMessages();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}