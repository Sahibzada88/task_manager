import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import 'storage_info_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _storageService.loadAppSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storageService.saveAppSettings(_settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildNotificationSection(),
          const SizedBox(height: 24),
          _buildDefaultsSection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: taskProvider.isDarkMode,
                  onChanged: (_) => taskProvider.toggleTheme(),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive notifications for due tasks'),
              value: _settings['notifications_enabled'] ?? true,
              onChanged: (value) {
                setState(() {
                  _settings['notifications_enabled'] = value;
                });
                _saveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Defaults',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Default Priority'),
              subtitle: Text(_settings['default_priority'] ?? 'medium'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showPriorityDialog(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Default Category'),
              subtitle: Text(_settings['default_category'] ?? 'General'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCategoryDialog(),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Auto-delete Completed'),
              subtitle: const Text('Automatically delete completed tasks after 30 days'),
              value: _settings['auto_delete_completed'] ?? false,
              onChanged: (value) {
                setState(() {
                  _settings['auto_delete_completed'] = value;
                });
                _saveSettings();
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('Storage Information'),
              subtitle: const Text('View where your data is stored'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StorageInfoScreen(),
                  ),
                );
              },
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Tasks'),
              subtitle: const Text('Export all tasks to file'),
              onTap: () => _showExportDialog(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Create Backup'),
              subtitle: const Text('Backup all data including settings'),
              onTap: () => _createBackup(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Storage Usage'),
              subtitle: FutureBuilder<int>(
                future: _storageService.getStorageSize(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final sizeKB = (snapshot.data! / 1024).toStringAsFixed(1);
                    return Text('$sizeKB KB used');
                  }
                  return const Text('Calculating...');
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Clear All Data',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text('Delete all tasks and settings'),
              onTap: () => _showClearDataDialog(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Version'),
              subtitle: Text('1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text('Developer'),
              subtitle: Text('Task Manager Pro Team'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Privacy Policy'),
              subtitle: const Text('View privacy policy'),
              onTap: () => _showPrivacyPolicy(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Low'),
                value: 'low',
                groupValue: _settings['default_priority'],
                onChanged: (value) {
                  setState(() {
                    _settings['default_priority'] = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Medium'),
                value: 'medium',
                groupValue: _settings['default_priority'],
                onChanged: (value) {
                  setState(() {
                    _settings['default_priority'] = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('High'),
                value: 'high',
                groupValue: _settings['default_priority'],
                onChanged: (value) {
                  setState(() {
                    _settings['default_priority'] = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Urgent'),
                value: 'urgent',
                groupValue: _settings['default_priority'],
                onChanged: (value) {
                  setState(() {
                    _settings['default_priority'] = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    controller.text = _settings['default_category'] ?? 'General';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _settings['default_category'] = controller.text.trim();
                });
                _saveSettings();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Tasks'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final result = await context.read<TaskProvider>().exportTasksToJson();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tasks exported: $result')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('JSON'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final result = await context.read<TaskProvider>().exportTasksToCsv();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tasks exported: $result')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('CSV'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBackup() async {
    try {
      final taskProvider = context.read<TaskProvider>();
      final exportService = ExportService();

      final result = await exportService.exportBackup(taskProvider.tasks, _settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup created: $result')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all tasks, settings, and app data. This action cannot be undone.\n\nAre you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<TaskProvider>().clearAllTasks();
                  await _storageService.clearAllData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to clear data: $e')),
                    );
                  }
                }
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const SingleChildScrollView(
            child: Text(
              'Task Manager Pro Privacy Policy\n\n'
                  '1. Data Collection: We only store data locally on your device.\n\n'
                  '2. Data Usage: Your task data is used solely for app functionality.\n\n'
                  '3. Data Sharing: We do not share your data with third parties.\n\n'
                  '4. Data Security: All data is stored securely on your device.\n\n'
                  '5. Data Control: You have full control over your data and can export or delete it at any time.\n\n'
                  'For questions, contact: support@taskmanagerpro.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
