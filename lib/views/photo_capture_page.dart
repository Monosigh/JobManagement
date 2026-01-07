import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class PhotoCapturePage extends StatefulWidget {
  final Task task;
  final Map<String, dynamic>? photoToEdit;

  const PhotoCapturePage({super.key, required this.task, this.photoToEdit});

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final TextEditingController _noteController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.photoToEdit != null) {
      _isEditing = true;
      _noteController.text = widget.photoToEdit!['note'] as String? ?? '';
      _selectedImage = XFile(widget.photoToEdit!['path'] as String);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPickerRow(),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    _buildImageReview(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 28, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Text(
            _isEditing ? 'Edit Photo' : 'Photo Capture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerRow() {
    return Row(
      children: [
        _buildPickButton(
          icon: Icons.folder_open,
          label: 'Select File',
          onTap: () => _pick(ImageSource.gallery),
        ),
        const SizedBox(width: 12),
        _buildPickButton(
          icon: Icons.photo_camera,
          label: 'Camera',
          onTap: () => _pick(ImageSource.camera),
        ),
      ],
    );
  }

  Widget _buildPickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Colors.grey[700]),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Review',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImage == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 36,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No image have chosen',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _selectedImage = null),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'Tap to insert notes',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_selectedImage == null && !_isEditing) ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                (_selectedImage == null && !_isEditing)
                    ? Colors.grey[300]
                    : const Color(0xFF00C853),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(_isEditing ? 'Save Changes' : 'Add Photo'),
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _save() async {
    if (_selectedImage == null && !_isEditing) return;

    if (_isEditing && widget.photoToEdit != null) {
      // Update existing photo (either with new image or just note)
      final List<dynamic> currentPhotos = List<dynamic>.from(
        widget.task.details['photos'] ?? const [],
      );

      final int photoIndex = currentPhotos.indexWhere(
        (p) => p['path'] == widget.photoToEdit!['path'],
      );

      if (photoIndex != -1) {
        if (_selectedImage != null) {
          // Replace the photo with a new one
          currentPhotos[photoIndex] = {
            'path': _selectedImage!.path,
            'note': _noteController.text.trim(),
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          };
        } else {
          // Just update the note
          currentPhotos[photoIndex] = {
            ...currentPhotos[photoIndex],
            'note': _noteController.text.trim(),
          };
        }

        widget.task.details['photos'] = currentPhotos;
        await _databaseHelper.updateTaskDetails(widget.task.title, {
          'photos': currentPhotos,
        });
      }
    } else if (_selectedImage != null) {
      // Add new photo
      final Map<String, dynamic> newEntry = {
        'path': _selectedImage!.path,
        'note': _noteController.text.trim(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      final List<dynamic> currentPhotos = List<dynamic>.from(
        widget.task.details['photos'] ?? const [],
      );
      currentPhotos.add(newEntry);

      widget.task.details['photos'] = currentPhotos;
      await _databaseHelper.updateTaskDetails(widget.task.title, {
        'photos': currentPhotos,
      });
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
