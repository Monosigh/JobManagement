enum TaskStatus { assigned, onHold, waitForSignOff, completed }

class Task {
  // Basic model representing a workshop job/task
  final String title;
  final String description;
  final String vehicleInfo; // Can be customer/vehicle text or project area
  final String date; // For simplicity, keep as display string for now
  TaskStatus status; // Using enum for type safety
  int totalTimeSeconds; // Total time spent on task in seconds
  int lastStartTime; // Timestamp when timer was last started
  Map<String, dynamic> details; // Flexible, data-driven details per task

  Task({
    required this.title,
    required this.description,
    required this.vehicleInfo,
    required this.date,
    required this.status,
    this.totalTimeSeconds = 0,
    this.lastStartTime = 0,
    Map<String, dynamic>? details,
  }) : details = details ?? {};

  // Helper method to get display text for status
  String get statusDisplayText {
    switch (status) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.waitForSignOff:
        return 'Wait for Sign Off';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  // Common getters from details map with sensible defaults
  String get customerEmail => details['customerEmail'] ?? '';
  String get customerContact => details['customerContact'] ?? '';

  String get registrationNumber => details['registrationNumber'] ?? '';
  String get vehicleModel => details['vehicleModel'] ?? '';
  String get yearOfManufacture => details['yearOfManufacture'] ?? '';
  String get vin => details['vin'] ?? '';
  String get engineNumber => details['engineNumber'] ?? '';
  String get mileage => details['mileage'] ?? '';

  String get jobId => details['jobId'] ?? '';
  String get dateCreated => details['dateCreated'] ?? '';
  String get jobStatus => details['jobStatus'] ?? '';
  String get issueReported => details['issueReported'] ?? description;
  List<String> get requestedServices =>
      List<String>.from(details['requestedServices'] ?? const []);

  String get previousJobsPerformed => details['previousJobsPerformed'] ?? '';
  String get previousPartsReplaced => details['previousPartsReplaced'] ?? '';

  // Method to update status
  void updateStatus(TaskStatus newStatus) {
    status = newStatus;
  }

  // Method to add time to total
  void addTime(int seconds) {
    totalTimeSeconds += seconds;
  }

  // Method to start timer
  void startTimer() {
    lastStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  // Method to pause timer and add elapsed time
  void pauseTimer() {
    if (lastStartTime > 0) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      int elapsedSeconds = ((currentTime - lastStartTime) / 1000).round();
      totalTimeSeconds += elapsedSeconds;
      lastStartTime = 0;
    }
  }

  // Method to get formatted time string
  String get formattedTime {
    int hours = totalTimeSeconds ~/ 3600;
    int minutes = (totalTimeSeconds % 3600) ~/ 60;
    int seconds = totalTimeSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Method to get current elapsed time if timer is running
  int get currentElapsedSeconds {
    if (lastStartTime > 0) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      return ((currentTime - lastStartTime) / 1000).round();
    }
    return 0;
  }

  // Method to get total time including current session
  int get totalTimeIncludingCurrent {
    return totalTimeSeconds + currentElapsedSeconds;
  }
}
