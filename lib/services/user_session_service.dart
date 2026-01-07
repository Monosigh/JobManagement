class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  String _currentUser = 'Admin123'; // Default user

  String get currentUser => _currentUser;

  void setCurrentUser(String user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = 'Admin123'; // Reset to default
  }
}
