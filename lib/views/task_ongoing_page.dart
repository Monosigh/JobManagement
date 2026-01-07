import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import 'dart:io';
import '../database/database_helper.dart';
import 'job_details_page.dart';
import 'photo_capture_page.dart';
import 'part_assignment_page.dart';
import '../widgets/confirmation_dialog.dart';

class TaskOngoingPage extends StatefulWidget {
  final Task task;

  const TaskOngoingPage({super.key, required this.task});

  @override
  State<TaskOngoingPage> createState() => _TaskOngoingPageState();
}

class _TaskOngoingPageState extends State<TaskOngoingPage> {
  late Timer _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    // If task is on hold, continue from previous time
    if (widget.task.status == TaskStatus.onHold) {
      // For on-hold tasks, we want to show the total accumulated time
      // but the local timer variables should only track the current session
      // Reset local timer variables to 0 for the new session
      _hours = 0;
      _minutes = 0;
      _seconds = 0;

      // Start the timer for the new session
      widget.task.startTimer();
    } else {
      // Start fresh timer for new tasks
      widget.task.startTimer();
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        if (_seconds >= 60) {
          _seconds = 0;
          _minutes++;
          if (_minutes >= 60) {
            _minutes = 0;
            _hours++;
          }
        }
      });
    });
  }

  int _getTotalHours() {
    int totalSeconds =
        widget.task.totalTimeSeconds + _hours * 3600 + _minutes * 60 + _seconds;
    return totalSeconds ~/ 3600;
  }

  int _getTotalMinutes() {
    int totalSeconds =
        widget.task.totalTimeSeconds + _hours * 3600 + _minutes * 60 + _seconds;
    return (totalSeconds % 3600) ~/ 60;
  }

  int _getTotalSeconds() {
    int totalSeconds =
        widget.task.totalTimeSeconds + _hours * 3600 + _minutes * 60 + _seconds;
    return totalSeconds % 60;
  }

  void _putTaskOnHold() async {
    // Calculate current session time
    int currentSessionTime = _hours * 3600 + _minutes * 60 + _seconds;

    // Add current session time to total time
    widget.task.addTime(currentSessionTime);

    // Update task status to on hold
    widget.task.updateStatus(TaskStatus.onHold);

    // Save to database
    await _databaseHelper.updateTaskStatus(
      widget.task.title,
      TaskStatus.onHold,
    );
    await _databaseHelper.updateTaskTime(
      widget.task.title,
      widget.task.totalTimeSeconds,
      widget.task.lastStartTime,
    );

    // Cancel timer
    _timer.cancel();

    // Check if widget is still mounted before using context
    if (!mounted) return;

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task "${widget.task.title}" put on hold. Time: ${widget.task.formattedTime}',
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 100.0, left: 16.0, right: 16.0),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate back to dashboard (pop TaskOngoing and JobDetails)
    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  void _completeTask() async {
    // Calculate current session time
    int currentSessionTime = _hours * 3600 + _minutes * 60 + _seconds;

    // Add current session time to total time
    widget.task.addTime(currentSessionTime);

    // Update task status to wait for sign off
    widget.task.updateStatus(TaskStatus.waitForSignOff);

    // Save to database
    await _databaseHelper.updateTaskStatus(
      widget.task.title,
      TaskStatus.waitForSignOff,
    );
    await _databaseHelper.updateTaskTime(
      widget.task.title,
      widget.task.totalTimeSeconds,
      widget.task.lastStartTime,
    );

    // Cancel timer
    _timer.cancel();

    // Check if widget is still mounted before using context
    if (!mounted) return;

    // Show congratulations dialog
    _showCongratulationsDialog();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showOnHoldConfirmation();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
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
                      _buildJobSummary(),
                      const SizedBox(height: 24),
                      _buildTimerSection(),
                      const SizedBox(height: 24),
                      _buildAssignPartsSection(),
                      const SizedBox(height: 24),
                      _buildPhotoCaptureSection(),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
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
          Expanded(
            child: Text(
              'Task Ongoing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSummary() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(12),
            child: _buildSummaryItem(
              'Issue Reported',
              widget.task.issueReported.isEmpty
                  ? widget.task.description
                  : widget.task.issueReported,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(12),
            child: _buildSummaryItem(
              'Requested Service',
              widget.task.requestedServices.isEmpty
                  ? const []
                  : widget.task.requestedServices,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => JobDetailsPage(
                          task: widget.task,
                          showActions: false,
                        ),
                  ),
                );
              },
              child: Text(
                'View More',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        if (content is String)
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[800]))
        else if (content is List<String>)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                content
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerUnit(
              _getTotalHours().toString().padLeft(2, '0'),
              'Hours',
            ),
            const SizedBox(width: 8),
            Text(
              ' : ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            _buildTimerUnit(
              _getTotalMinutes().toString().padLeft(2, '0'),
              'Minutes',
            ),
            const SizedBox(width: 8),
            Text(
              ' : ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            _buildTimerUnit(
              _getTotalSeconds().toString().padLeft(2, '0'),
              'Seconds',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildTimerUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAssignPartsSection() {
    final parts = _getAssignedParts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assign parts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartAssignmentPage(task: widget.task),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Parts updated'),
                      margin: const EdgeInsets.only(
                        bottom: 100.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Parts'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (parts.isEmpty)
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
                  'No parts added',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          Column(children: parts.map((part) => _buildPartItem(part)).toList()),
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
            onPressed: () => _showDeletePartConfirmation(part),
            icon: Icon(Icons.delete, color: Colors.red[400]),
            tooltip: 'Delete part',
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

  Widget _buildPhotoCaptureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Capture',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoCapturePage(task: widget.task),
                  ),
                );
                if (result == true && mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Photo added to task'),
                      margin: const EdgeInsets.only(
                        bottom: 100.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Image'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildPhotosListOrPlaceholder(),
      ],
    );
  }

  List<Widget> _buildPhotosListOrPlaceholder() {
    final photos = _getAllPhotosSorted();
    if (photos.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No image added',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ];
    }

    return photos
        .map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo section with rounded top corners
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        Image.file(
                          File(p['path'] as String),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        // Delete button (top-left)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: InkWell(
                            onTap: () => _showDeletePhotoConfirmation(p),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        // Edit button (top-right)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () => _editPhoto(p),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notes section with padding and bottom rounded corners
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Text(
                      (p['note'] as String?)?.isNotEmpty == true
                          ? p['note'] as String
                          : 'No notes added',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> _getAllPhotosSorted() {
    try {
      final List<dynamic> raw = List<dynamic>.from(
        widget.task.details['photos'] ?? const [],
      );
      final List<Map<String, dynamic>> photos =
          raw
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
      photos.sort((a, b) {
        final int aTs = (a['createdAt'] ?? 0) as int;
        final int bTs = (b['createdAt'] ?? 0) as int;
        return bTs.compareTo(aTs); // newest first
      });
      return photos;
    } catch (_) {
      return [];
    }
  }

  Widget _buildBottomButtons() {
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showOnHoldConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pause, size: 20),
                  const SizedBox(width: 8),
                  Text('On Hold'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showCompleteTaskConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  Text('Complete'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteTaskConfirmation() {
    showConfirmationDialog(
      context: context,
      title: 'Are You Sure?',
      message: 'The task will be marked as completed and ready for sign-off.',
      confirmText: 'Complete',
      cancelText: 'Continue',
      icon: Icons.check_circle,
      confirmColor: Colors.green,
      cancelColor: Colors.red,
      iconColor: Colors.green,
      onConfirm: _completeTask,
    );
  }

  void _showOnHoldConfirmation() {
    showConfirmationDialog(
      context: context,
      title: 'Put On Hold?',
      message:
          'The task will be paused. The current timer will be saved and you can continue later.',
      confirmText: 'Pause',
      cancelText: 'Continue',
      icon: Icons.pause_circle,
      confirmColor: Colors.orange,
      cancelColor: Colors.red,
      iconColor: Colors.orange,
      onConfirm: _putTaskOnHold,
    );
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
              const SizedBox(height: 16),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Task "${widget.task.title}" has been completed successfully!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Total time: ${widget.task.formattedTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              const Text(
                'The task is now ready for sign-off.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Return to dashboard (pop TaskOngoing and JobDetails)
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPhoto(Map<String, dynamic> photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PhotoCapturePage(task: widget.task, photoToEdit: photo),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo updated')));
      }
    });
  }

  void _showDeletePhotoConfirmation(Map<String, dynamic> photo) {
    showConfirmationDialog(
      context: context,
      title: 'Delete Photo?',
      message: 'This photo will be permanently removed from the task.',
      confirmText: 'Delete',
      cancelText: 'Keep',
      icon: Icons.delete_forever,
      confirmColor: Colors.red,
      cancelColor: Colors.grey,
      iconColor: Colors.red,
      onConfirm: () => _deletePhoto(photo),
    );
  }

  void _deletePhoto(Map<String, dynamic> photo) async {
    try {
      // Get the original photos list from task details (not sorted)
      final List<dynamic> currentPhotos = List<dynamic>.from(
        widget.task.details['photos'] ?? const [],
      );

      // Find the photo by path (more reliable than index comparison)
      final int photoIndex = currentPhotos.indexWhere(
        (p) => p is Map<String, dynamic> && p['path'] == photo['path'],
      );

      if (photoIndex != -1) {
        // Remove the photo from the original list
        currentPhotos.removeAt(photoIndex);

        // Update the task details with the modified list
        widget.task.details['photos'] = currentPhotos;

        // Update the database
        await _databaseHelper.updateTaskDetails(
          widget.task.title,
          widget.task.details,
        );

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo not found'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error deleting photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeletePartConfirmation(Map<String, dynamic> part) {
    showConfirmationDialog(
      context: context,
      title: 'Remove Part?',
      message: 'This part will be removed from the task.',
      confirmText: 'Remove',
      cancelText: 'Keep',
      icon: Icons.remove_circle,
      confirmColor: Colors.red,
      cancelColor: Colors.grey,
      iconColor: Colors.red,
      onConfirm: () => _deletePart(part),
    );
  }

  void _deletePart(Map<String, dynamic> part) async {
    try {
      // Get the current parts list from the task details
      final List<dynamic> currentParts = List<dynamic>.from(
        widget.task.details['parts'] ?? const [],
      );

      // Find and remove the part by ID (more reliable than index)
      final index = currentParts.indexWhere(
        (p) => p is Map<String, dynamic> && p['id'] == part['id'],
      );

      if (index != -1) {
        final deletedPart = currentParts[index];
        print('DEBUG: Deleting part: ${deletedPart['name']}');

        currentParts.removeAt(index);

        // Update the task details with the new parts list
        widget.task.details['parts'] = currentParts;

        // Update the database
        await _databaseHelper.updateTaskDetails(
          widget.task.title,
          widget.task.details,
        );

        print('DEBUG: Database updated successfully');

        // Refresh the UI
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${part['name']} deleted successfully'),
            margin: const EdgeInsets.only(
              bottom: 100.0,
              left: 16.0,
              right: 16.0,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print('DEBUG: Part not found in the list');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Part not found'),
            margin: const EdgeInsets.only(
              bottom: 100.0,
              left: 16.0,
              right: 16.0,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error deleting part: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting part: $e'),
          margin: const EdgeInsets.only(bottom: 100.0, left: 16.0, right: 16.0),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
