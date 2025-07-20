import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/storage_service.dart';

class StorageInfoScreen extends StatefulWidget {
  const StorageInfoScreen({super.key});

  @override
  State<StorageInfoScreen> createState() => _StorageInfoScreenState();
}

class _StorageInfoScreenState extends State<StorageInfoScreen> {
  final StorageService _storageService = StorageService();
  Map<String, dynamic> _storageInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    try {
      final storageSize = await _storageService.getStorageSize();
      final settings = await _storageService.loadAppSettings();

      setState(() {
        _storageInfo = {
          'storageSize': storageSize,
          'storageSizeKB': (storageSize / 1024).toStringAsFixed(2),
          'platform': _getPlatformInfo(),
          'storageLocation': _getStorageLocation(),
          'dataTypes': _getDataTypes(),
          'settings': settings,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getPlatformInfo() {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS';
    } else {
      return 'Unknown Platform';
    }
  }

  String _getStorageLocation() {
    if (kIsWeb) {
      return 'Browser Local Storage\n(DevTools → Application → Local Storage)';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android Secure Storage\n(/data/data/com.example.taskManager/shared_prefs/)';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS App Sandbox\n(Documents Directory)';
    } else {
      return 'Platform-specific secure storage';
    }
  }

  List<String> _getDataTypes() {
    return [
      'Tasks (JSON format)',
      'App Settings',
      'Theme Preferences',
      'User Preferences',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Information'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStorageOverviewCard(taskProvider),
              const SizedBox(height: 16),
              _buildPlatformInfoCard(),
              const SizedBox(height: 16),
              _buildDataTypesCard(),
              const SizedBox(height: 16),
              _buildStorageActionsCard(taskProvider),
              const SizedBox(height: 16),
              _buildExportLocationCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStorageOverviewCard(TaskProvider taskProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storage_rounded,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Storage Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Platform', _storageInfo['platform'] ?? 'Unknown'),
            _buildInfoRow('Storage Size', '${_storageInfo['storageSizeKB']} KB'),
            _buildInfoRow('Total Tasks', taskProvider.totalTasksCount.toString()),
            _buildInfoRow('Completed Tasks', taskProvider.completedTasksCount.toString()),
            _buildInfoRow('Pending Tasks', taskProvider.pendingTasksCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Storage Location',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text(
                _storageInfo['storageLocation'] ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (kIsWeb) ...[
              const Text(
                '💡 To view your data in browser:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('1. Open Browser DevTools (F12)'),
              const Text('2. Go to Application tab'),
              const Text('3. Expand Local Storage'),
              const Text('4. Look for your app domain'),
            ] else ...[
              const Text(
                '🔒 Your data is stored securely on your device and never leaves your phone unless you explicitly export it.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Stored Data Types',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_storageInfo['dataTypes'] as List<String>? ?? []).map(
                  (dataType) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(dataType),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageActionsCard(TaskProvider taskProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Storage Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Refresh Storage Info'),
              subtitle: const Text('Update storage size and information'),
              onTap: () {
                setState(() {
                  _isLoading = true;
                });
                _loadStorageInfo();
              },
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.backup_rounded),
              title: const Text('Create Backup'),
              subtitle: const Text('Export all data including settings'),
              onTap: () async {
                try {
                  final settings = await _storageService.loadAppSettings();
                  // This would call the backup export method
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup feature available in Settings')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Color(0xFFFFB800),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Locations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (kIsWeb) ...[
              _buildInfoRow('JSON/CSV Exports', 'Browser Downloads folder'),
              _buildInfoRow('Backup Files', 'Browser Downloads folder'),
              const SizedBox(height: 8),
              const Text(
                '📁 Files are downloaded to your browser\'s default download location',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              _buildInfoRow('JSON/CSV Exports', 'Share dialog (save anywhere)'),
              _buildInfoRow('Backup Files', 'Share dialog (save anywhere)'),
              const SizedBox(height: 8),
              const Text(
                '📤 Files can be saved to any location or shared with other apps',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
