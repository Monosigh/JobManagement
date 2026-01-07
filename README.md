# Job Management for Workshop Mechanics

A Flutter mobile application designed to help workshop mechanics manage their daily tasks and work orders efficiently.

## Features

### Dashboard View
- **Summary Cards**: Display assigned tasks (21) and completed tasks (31) side by side
- **Period Filter**: Dropdown to filter between "Today" and "This Week"
- **Task Filter**: Dropdown to filter tasks by status:
  - All Tasks
  - Assigned
  - On Hold
  - Wait for Sign Off
  - Completed
- **Task List**: Scrollable list of tasks with detailed information

### Task Cards
Each task card displays:
- Task title
- Description
- Vehicle information (make, model, registration)
- Date
- Status-based action button (View, Sign Off, New task)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd assignment
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running on Different Platforms

- **Android**: `flutter run -d android`
- **iOS**: `flutter run -d ios`
- **Web**: `flutter run -d chrome`
- **Windows**: `flutter run -d windows`

## Project Structure

```
lib/
├── main.dart              # Main application entry point
│   ├── JobManagementApp   # Root app widget
│   ├── DashboardPage      # Main dashboard screen
│   └── Task              # Task data model
```

## Features Implemented

### ✅ Completed
- Clean, modern UI design matching the provided mockup
- Summary cards with task counts
- Interactive dropdown filters
- Task list with detailed cards
- Status-based button colors and text
- Responsive layout

### 🔄 In Progress
- Task filtering functionality (UI ready, logic to be implemented)
- Period filtering functionality (UI ready, logic to be implemented)

### 📋 Planned Features
- Task detail view
- Add new task functionality
- Task status updates
- User authentication
- Data persistence
- Push notifications

## UI Components

### Summary Section
- Two cards showing assigned and completed task counts
- Period filter dropdown (Today/This Week)

### Task Section
- Task filter dropdown with all status options
- Scrollable list of task cards

### Task Cards
- White background with subtle shadows
- Rounded corners for modern look
- Status-based colored buttons
- Vehicle information with icons
- Date display with clock icon

## Development Notes

This app follows Flutter best practices:
- Clean separation of UI and business logic
- Reusable widget components
- Proper state management using setState
- Material Design 3 principles
- Responsive design for different screen sizes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is created for educational purposes as part of a Flutter development assignment.
