import 'dart:io';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'job_details_page.dart';

class CompletedViewPage extends StatelessWidget {
  final Task task;

  const CompletedViewPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildPartsSection(),
                    const SizedBox(height: 16),
                    _buildImagesSection(),
                    const SizedBox(height: 16),
                    _buildSignatureSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Text(
              'Completed Task',
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

  Widget _buildSummaryCard() {
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
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Time used: ${task.formattedTime}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Issue Reported (grey shaded container)
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
                _label('Issue Reported'),
                const SizedBox(height: 6),
                Text(
                  task.issueReported.isEmpty
                      ? task.description
                      : task.issueReported,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Requested Service (grey shaded container)
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
                _label('Requested Service'),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      (task.requestedServices.isEmpty
                              ? const <String>[]
                              : task.requestedServices)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 8),
          Builder(
            builder:
                (innerContext) => Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        innerContext,
                        MaterialPageRoute(
                          builder:
                              (context) => JobDetailsPage(
                                task: task,
                                showActions: false,
                              ),
                        ),
                      );
                    },
                    child: const Text('View More'),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsSection() {
    final parts = List<Map<String, dynamic>>.from(
      (task.details['parts'] ?? const [])
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  // Part image
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: _getPartImage(part['id']),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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

  Widget _buildImagesSection() {
    final photos = List<Map<String, dynamic>>.from(
      (task.details['photos'] ?? const [])
          .where((e) => e is Map)
          .map((e) => Map<String, dynamic>.from(e as Map)),
    );

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

  Widget _buildSignatureSection() {
    final sig = task.details['signature'];
    if (sig == null || sig is! Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signature:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
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
            child: Text(
              'No signature',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      );
    }

    final List<dynamic> raw = List<dynamic>.from(sig['points'] ?? const []);
    final int sw = (sig['sourceWidth'] ?? 0) as int;
    final int sh = (sig['sourceHeight'] ?? 0) as int;
    final points =
        raw
            .map<Offset?>(
              (e) =>
                  e == null
                      ? null
                      : Offset(
                        (e[0] as num).toDouble(),
                        (e[1] as num).toDouble(),
                      ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signature:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
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
          child: Padding(
            padding: const EdgeInsets.all(
              8.0,
            ), // Add margin inside the container
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _ReadonlySignaturePainter(
                  points,
                  Size(sw.toDouble(), sh.toDouble()),
                ),
                child: Container(),
              ),
            ),
          ),
        ),
      ],
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
          child: Icon(Icons.build, size: 16, color: Colors.grey[600]),
        );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if image fails to load
        return Container(
          color: Colors.grey[100],
          child: Icon(Icons.build, size: 16, color: Colors.grey[600]),
        );
      },
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    ),
  );
}

class _ReadonlySignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Size sourceSize;
  _ReadonlySignaturePainter(this.points, this.sourceSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;
    final bool scale = sourceSize.width > 0 && sourceSize.height > 0;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        Offset a = p1;
        Offset b = p2;
        if (scale) {
          final sx = size.width / sourceSize.width;
          final sy = size.height / sourceSize.height;
          a = Offset(p1.dx * sx, p1.dy * sy);
          b = Offset(p2.dx * sx, p2.dy * sy);
        }
        canvas.drawLine(a, b, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReadonlySignaturePainter oldDelegate) => false;
}
