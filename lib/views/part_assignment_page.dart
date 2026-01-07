import 'package:flutter/material.dart';
import '../models/task.dart';
import 'part_categories_page.dart';
import '../database/database_helper.dart'; // Added import for DatabaseHelper

class PartAssignmentPage extends StatefulWidget {
  final Task task;

  const PartAssignmentPage({super.key, required this.task});

  @override
  State<PartAssignmentPage> createState() => _PartAssignmentPageState();
}

class _PartAssignmentPageState extends State<PartAssignmentPage> {
  List<Map<String, dynamic>> _tempParts = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing parts from the task
    _tempParts = _getAssignedParts();
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
                  children: [_buildPartsSection()],
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
            'Assign Part',
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

  Widget _buildPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Parts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            IconButton(
              onPressed: () => _navigateToCategories(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_tempParts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.build, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No parts have chosen',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          Column(
            children: _tempParts.map((part) => _buildPartItem(part)).toList(),
          ),
      ],
    );
  }

  Widget _buildPartItem(Map<String, dynamic> part) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
          // Part image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _getPartImage(part['id']),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part['name'] ?? 'Unknown Part',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                if (part['category'] != null)
                  Text(
                    part['category'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removePart(part),
            icon: Icon(Icons.remove_circle, color: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  Widget _getPartImage(String? partId) {
    // Map part IDs to their corresponding image assets
    String imagePath;
    switch (partId) {
      case 'led_headlight_left':
      case 'led_headlight_right':
        imagePath = 'assets/LED_Car_Head_Light.jpg';
        break;
      case 'led_backlight_left':
      case 'led_backlight_right':
        imagePath = 'assets/LED_Car_Back_Light.webp';
        break;
      case 'brake_light':
        imagePath = 'assets/Brake_light.jpg';
        break;
      case 'spark_plug':
        imagePath = 'assets/Spark_plug.jpg';
        break;
      case 'air_filter':
        imagePath = 'assets/Air_filters.jpeg';
        break;
      case 'oil_filter':
        imagePath = 'assets/Oil_filters.jpg';
        break;
      case 'airbag_sensor':
        imagePath = 'assets/Airbag_sensor.jpeg';
        break;
      case 'seatbelt_buckle':
        imagePath = 'assets/Seatbelt_buckle.jpg';
        break;
      case 'instrument_cluster':
        imagePath = 'assets/Instrument_cluster.webp';
        break;
      default:
        // Default icon for unknown parts
        return Container(
          color: Colors.grey[100],
          child: Icon(Icons.build, size: 24, color: Colors.grey[600]),
        );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if image fails to load
        print('DEBUG: Failed to load image: $imagePath, Error: $error');
        return Container(
          color: Colors.grey[100],
          child: Icon(Icons.build, size: 24, color: Colors.grey[600]),
        );
      },
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
          onPressed: _tempParts.isNotEmpty ? _confirmParts : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _tempParts.isNotEmpty
                    ? const Color(0xFF00C853)
                    : Colors.grey[300],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _tempParts.isNotEmpty
                ? 'Confirm (${_tempParts.length} parts)'
                : 'Confirm',
          ),
        ),
      ),
    );
  }

  void _navigateToCategories() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartCategoriesPage(task: widget.task),
      ),
    );

    if (result != null && mounted) {
      // If a part was added, add it to the temporary parts list
      if (result is Map<String, dynamic>) {
        setState(() {
          _tempParts.add(result);
        });
      }
    }
  }

  void _removePart(Map<String, dynamic> part) {
    setState(() {
      // Find the first occurrence of the part and remove only that one
      final index = _tempParts.indexWhere((p) => p['id'] == part['id']);
      if (index != -1) {
        _tempParts.removeAt(index);
      }
    });
  }

  void _confirmParts() async {
    // Save the temporary parts to the task details
    widget.task.details['parts'] = List.from(_tempParts);

    // Also save to database to ensure persistence
    try {
      final DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.updateTaskDetails(widget.task.title, {
        'parts': List.from(_tempParts),
      });
      print('DEBUG: Parts saved to database successfully');
    } catch (e) {
      print('DEBUG: Error saving parts to database: $e');
    }

    Navigator.pop(context, true); // Return true to indicate successful save
  }

  List<Map<String, dynamic>> _getAssignedParts() {
    try {
      final List<dynamic> raw = List<dynamic>.from(
        widget.task.details['parts'] ?? const [],
      );
      return raw
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
