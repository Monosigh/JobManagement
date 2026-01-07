import '../database/database_helper.dart';
import 'user_session_service.dart';

class UserDataService {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<String> getUserName() async {
    await _databaseHelper.ensureUserProfileExists();
    final currentUser = UserSessionService().currentUser;
    return await _databaseHelper.getUserName(user: currentUser);
  }

  static Future<void> setUserName(String name) async {
    await _databaseHelper.ensureUserProfileExists();
    final currentUser = UserSessionService().currentUser;
    await _databaseHelper.setUserName(name, user: currentUser);
  }

  static Future<String?> getProfileImagePath() async {
    await _databaseHelper.ensureUserProfileExists();
    final currentUser = UserSessionService().currentUser;
    return await _databaseHelper.getProfileImagePath(user: currentUser);
  }

  static Future<void> setProfileImagePath(String? imagePath) async {
    await _databaseHelper.ensureUserProfileExists();
    final currentUser = UserSessionService().currentUser;
    await _databaseHelper.setProfileImagePath(imagePath, user: currentUser);
  }
}
