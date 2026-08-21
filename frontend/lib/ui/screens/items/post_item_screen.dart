import 'dart:typed_data';

import 'package:campus_lost_found/core/services/api_service.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/item_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({Key? key}) : super(key: key);

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _itemType = 'lost';
  String _category = 'other';
  bool _isSubmitting = false;
  Uint8List? _photoBytes;
  String? _photoFilename;

  final categories = ['electronics', 'id_cards', 'keys', 'bags', 'books', 'clothing', 'other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (kIsWeb && source == ImageSource.camera) {
      final host = Uri.base.host;
      if (host != 'localhost' && host != '127.0.0.1') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera on web only works at http://localhost:8080. Use Gallery, or restart with --web-hostname=localhost.',
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
        requestFullMetadata: !kIsWeb,
      );

      if (picked == null) {
        if (mounted && source == ImageSource.camera) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera was not opened. Allow camera permission in the browser, or use Gallery.',
              ),
            ),
          );
        }
        return;
      }

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _photoBytes = bytes;
        _photoFilename = picked.name.isNotEmpty ? picked.name : 'photo.jpg';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera error: $e. Try Gallery instead.'
                  : 'Could not pick image: $e',
            ),
          ),
        );
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _photoBytes = null;
      _photoFilename = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an Item')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Item Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(label: Text('Lost'), value: 'lost'),
                    ButtonSegment(label: Text('Found'), value: 'found'),
                  ],
                  selected: {_itemType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _itemType = newSelection.first);
                  },
                ),
                const SizedBox(height: 24),
                const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_photoBytes != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _photoBytes!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filled(
                          onPressed: _clearPhoto,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Add a photo to help others identify the item'),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Item Title',
                    hintText: 'e.g., Blue backpack',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the item in detail',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 16),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.replaceAll('_', ' ')),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value ?? 'other'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Library entrance',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Post Item'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    await authService.ensureInitialized();
    if (!authService.isAuthenticated || authService.userId == null || authService.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to post an item')),
        );
        context.push('/login');
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      context.read<ApiService>().setSessionToken(authService.token);
      final itemService = context.read<ItemService>();
      final created = await itemService.createItem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _itemType,
        category: _category,
        location: _locationController.text.trim(),
        postedById: authService.userId!,
        photoBytes: _photoBytes,
        photoFilename: _photoFilename,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(created ? 'Item posted successfully!' : 'Unable to post item.'),
          ),
        );
        if (created) context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        final needsLogin = message.contains('KS_ACCESS_DENIED') ||
            message.contains('Access denied');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              needsLogin
                  ? 'Session expired. Please sign out and sign in again.'
                  : 'Error: $e',
            ),
          ),
        );
        if (needsLogin) {
          await authService.logout();
          if (mounted) context.push('/login');
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
