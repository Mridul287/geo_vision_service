import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/geo_api_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeoApiService _apiService = GeoApiService();
  List<Map<String, String>> _recentUploads = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentUploads();
  }

  Future<void> _loadRecentUploads() async {
    final recent = await _apiService.getRecentUploads();
    setState(() {
      _recentUploads = recent;
    });
  }

  Future<void> _handleImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final File imageFile = File(image.path);
    final int sizeInBytes = await imageFile.length();

    if (sizeInBytes > 10 * 1024 * 1024) {
      _showSizeLimitDialog();
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _apiService.uploadImage(imageFile);
      _showSuccessMessage();
      _loadRecentUploads();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSizeLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Too Large'),
        content: const Text('The image size exceeds the 10MB limit. Please choose a smaller image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image uploaded successfully. View analysis on dashboard.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload failed: $message'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Logic to retry can be added here
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: AppTheme.accentColor),
            SizedBox(width: 8),
            Text('GeoVision', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _isUploading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentColor),
                  )
                : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _handleImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload from Gallery'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.accentColor,
                          side: const BorderSide(color: AppTheme.accentColor, width: 2),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 48),
            const Text(
              'Recent Uploads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _recentUploads.isEmpty
                  ? Center(
                      child: Text(
                        'No recent uploads',
                        style: TextStyle(color: AppTheme.mutedText),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recentUploads.length,
                      itemBuilder: (context, index) {
                        final upload = _recentUploads[index];
                        final DateTime dateTime = DateTime.parse(upload['time']!);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(upload['location']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppTheme.mutedText),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
