import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/task.dart';
import '../database/database_helper.dart';
import 'job_details_page.dart';

class SignOffPage extends StatefulWidget {
  final Task task;

  const SignOffPage({super.key, required this.task});

  @override
  State<SignOffPage> createState() => _SignOffPageState();
}

class _SignOffPageState extends State<SignOffPage> {
  final TextEditingController _detailsController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<Offset?> _signaturePoints = <Offset?>[];
  bool _hasSignature = false;
  Size? _signatureSourceSize;
  Task? _refreshedTask;

  @override
  void initState() {
    super.initState();
    _refreshTaskData();
  }

  Future<void> _refreshTaskData() async {
    try {
      final refreshedTask = await _databaseHelper.getTaskByTitle(
        widget.task.title,
      );
      if (refreshedTask != null) {
        setState(() {
          _refreshedTask = refreshedTask;
        });
      } else {
        print('DEBUG: No refreshed task found');
      }
    } catch (e) {
      print('Error refreshing task data: $e');
    }
  }

  Task get _currentTask => _refreshedTask ?? widget.task;

  @override
  void dispose() {
    _detailsController.dispose();
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
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    _buildPartsSection(),
                    const SizedBox(height: 24),
                    _buildImageReviewSection(),
                    const SizedBox(height: 24),
                    _buildSignOffArea(),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Sign-off',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Time used: ${_currentTask.formattedTime}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Issue Reported
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Reported',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentTask.issueReported.isEmpty
                          ? _currentTask.description
                          : _currentTask.issueReported,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Requested Service
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested Service',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (_currentTask.requestedServices.isEmpty
                                  ? const <String>[]
                                  : _currentTask.requestedServices)
                              .map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(
                                        child: Text(
                                          s,
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
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => JobDetailsPage(
                              task: _currentTask,
                              showActions: false,
                            ),
                      ),
                    );
                  },
                  child: const Text('View More'),
                ),
              ),
            ],
          ),
        ),
        // Removed additional notes section per request
      ],
    );
  }

  Widget _buildPartsSection() {
    final parts = _getPartsList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parts Assigned:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (parts.isEmpty)
                Column(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No parts assigned',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      parts
                          .map(
                            (part) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(
                                      part['name'] as String,
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
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getPartsList() {
    try {
      final List<dynamic> raw = List<dynamic>.from(
        _currentTask.details['parts'] ?? const [],
      );

      final parts =
          raw
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();

      return parts;
    } catch (e) {
      print('DEBUG: Error getting parts: $e');
      return [];
    }
  }

  Widget _buildImageReviewSection() {
    final photos = _getAllPhotosSorted();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image review:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        if (photos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
              ],
            ),
          )
        else
          Column(
            children:
                photos
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
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
                                child: Image.file(
                                  File(p['path'] as String),
                                  width: double.infinity,
                                  fit: BoxFit.contain,
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
                    .toList(),
          ),
      ],
    );
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
        return bTs.compareTo(aTs);
      });
      return photos;
    } catch (_) {
      return [];
    }
  }

  Widget _buildSignOffArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Sign-off area',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _hasSignature
                        ? CustomPaint(
                          painter: _SignaturePainter(
                            List<Offset?>.from(_signaturePoints),
                            sourceSize: _signatureSourceSize,
                          ),
                          child: Container(),
                        )
                        : Center(
                          child: Text(
                            'No signature yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _showSignaturePadDialog,
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
                  child: Text(_hasSignature ? 'Re-sign' : 'Add Signature'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showSignaturePadDialog() async {
    // Get the actual width of the sign-off area to match exactly
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogPadding = 48.0; // Dialog horizontal padding (24px each side)
    final dialogMargins = 32.0; // Dialog margins
    final signOffAreaWidth = screenWidth - dialogPadding - dialogMargins;
    final Size dialogSize = Size(signOffAreaWidth, 200);
    List<Offset?> tempPoints = <Offset?>[];
    if (_signaturePoints.isNotEmpty && _signatureSourceSize != null) {
      // Scale existing points from saved source size to dialog size
      final double sx = dialogSize.width / _signatureSourceSize!.width;
      final double sy = dialogSize.height / _signatureSourceSize!.height;
      for (final p in _signaturePoints) {
        if (p == null) {
          tempPoints.add(null);
        } else {
          tempPoints.add(Offset(p.dx * sx, p.dy * sy));
        }
      }
    }
    final result = await showDialog<List<Offset?>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Sign here'),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: dialogSize.width,
                      height: dialogSize.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: GestureDetector(
                        onPanStart: (details) {
                          // Only allow starting signature within the white area bounds
                          final localPosition = details.localPosition;
                          if (localPosition.dx >= 0 &&
                              localPosition.dx <= dialogSize.width &&
                              localPosition.dy >= 0 &&
                              localPosition.dy <= dialogSize.height) {
                            tempPoints.add(localPosition);
                            setDialogState(() {});
                          }
                        },
                        onPanUpdate: (details) {
                          // Only allow signing within the white area bounds
                          final localPosition = details.localPosition;
                          if (localPosition.dx >= 0 &&
                              localPosition.dx <= dialogSize.width &&
                              localPosition.dy >= 0 &&
                              localPosition.dy <= dialogSize.height) {
                            tempPoints.add(localPosition);
                            setDialogState(() {});
                          }
                        },
                        onPanEnd: (_) {
                          tempPoints.add(null);
                          setDialogState(() {});
                        },
                        child: ClipRect(
                          child: CustomPaint(
                            painter: _SignaturePainter(
                              List<Offset?>.from(tempPoints),
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign within the white area above',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear and redraw immediately
                tempPoints.clear();
                (context as Element).markNeedsBuild();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final hasStrokes = tempPoints.any((p) => p != null);
                if (!hasStrokes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please sign before saving.')),
                  );
                  return;
                }
                Navigator.pop(context, List<Offset?>.from(tempPoints));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _signaturePoints
          ..clear()
          ..addAll(result);
        _hasSignature = true;
        _signatureSourceSize = dialogSize;
      });
    } else {
      setState(() {});
    }
  }

  // Removed text signature dialog; replaced with hand-drawn signature area

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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _confirmSignOff();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOff() async {
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your signature before confirming.'),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(bottom: 100.0, left: 16.0, right: 16.0),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Persist signature to task details (as normalized points)
    final List<List<double>?> serialized =
        _signaturePoints
            .map((p) => p == null ? null : <double>[p.dx, p.dy])
            .toList();
    if (_signatureSourceSize != null) {
      await _databaseHelper.saveTaskSignature(
        _currentTask.title,
        serialized,
        _signatureSourceSize!.width.toInt(),
        _signatureSourceSize!.height.toInt(),
      );
      // also reflect in-memory for any immediate consumers
      _currentTask.details['signature'] = {
        'points': serialized,
        'sourceWidth': _signatureSourceSize!.width.toInt(),
        'sourceHeight': _signatureSourceSize!.height.toInt(),
      };
    }

    // Update task status to completed
    _currentTask.updateStatus(TaskStatus.completed);

    // Save to database
    await _databaseHelper.updateTaskStatus(
      _currentTask.title,
      TaskStatus.completed,
    );

    // Show success message
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${_currentTask.title}" successfully signed off!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to dashboard and trigger refresh
    Navigator.pop(context, true);
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Size? sourceSize;
  _SignaturePainter(this.points, {this.sourceSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;
    final bool scale =
        sourceSize != null && sourceSize!.width > 0 && sourceSize!.height > 0;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        Offset a = p1;
        Offset b = p2;
        if (scale) {
          final sx = size.width / sourceSize!.width;
          final sy = size.height / sourceSize!.height;
          a = Offset(p1.dx * sx, p1.dy * sy);
          b = Offset(p2.dx * sx, p2.dy * sy);
        }
        canvas.drawLine(a, b, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) =>
      !listEquals(oldDelegate.points, points) ||
      oldDelegate.sourceSize != sourceSize;
}
