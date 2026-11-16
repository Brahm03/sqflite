import 'package:flutter/foundation.dart';

import '../utils/database_service.dart';

enum AuthStatus { loading, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.loading;
  UserModel? _user;
  bool _busy = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get busy => _busy;

  Future<void> load() async {
    _user = await DatabaseService.getUser();
    _status = _user == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      await DatabaseService.addUserToDB(name, lastName, email, password);
      await load();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    await DatabaseService.logOut();
    _user = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}
