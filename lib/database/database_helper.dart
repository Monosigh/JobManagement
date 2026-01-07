import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'job_management.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        vehicleInfo TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        totalTimeSeconds INTEGER DEFAULT 0,
        lastStartTime INTEGER DEFAULT 0,
        details TEXT,
        createdAt INTEGER NOT NULL,
        user TEXT NOT NULL DEFAULT 'Admin1'
      )
    ''');

    // Create user_profile table
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL DEFAULT 'Admin1',
        name TEXT NOT NULL DEFAULT 'Andrew',
        profile_image_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Insert default user profiles
    await db.insert('user_profile', {
      'user': 'Admin1',
      'name': 'Andrew',
      'profile_image_path': null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    await db.insert('user_profile', {
      'user': 'Admin2',
      'name': 'Sam',
      'profile_image_path': null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add details column; ignore if already exists
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN details TEXT');
      } catch (_) {
        // Column might already exist; ignore
      }
    }

    if (oldVersion < 3) {
      // Add user_profile table
      try {
        await db.execute('''
          CREATE TABLE user_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL DEFAULT 'Andrew',
            profile_image_path TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Insert default user profile
        await db.insert('user_profile', {
          'name': 'Andrew',
          'profile_image_path': null,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        // Table might already exist; check if we need to insert default data
        try {
          final result = await db.query('user_profile', limit: 1);
          if (result.isEmpty) {
            // Table exists but no data, insert default
            await db.insert('user_profile', {
              'name': 'Andrew',
              'profile_image_path': null,
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            });
          }
        } catch (_) {
          // Something went wrong, ignore
        }
      }
    }

    if (oldVersion < 4) {
      // Add user column to tasks table
      try {
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN user TEXT NOT NULL DEFAULT \'Admin1\'',
        );
      } catch (_) {
        // Column might already exist; ignore
      }

      // Clean up existing data - ensure Admin2 tasks have correct user field
      try {
        await db.execute(
          'UPDATE tasks SET user = \'Admin2\' WHERE title LIKE \'Admin2%\'',
        );
        // Ensure all other tasks are set to Admin1
        await db.execute(
          'UPDATE tasks SET user = \'Admin1\' WHERE user IS NULL OR user = \'\'',
        );
      } catch (_) {
        // Ignore errors
      }
    }

    if (oldVersion < 5) {
      // Add user column to user_profile table
      try {
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN user TEXT NOT NULL DEFAULT \'Admin1\'',
        );
      } catch (_) {
        // Column might already exist; ignore
      }

      // Update existing user profile to Admin1
      try {
        await db.execute(
          'UPDATE user_profile SET user = \'Admin1\' WHERE user IS NULL OR user = \'\'',
        );

        // Insert Admin2 profile if it doesn't exist
        final admin2Exists = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM user_profile WHERE user = \'Admin2\'',
          ),
        );
        if (admin2Exists == 0) {
          await db.insert('user_profile', {
            'user': 'Admin2',
            'name': 'Sam',
            'profile_image_path': null,
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
      } catch (_) {
        // Ignore errors
      }
    }
  }

  // Insert a new task
  Future<int> insertTask(Task task, {String user = 'Admin1'}) async {
    final db = await database;
    return await db.insert('tasks', {
      'title': task.title,
      'description': task.description,
      'vehicleInfo': task.vehicleInfo,
      'date': task.date,
      'status': task.status.name,
      'totalTimeSeconds': task.totalTimeSeconds,
      'lastStartTime': task.lastStartTime,
      'details': jsonEncode(task.details),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'user': user,
    });
  }

  // Get all tasks for a specific user
  Future<List<Task>> getAllTasks({String user = 'Admin1'}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'user = ?',
      whereArgs: [user],
      orderBy: 'createdAt DESC',
    );

    // Debug logging
    print('DEBUG: Loading tasks for user: $user');
    print('DEBUG: Found ${maps.length} tasks');
    for (final map in maps) {
      print('DEBUG: Task: ${map['title']} - User: ${map['user']}');
    }

    return List.generate(maps.length, (i) {
      return Task(
        title: maps[i]['title'],
        description: maps[i]['description'],
        vehicleInfo: maps[i]['vehicleInfo'],
        date: maps[i]['date'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[i]['status'],
        ),
        totalTimeSeconds: maps[i]['totalTimeSeconds'],
        lastStartTime: maps[i]['lastStartTime'],
        details: _decodeDetails(maps[i]['details']),
      );
    });
  }

  // Get tasks by status for a specific user
  Future<List<Task>> getTasksByStatus(
    TaskStatus status, {
    String user = 'Admin1',
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ? AND user = ?',
      whereArgs: [status.name, user],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Task(
        title: maps[i]['title'],
        description: maps[i]['description'],
        vehicleInfo: maps[i]['vehicleInfo'],
        date: maps[i]['date'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[i]['status'],
        ),
        totalTimeSeconds: maps[i]['totalTimeSeconds'],
        lastStartTime: maps[i]['lastStartTime'],
        details: _decodeDetails(maps[i]['details']),
      );
    });
  }

  // Update task status
  Future<int> updateTaskStatus(String title, TaskStatus newStatus) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'status': newStatus.name},
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Update task time
  Future<int> updateTaskTime(
    String title,
    int totalTimeSeconds,
    int lastStartTime,
  ) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'totalTimeSeconds': totalTimeSeconds, 'lastStartTime': lastStartTime},
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Update task details map (merge existing with provided)
  Future<int> updateTaskDetails(
    String title,
    Map<String, dynamic> newDetails,
  ) async {
    final db = await database;
    // Fetch current details
    final existing = await getTaskByTitle(title);
    final Map<String, dynamic> current = Map<String, dynamic>.from(
      existing?.details ?? {},
    );
    current.addAll(newDetails);

    return await db.update(
      'tasks',
      {'details': jsonEncode(current)},
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Persist signature points and source size
  Future<int> saveTaskSignature(
    String title,
    List<List<double>?> points,
    int sourceWidth,
    int sourceHeight,
  ) async {
    return updateTaskDetails(title, {
      'signature': {
        'points': points,
        'sourceWidth': sourceWidth,
        'sourceHeight': sourceHeight,
      },
    });
  }

  // Delete a task
  Future<int> deleteTask(String title) async {
    final db = await database;
    return await db.delete('tasks', where: 'title = ?', whereArgs: [title]);
  }

  // Get task by title
  Future<Task?> getTaskByTitle(String title) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title = ?',
      whereArgs: [title],
    );

    if (maps.isNotEmpty) {
      return Task(
        title: maps[0]['title'],
        description: maps[0]['description'],
        vehicleInfo: maps[0]['vehicleInfo'],
        date: maps[0]['date'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[0]['status'],
        ),
        totalTimeSeconds: maps[0]['totalTimeSeconds'],
        lastStartTime: maps[0]['lastStartTime'],
        details: _decodeDetails(maps[0]['details']),
      );
    }
    return null;
  }

  Map<String, dynamic> _decodeDetails(dynamic value) {
    if (value == null) return {};
    try {
      if (value is String && value.isNotEmpty) {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return {};
  }

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    final db = await database;

    // Check if data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tasks'),
    );
    if (count! > 0) return; // Data already exists

    // Insert sample tasks for Admin1
    await insertTask(
      Task(
        title: 'Engine Overheating',
        description: 'Temperature gauge frequently rising above normal.',
        vehicleInfo: 'Honda, Civic, XYZ987',
        date: 'September 22, 2025',
        status: TaskStatus.assigned,
        details: {
          'customerEmail': 'civicowner@gmail.com',
          'customerContact': '0177777777',
          'registrationNumber': 'XYZ 987',
          'vehicleModel': 'Honda Civic',
          'yearOfManufacture': '2020',
          'vin': 'CIVICVIN2020',
          'engineNumber': 'CIV-ENG-123',
          'mileage': '45,500 km',
          'jobId': 'JOB-2025005',
          'dateCreated': '21/7/2025',
          'jobStatus': 'In Progress',
          'issueReported': 'Coolant leaking and fan not engaging properly.',
          'requestedServices': [
            'Coolant system flush',
            'Inspect radiator',
            'Check fan motor',
          ],
          'previousJobsPerformed': '2025-02-12 Oil change',
          'previousPartsReplaced': 'Coolant hose (2024-12-10)',
        },
      ),
      user: 'Admin1',
    );

    await insertTask(
      Task(
        title: 'Transmission Issue',
        description: 'Difficulty shifting gears, grinding noise in 2nd gear.',
        vehicleInfo: 'Ford, Ranger, DEF456',
        date: 'September 20, 2025',
        status: TaskStatus.waitForSignOff,
        details: {
          'customerEmail': 'ranger_driver@ford.com',
          'customerContact': '0136666666',
          'registrationNumber': 'DEF 456',
          'vehicleModel': 'Ford Ranger',
          'yearOfManufacture': '2017',
          'vin': 'RANGERVIN2017',
          'engineNumber': 'RNG-ENG-789',
          'mileage': '112,300 km',
          'jobId': 'JOB-2025006',
          'dateCreated': '22/7/2025',
          'jobStatus': 'Completed',
          'issueReported': 'Gearbox grinding in 2nd gear; delayed response.',
          'requestedServices': [
            'Transmission fluid replacement',
            'Clutch inspection',
            'Gear synchronizer check',
          ],
          'previousJobsPerformed': '2024-10-11 Major service',
          'previousPartsReplaced': 'Clutch plate (2023-03-15)',
        },
      ),
      user: 'Admin1',
    );

    await insertTask(
      Task(
        title: 'Battery & Electrical Check',
        description: 'Vehicle not starting reliably, dashboard lights dim.',
        vehicleInfo: 'Nissan, Almera, GHI321',
        date: 'September 21, 2025',
        status: TaskStatus.assigned,
        details: {
          'customerEmail': 'nissan_owner@mail.com',
          'customerContact': '0165555555',
          'registrationNumber': 'GHI 321',
          'vehicleModel': 'Nissan Almera',
          'yearOfManufacture': '2019',
          'vin': 'ALMERAVIN2019',
          'engineNumber': 'ALM-ENG-222',
          'mileage': '60,200 km',
          'jobId': 'JOB-2025007',
          'dateCreated': '23/7/2025',
          'jobStatus': 'Pending',
          'issueReported':
              'Battery weak, alternator may not be charging properly.',
          'requestedServices': [
            'Battery health test',
            'Alternator inspection',
            'Wiring check',
          ],
          'previousJobsPerformed': '2025-01-05 Battery jump-start service',
          'previousPartsReplaced': 'Spark plugs (2023-09-18)',
        },
      ),
      user: 'Admin1',
    );

    await insertTask(
      Task(
        title: 'Brake System Repair',
        description: 'Squeaking brakes and reduced stopping power.',
        vehicleInfo: 'Toyota, Camry, ABC123',
        date: 'September 22, 2025',
        status: TaskStatus.onHold,
        details: {
          'customerEmail': 'owner@toyota.com',
          'customerContact': '0128888888',
          'registrationNumber': 'ABC 123',
          'vehicleModel': 'Toyota Camry',
          'yearOfManufacture': '2018',
          'vin': 'CAMRYVIN001',
          'engineNumber': 'CAM-ENG-001',
          'mileage': '78000 km',
          'jobId': 'JOB-2025004',
          'dateCreated': '20/7/2025',
          'jobStatus': 'On Hold',
          'issueReported': 'Squeaking brakes; inspect pads and rotors.',
          'requestedServices': [
            'Inspect brake pads',
            'Inspect rotors',
            'Brake fluid check',
          ],
          'previousJobsPerformed': '2024-07-01 Minor service',
          'previousPartsReplaced': 'Front pads (2023-06-10)',
        },
      ),
      user: 'Admin1',
    );

    await insertTask(
      Task(
        title: 'Oil Change Service',
        description: 'Regular oil and filter replacement. Synthetic oil.',
        vehicleInfo: 'Honda, Civic, XYZ789',
        date: 'September 19, 2025',
        status: TaskStatus.completed,
        details: {
          'customerEmail': 'owner@honda.com',
          'customerContact': '0177777777',
          'registrationNumber': 'XYZ 789',
          'vehicleModel': 'Honda Civic',
          'yearOfManufacture': '2016',
          'vin': 'CIVICVIN987654',
          'engineNumber': 'R18-ENG-2016',
          'mileage': '105000 km',
          'jobId': 'JOB-2025005',
          'dateCreated': '18/7/2025',
          'jobStatus': 'Completed',
          'issueReported': 'Scheduled maintenance',
          'requestedServices': ['Replace oil', 'Replace oil filter'],
          'previousJobsPerformed': '2025-01-10 100,000 km service',
          'previousPartsReplaced': 'Air filter (2024-06-05)',
        },
      ),
      user: 'Admin1',
    );

    await insertTask(
      Task(
        title: 'Transmission Diagnostics',
        description: 'Transmission slipping; diagnostics required.',
        vehicleInfo: 'Ford, Focus, DEF456',
        date: 'September 21, 2025',
        status: TaskStatus.assigned,
        details: {
          'customerEmail': 'owner@ford.com',
          'customerContact': '0166666666',
          'registrationNumber': 'DEF 456',
          'vehicleModel': 'Ford Focus',
          'yearOfManufacture': '2015',
          'vin': 'FOCUSVIN123456',
          'engineNumber': 'DURATEC-20-2015',
          'mileage': '120000 km',
          'jobId': 'JOB-2025006',
          'dateCreated': '19/7/2025',
          'jobStatus': 'Assigned',
          'issueReported': 'Transmission slipping under load.',
          'requestedServices': ['OBD scan', 'Transmission fluid check'],
          'previousJobsPerformed': '2024-03-20 Major service',
          'previousPartsReplaced': 'Transmission fluid (2023-03-10)',
        },
      ),
      user: 'Admin1',
    );
  }

  // Initialize Admin2's unique tasks
  Future<void> initializeAdmin2Data() async {
    final db = await database;

    // Check if Admin2 data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE title LIKE "Admin2%"',
      ),
    );
    if (count! > 0) return; // Admin2 data already exists

    // Insert Admin2's unique tasks
    await insertTask(
      Task(
        title: 'Brake System Overhaul',
        description:
            'Complete brake pad and rotor replacement with fluid flush.',
        vehicleInfo: 'Toyota, Supra, WUM2704',
        date: 'September 22, 2025',
        status: TaskStatus.assigned,
        details: {
          'customerEmail': 'peter@gmail.com',
          'customerContact': '0123456789',
          'registrationNumber': 'WUM 2704',
          'vehicleModel': 'Toyota Supra',
          'yearOfManufacture': '2021',
          'vin': 'SUPRAVIN2021',
          'engineNumber': 'CAM-ENG-456',
          'mileage': '38,750 km',
          'jobId': 'JOB-ADMIN2-001',
          'dateCreated': '15/1/2024',
          'jobStatus': 'In Progress',
          'issueReported': 'Brake pads worn, squeaking noise when braking.',
          'requestedServices': [
            'Front brake pad replacement',
            'Rear brake pad replacement',
            'Brake fluid flush',
            'Rotor inspection',
          ],
          'previousJobsPerformed': '2023-11-20 Regular maintenance',
          'previousPartsReplaced': 'Air filter (2023-11-20)',
        },
      ),
      user: 'Admin2',
    );

    await insertTask(
      Task(
        title: 'Air Conditioning Repair',
        description: 'AC compressor replacement and refrigerant recharge.',
        vehicleInfo: 'Hyundai, Elantra, XYZ789',
        date: 'September 21, 2025',
        status: TaskStatus.onHold,
        details: {
          'customerEmail': 'elantra_driver@hyundai.com',
          'customerContact': '0198765432',
          'registrationNumber': 'XYZ 789',
          'vehicleModel': 'Hyundai Elantra',
          'yearOfManufacture': '2020',
          'vin': 'ELANTRVIN2020',
          'engineNumber': 'ELN-ENG-789',
          'mileage': '52,100 km',
          'jobId': 'JOB-ADMIN2-002',
          'dateCreated': '20/1/2024',
          'jobStatus': 'On Hold',
          'issueReported': 'AC not cooling, compressor making strange noises.',
          'requestedServices': [
            'AC compressor replacement',
            'Refrigerant recharge',
            'AC system leak test',
            'Belt inspection',
          ],
          'previousJobsPerformed': '2023-08-15 AC service',
          'previousPartsReplaced': 'AC belt (2023-08-15)',
        },
      ),
      user: 'Admin2',
    );

    await insertTask(
      Task(
        title: 'Suspension System Check',
        description: 'Shock absorber replacement and wheel alignment.',
        vehicleInfo: 'Mazda, CX-5, DEF456',
        date: 'September 20, 2025',
        status: TaskStatus.completed,
        details: {
          'customerEmail': 'cx5_owner@mazda.com',
          'customerContact': '0156789012',
          'registrationNumber': 'DEF 456',
          'vehicleModel': 'Mazda CX-5',
          'yearOfManufacture': '2019',
          'vin': 'CX5VIN2019',
          'engineNumber': 'CX5-ENG-321',
          'mileage': '67,800 km',
          'jobId': 'JOB-ADMIN2-003',
          'dateCreated': '5/2/2024',
          'jobStatus': 'Completed',
          'issueReported': 'Vehicle bouncing excessively, uneven tire wear.',
          'requestedServices': [
            'Front shock absorber replacement',
            'Rear shock absorber replacement',
            'Wheel alignment',
            'Tire rotation',
          ],
          'previousJobsPerformed': '2023-12-10 Tire replacement',
          'previousPartsReplaced': 'All 4 tires (2023-12-10)',
        },
      ),
      user: 'Admin2',
    );

    await insertTask(
      Task(
        title: 'Engine Diagnostic',
        description: 'Check engine light investigation and sensor replacement.',
        vehicleInfo: 'Subaru, Impreza, GHI654',
        date: 'September 22, 2025',
        status: TaskStatus.waitForSignOff,
        details: {
          'customerEmail': 'impreza_driver@subaru.com',
          'customerContact': '0134567890',
          'registrationNumber': 'GHI 654',
          'vehicleModel': 'Subaru Impreza',
          'yearOfManufacture': '2022',
          'vin': 'IMPRZVIN2022',
          'engineNumber': 'IMP-ENG-654',
          'mileage': '25,300 km',
          'jobId': 'JOB-ADMIN2-004',
          'dateCreated': '10/2/2024',
          'jobStatus': 'Completed',
          'issueReported': 'Check engine light on, reduced fuel efficiency.',
          'requestedServices': [
            'Engine diagnostic scan',
            'O2 sensor replacement',
            'Catalytic converter inspection',
            'Fuel system cleaning',
          ],
          'previousJobsPerformed': '2023-10-05 Oil change',
          'previousPartsReplaced': 'Oil filter (2023-10-05)',
        },
      ),
      user: 'Admin2',
    );
  }

  // User Profile Methods
  Future<String> getUserName({String user = 'Admin1'}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'user_profile',
        where: 'user = ?',
        whereArgs: [user],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first['name'] as String;
      }
      return user == 'Admin2' ? 'Sam' : 'Andrew'; // Default fallback
    } catch (e) {
      // If there's an error, ensure the table exists and try again
      await ensureUserProfileExists();
      return user == 'Admin2' ? 'Sam' : 'Andrew';
    }
  }

  Future<void> setUserName(String name, {String user = 'Admin1'}) async {
    try {
      final db = await database;
      await db.update(
        'user_profile',
        {'name': name, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'user = ?',
        whereArgs: [user],
      );
    } catch (e) {
      // If there's an error, ensure the table exists and try again
      await ensureUserProfileExists();
      final db = await database;
      await db.update(
        'user_profile',
        {'name': name, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'user = ?',
        whereArgs: [user],
      );
    }
  }

  Future<String?> getProfileImagePath({String user = 'Admin1'}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'user_profile',
        where: 'user = ?',
        whereArgs: [user],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first['profile_image_path'] as String?;
      }
      return null;
    } catch (e) {
      // If there's an error, ensure the table exists and try again
      await ensureUserProfileExists();
      return null;
    }
  }

  Future<void> setProfileImagePath(
    String? imagePath, {
    String user = 'Admin1',
  }) async {
    try {
      final db = await database;
      await db.update(
        'user_profile',
        {
          'profile_image_path': imagePath,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'user = ?',
        whereArgs: [user],
      );
    } catch (e) {
      // If there's an error, ensure the table exists and try again
      await ensureUserProfileExists();
      final db = await database;
      await db.update(
        'user_profile',
        {
          'profile_image_path': imagePath,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'user = ?',
        whereArgs: [user],
      );
    }
  }

  // Ensure user profile table exists and has data
  Future<void> ensureUserProfileExists() async {
    final db = await database;

    try {
      // Check if user_profile table exists
      final result = await db.query('user_profile', limit: 1);
      if (result.isEmpty) {
        // Table exists but no data, insert defaults for both users
        await db.insert('user_profile', {
          'user': 'Admin1',
          'name': 'Andrew',
          'profile_image_path': null,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
        await db.insert('user_profile', {
          'user': 'Admin2',
          'name': 'Sam',
          'profile_image_path': null,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      // Table doesn't exist, create it
      await db.execute('''
        CREATE TABLE user_profile(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL DEFAULT 'Andrew',
          profile_image_path TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Insert default user profile
      await db.insert('user_profile', {
        'name': 'Andrew',
        'profile_image_path': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
