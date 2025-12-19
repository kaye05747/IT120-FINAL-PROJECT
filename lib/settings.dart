import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'providers/settings_provider.dart';
import 'services/detection_service.dart';
import 'services/firestore_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isTestingConnection = false;
  bool _isConnected = false;
  int _firebaseCount = 0;
  bool _isLoadingFirebaseCount = false;
  bool _isWritingTestData = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Provider will automatically load settings
    _checkFirebaseConnection();
    _loadFirebaseCount();
  }

  Future<void> _checkFirebaseConnection() async {
    final connected = await DetectionService.instance.isFirebaseConnected();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<void> _loadFirebaseCount() async {
    setState(() {
      _isLoadingFirebaseCount = true;
    });
    
    final count = await DetectionService.instance.getFirebaseDetectionCount();
    
    if (mounted) {
      setState(() {
        _firebaseCount = count;
        _isLoadingFirebaseCount = false;
      });
    }
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isTestingConnection = true;
    });

    final success = await DetectionService.instance.testFirebaseConnection();
    
    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _isConnected = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Firebase connection successful!' 
              : 'Firebase connection failed. Check your configuration.'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (success) {
        _loadFirebaseCount(); // Refresh count if connection successful
      }
    }
  }

  
  Future<void> _writeSampleDataToFirestore() async {
    setState(() {
      _isWritingTestData = true;
    });

    try {
      await _firestoreService.writeSampleData();
      
      if (mounted) {
        setState(() {
          _isWritingTestData = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data written to Firestore successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWritingTestData = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to write sample data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showClearDataDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text('This will delete all your classification history and settings from both local storage and Firebase. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await settingsProvider.clearAllData();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.pink,
                    ),
                  );
                  _loadFirebaseCount(); // Refresh Firebase count
                }
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearFirebaseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Firebase Data'),
          content: const Text('This will delete all detection data from Firebase Cloud Firestore only. Local data will remain. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await DetectionService.instance.clearFirebaseOnly();
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Firebase data cleared successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadFirebaseCount(); // Refresh Firebase count
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to clear Firebase data: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Clear Firebase',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildSwitchTile(
                'Dark Theme',
                'Use dark theme across the app',
                settingsProvider.isDarkTheme,
                (value) => settingsProvider.setDarkTheme(value),
              ),
          
          // Classification Settings
              const SizedBox(height: 24),
              _buildSectionHeader('Classification'),
              _buildSliderTile(
                'Confidence Threshold',
                'Minimum confidence for predictions',
                settingsProvider.confidenceThreshold,
                50.0,
                100.0,
                (value) => settingsProvider.setConfidenceThreshold(value),
              ),
              _buildDropdownTile(
                'Image Quality',
                'Quality of captured images',
                settingsProvider.imageQuality,
                ['low', 'medium', 'high'],
                (value) => settingsProvider.setImageQuality(value),
              ),
              
              // Data Management
              const SizedBox(height: 24),
              _buildSectionHeader('Data Management'),
              _buildSwitchTile(
                'Auto Save Images',
                'Automatically save classified images',
                settingsProvider.autoSaveImages,
                (value) => settingsProvider.setAutoSaveImages(value),
              ),
              _buildSwitchTile(
                'Notifications',
                'Show notifications for classification results',
                settingsProvider.notificationsEnabled,
                (value) => settingsProvider.setNotificationsEnabled(value),
              ),

              // Firebase Section
              const SizedBox(height: 24),
              _buildSectionHeader('Firebase Cloud Storage'),
              _buildFirebaseStatusTile(),
              _buildActionTile(
                'Test Firebase Connection',
                'Check if Firebase is properly configured and connected',
                _isTestingConnection ? Icons.hourglass_empty : Icons.cloud_done,
                _isConnected ? Colors.green : Colors.orange,
                _isTestingConnection ? () {} : () => _testFirebaseConnection(),
              ),
              _buildActionTile(
                'Write Sample Data',
                'Test writing sample orchid data to Firestore',
                _isWritingTestData ? Icons.hourglass_empty : Icons.upload,
                Colors.blue,
                _isWritingTestData ? () {} : () => _writeSampleDataToFirestore(),
              ),
              _buildActionTile(
                'Clear Firebase Data',
                'Delete all data from Firebase Cloud Firestore only',
                Icons.cloud_off,
                Colors.deepOrange,
                _showClearFirebaseDialog,
              ),
          
          // Danger Zone
              const SizedBox(height: 24),
              _buildSectionHeader('Danger Zone'),
              _buildActionTile(
                'Clear All Data',
                'Delete all history and reset settings',
                Icons.delete_sweep,
                Colors.red,
                () => _showClearDataDialog(settingsProvider),
              ),
              
              // App Info
              const SizedBox(height: 24),
              _buildSectionHeader('About'),
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('Model', 'Flower Classification v1.0'),
              _buildInfoTile('Developer', 'Flower Classification Team'),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.pink.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This flower classification app uses machine learning to identify different flower species. The app can classify 10 different types of orchids and flowers with high accuracy.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.pink.shade700,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.pink,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 10,
            activeColor: Colors.pink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> options, Function(String) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option.toUpperCase()),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFirebaseStatusTile() {
    return ListTile(
      leading: Icon(
        _isConnected ? Icons.cloud_done : Icons.cloud_off,
        color: _isConnected ? Colors.green : Colors.red,
      ),
      title: Text('Firebase Status'),
      subtitle: Text(_isConnected ? 'Connected' : 'Disconnected'),
      trailing: _isLoadingFirebaseCount
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text('$_firebaseCount detections'),
      contentPadding: EdgeInsets.zero,
    );
  }
}
