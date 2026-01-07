import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../services/user_data_service.dart';
import '../services/user_session_service.dart';
import 'job_details_page.dart';
import 'sign_off_page.dart';
import 'completed_view_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPeriod = 'All Time';
  String selectedFilter = 'All Tasks';
  bool isFilterDropdownOpen = false;
  List<Task> tasks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = true;
  String _userName = 'Andre';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserName();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all tasks from database for current user
      final currentUser = UserSessionService().currentUser;
      print('DEBUG: Dashboard loading tasks for user: $currentUser');
      final loadedTasks = await _databaseHelper.getAllTasks(user: currentUser);
      setState(() {
        tasks = loadedTasks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    final userName = await UserDataService.getUserName();
    setState(() {
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSummarySection(),
              const SizedBox(height: 20),
              _buildTasksSection(),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildTaskList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greetingText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              DateFormat('d MMM, yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            // Refresh user name when returning from settings
            _loadUserName();
          },
          child: Icon(
            Icons.settings_outlined,
            size: 24,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                _showPeriodDropdown(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedPeriod,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Assigned tasks',
                _getAssignedTaskCount().toString(),
                Colors.blue[50]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Completed tasks',
                _getCompletedTaskCount().toString(),
                Colors.green[50]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, Color backgroundColor) {
    return Container(
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
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${selectedPeriod} tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Main dropdown button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFilterDropdownOpen = !isFilterDropdownOpen;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedFilter,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Icon(
                        isFilterDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              // Dropdown options
              if (isFilterDropdownOpen) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    children: [
                      _buildFilterOption('All Tasks'),
                      _buildFilterOption('Assigned'),
                      _buildFilterOption('On Hold'),
                      _buildFilterOption('Wait for Sign Off'),
                      _buildFilterOption('Completed'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = option;
          isFilterDropdownOpen = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectedFilter == option ? Colors.grey[50] : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            color:
                selectedFilter == option ? Colors.blue[600] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    // Filter tasks based on selected filter
    List<Task> filteredTasks = _getFilteredTasks();

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(filteredTasks[index]);
      },
    );
  }

  List<Task> _getFilteredTasks() {
    List<Task> filteredTasks = tasks;

    // Filter by status
    switch (selectedFilter) {
      case 'All Tasks':
        break; // No status filtering
      case 'Assigned':
        filteredTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.assigned)
                .toList();
        break;
      case 'On Hold':
        filteredTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.onHold)
                .toList();
        break;
      case 'Wait for Sign Off':
        filteredTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.waitForSignOff)
                .toList();
        break;
      case 'Completed':
        filteredTasks =
            filteredTasks
                .where((task) => task.status == TaskStatus.completed)
                .toList();
        break;
    }

    // Filter by period
    filteredTasks = _tasksForSelectedPeriod(filteredTasks);

    // Sort by date (oldest first)
    filteredTasks.sort(
      (a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)),
    );

    return filteredTasks;
  }

  bool _isToday(String dateStr) {
    final date = _parseDate(dateStr);
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isThisWeek(String dateStr) {
    final date = _parseDate(dateStr);
    final now = DateTime.now();
    final int currentWeekday = now.weekday; // 1 (Mon) - 7 (Sun)
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: currentWeekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final onlyDate = DateTime(date.year, date.month, date.day);
    return !onlyDate.isBefore(startOfWeek) && !onlyDate.isAfter(endOfWeek);
  }

  DateTime _parseDate(String dateStr) {
    // Expecting formats like 'October 15, 2023'
    try {
      return DateFormat('MMMM d, yyyy').parse(dateStr);
    } catch (_) {
      // Fallback: try more formats if needed
      try {
        return DateFormat('d/M/yyyy').parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  int _getAssignedTaskCount() {
    final periodTasks = _tasksForSelectedPeriod(tasks);
    return periodTasks
        .where(
          (task) =>
              task.status == TaskStatus.assigned ||
              task.status == TaskStatus.onHold ||
              task.status == TaskStatus.waitForSignOff,
        )
        .length;
  }

  int _getCompletedTaskCount() {
    final periodTasks = _tasksForSelectedPeriod(tasks);
    return periodTasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
  }

  List<Task> _tasksForSelectedPeriod(List<Task> input) {
    switch (selectedPeriod) {
      case 'Today':
        return input.where((t) => _isToday(t.date)).toList();
      case 'This Week':
        return input.where((t) => _isThisWeek(t.date)).toList();
      default:
        return input;
    }
  }

  String _greetingText() {
    return 'Hi, $_userName!';
  }

  Widget _buildTaskCard(Task task) {
    Color buttonColor;
    String buttonText;

    switch (task.status) {
      case TaskStatus.assigned:
        buttonColor = Colors.purple[300]!;
        buttonText = 'View';
        break;
      case TaskStatus.waitForSignOff:
        buttonColor = Colors.green;
        buttonText = 'Sign Off';
        break;
      case TaskStatus.onHold:
        buttonColor = Colors.orange[300]!;
        buttonText = 'On Hold';
        break;
      case TaskStatus.completed:
        buttonColor = Colors.grey[400]!;
        buttonText = 'Completed';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                task.vehicleInfo,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  if (task.totalTimeSeconds > 0 ||
                      task.status == TaskStatus.onHold)
                    const SizedBox(height: 4),
                  if (task.totalTimeSeconds > 0 ||
                      task.status == TaskStatus.onHold)
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          task.formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  if (task.status == TaskStatus.assigned) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsPage(task: task),
                      ),
                    );
                    if (result == true) {
                      _loadTasks();
                    }
                  } else if (task.status == TaskStatus.onHold) {
                    // Continue on-hold task
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsPage(task: task),
                      ),
                    );
                    // Refresh tasks if returning from job details page
                    if (result == true) {
                      _loadTasks();
                    }
                  } else if (task.status == TaskStatus.waitForSignOff) {
                    // Navigate to sign-off page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignOffPage(task: task),
                      ),
                    );
                    // Refresh tasks if returning from sign-off page
                    if (result == true) {
                      _loadTasks();
                    }
                  } else if (task.status == TaskStatus.completed) {
                    // View-only completed page
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompletedViewPage(task: task),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    task.status == TaskStatus.onHold ? 'Continue' : buttonText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPeriodDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Time'),
                onTap: () {
                  setState(() {
                    selectedPeriod = 'All Time';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Today'),
                onTap: () {
                  setState(() {
                    selectedPeriod = 'Today';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('This Week'),
                onTap: () {
                  setState(() {
                    selectedPeriod = 'This Week';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
