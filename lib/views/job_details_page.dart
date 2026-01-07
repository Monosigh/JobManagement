import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_ongoing_page.dart';
import '../widgets/confirmation_dialog.dart';

class JobDetailsPage extends StatefulWidget {
  final Task task;
  final bool showActions;

  const JobDetailsPage({
    super.key,
    required this.task,
    this.showActions = true,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
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
                    _buildCustomerDetails(),
                    const SizedBox(height: 16),
                    _buildVehicleDetails(),
                    const SizedBox(height: 16),
                    _buildJobDescription(),
                    const SizedBox(height: 16),
                    _buildServicesHistory(),
                    if (widget.showActions)
                      const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
            if (widget.showActions) _buildBottomButtons(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'ABC Electrical',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Email',
            widget.task.customerEmail.isEmpty ? '-' : widget.task.customerEmail,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Contact',
            widget.task.customerContact.isEmpty
                ? '-'
                : widget.task.customerContact,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Vehicle Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Registration Number',
            widget.task.registrationNumber.isEmpty
                ? '-'
                : widget.task.registrationNumber,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Model',
            widget.task.vehicleModel.isEmpty ? '-' : widget.task.vehicleModel,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Year of Manufacture',
            widget.task.yearOfManufacture.isEmpty
                ? '-'
                : widget.task.yearOfManufacture,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'VIN',
            widget.task.vin.isEmpty ? '-' : widget.task.vin,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Engine Number',
            widget.task.engineNumber.isEmpty ? '-' : widget.task.engineNumber,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Mileage',
            widget.task.mileage.isEmpty ? '-' : widget.task.mileage,
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Job ID',
            widget.task.jobId.isEmpty ? '-' : widget.task.jobId,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Date Created',
            widget.task.dateCreated.isEmpty ? '-' : widget.task.dateCreated,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            'Job Status',
            widget.task.jobStatus.isEmpty
                ? widget.task.statusDisplayText
                : widget.task.jobStatus,
          ),
          const SizedBox(height: 12),
          _buildTextArea(
            'Issue Reported',
            widget.task.issueReported.isEmpty
                ? widget.task.description
                : widget.task.issueReported,
          ),
          const SizedBox(height: 12),
          _buildBulletList(
            'Requested Service',
            widget.task.requestedServices.isEmpty
                ? const []
                : widget.task.requestedServices,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Services History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextArea(
            'Previous Jobs Performed',
            widget.task.previousJobsPerformed.isEmpty
                ? '-'
                : widget.task.previousJobsPerformed,
          ),
          const SizedBox(height: 12),
          _buildTextArea(
            'Previous Parts Replaced',
            widget.task.previousPartsReplaced.isEmpty
                ? '-'
                : widget.task.previousPartsReplaced,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
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
        ),
      ],
    );
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20),
                  const SizedBox(width: 8),
                  Text('Close'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showStartTimerConfirmation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.task.status == TaskStatus.onHold
                        ? Colors.orange
                        : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.task.status == TaskStatus.onHold
                        ? Icons.play_arrow
                        : Icons.timer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.task.status == TaskStatus.onHold
                        ? 'Continue Timer'
                        : 'Start Timer',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStartTimerConfirmation() {
    final bool isOnHold = widget.task.status == TaskStatus.onHold;
    final String title = isOnHold ? 'Continue Timer?' : 'Start Timer?';
    final String message =
        isOnHold
            ? 'The timer will resume from where it was paused.'
            : 'The timer will begin now.';
    final String buttonText = isOnHold ? 'Continue' : 'Start';
    final Color buttonColor = isOnHold ? Colors.orange : Colors.green;
    final IconData icon = isOnHold ? Icons.play_circle : Icons.timer;

    showConfirmationDialog(
      context: context,
      title: title,
      message: message,
      confirmText: buttonText,
      cancelText: 'Not Now',
      icon: icon,
      confirmColor: buttonColor,
      cancelColor: Colors.red,
      iconColor: buttonColor,
      onConfirm: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskOngoingPage(task: widget.task),
          ),
        );
      },
    );
  }
}
