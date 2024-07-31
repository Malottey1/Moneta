import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int _userId;
  String _firstName;
  String _lastName;
  String _email;
  String? _profilePictureUrl;

  UserProvider(this._userId, this._firstName, this._lastName, this._email, [this._profilePictureUrl]);

  int get userId => _userId;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String? get profilePictureUrl => _profilePictureUrl;

  void updateUser(int userId, String firstName, String lastName, String email, String? profilePictureUrl) {
    _userId = userId;
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _profilePictureUrl = profilePictureUrl;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void setFirstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
  }

  void setLastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setProfilePictureUrl(String url) {
    _profilePictureUrl = url;
    notifyListeners();
  }
}