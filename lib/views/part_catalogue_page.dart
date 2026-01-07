import 'package:flutter/material.dart';
import '../models/task.dart';

class PartCataloguePage extends StatefulWidget {
  final Task task;
  final Map<String, dynamic> category;

  const PartCataloguePage({
    super.key,
    required this.task,
    required this.category,
  });

  @override
  State<PartCataloguePage> createState() => _PartCataloguePageState();
}

class _PartCataloguePageState extends State<PartCataloguePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredParts = [];
  Map<String, dynamic>? _selectedPart;

  late List<Map<String, dynamic>> _parts;

  @override
  void initState() {
    super.initState();
    _initializeParts();
    _filteredParts = List.from(_parts);
    _searchController.addListener(_filterParts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeParts() {
    switch (widget.category['id']) {
      case 'lights':
        _parts = [
          {
            'id': 'led_headlight_left',
            'name': 'LED Car Head Light - Left',
            'category': 'Lights',
          },
          {
            'id': 'led_headlight_right',
            'name': 'LED Car Head Light - Right',
            'category': 'Lights',
          },
          {
            'id': 'led_backlight_left',
            'name': 'LED Car Back Light - Left',
            'category': 'Lights',
          },
          {
            'id': 'led_backlight_right',
            'name': 'LED Car Back Light - Right',
            'category': 'Lights',
          },
          {'id': 'brake_light', 'name': 'Brake Light', 'category': 'Lights'},
        ];
        break;
      case 'engine':
        _parts = [
          {'id': 'spark_plug', 'name': 'Spark Plug Set', 'category': 'Engine'},
          {'id': 'air_filter', 'name': 'Air Filter', 'category': 'Engine'},
          {'id': 'oil_filter', 'name': 'Oil Filter', 'category': 'Engine'},
        ];
        break;
      case 'srs':
        _parts = [
          {'id': 'airbag_sensor', 'name': 'Airbag Sensor', 'category': 'SRS'},
          {
            'id': 'seatbelt_buckle',
            'name': 'Seatbelt Buckle',
            'category': 'SRS',
          },
        ];
        break;
      case 'dashboard':
        _parts = [
          {
            'id': 'instrument_cluster',
            'name': 'Instrument Cluster',
            'category': 'Dashboard',
          },
        ];
        break;
      default:
        _parts = [];
    }
  }

  void _filterParts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredParts = List.from(_parts);
      } else {
        _filteredParts =
            _parts
                .where(
                  (part) =>
                      part['name'].toString().toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildPartsList()],
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
            widget.category['name'],
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPartsList() {
    return Column(
      children:
          _filteredParts.map((part) {
            final isSelected = _selectedPart?['id'] == part['id'];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _selectPart(part),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.green[50] : Colors.white,
                  foregroundColor: Colors.grey[800],
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    // Part image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: _getPartImage(part['id']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? Colors.green[700]
                                      : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
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
          onPressed: _selectedPart != null ? _addPart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedPart != null
                    ? const Color(0xFF00C853)
                    : Colors.grey[300],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add Part'),
        ),
      ),
    );
  }

  void _selectPart(Map<String, dynamic> part) {
    setState(() {
      _selectedPart = part;
    });
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
          child: Icon(Icons.build, size: 20, color: Colors.grey[600]),
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
          child: Icon(Icons.build, size: 20, color: Colors.grey[600]),
        );
      },
    );
  }

  void _addPart() async {
    if (_selectedPart == null) return;

    final newPart = {
      ..._selectedPart!,
      'assignedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (!mounted) return;

    // Show success message briefly, then navigate back to PartAssignmentPage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newPart['name']} added to parts list'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 100.0, left: 16.0, right: 16.0),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Pop back to PartCategoriesPage with the part data
    Navigator.pop(context, newPart);
  }
}
