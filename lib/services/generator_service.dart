import 'package:flutter/foundation.dart';
import 'package:passgrinder/models/password_generator.dart';

class GeneratorService with ChangeNotifier {
  String _masterPassword = '';
  String _uniquePhrase = '';
  int _variation = 0;
  String _generatedPassword = '';
  bool _showPassword = false;

  String get masterPassword => _masterPassword;
  String get uniquePhrase => _uniquePhrase;
  int get variation => _variation;
  String get generatedPassword => _generatedPassword;
  bool get showPassword => _showPassword;

  void setMasterPassword(String value) {
    _masterPassword = value;
    _generatePassword();
    notifyListeners();
  }

  void setUniquePhrase(String value) {
    _uniquePhrase = value;
    _generatePassword();
    notifyListeners();
  }

  void setVariation(int value) {
    _variation = value;
    _generatePassword();
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void _generatePassword() {
    if (_masterPassword.isNotEmpty) {
      final generator = PasswordGenerator(
        masterPassword: _masterPassword,
        uniquePhrase: _uniquePhrase,
        variation: _variation,
      );
      _generatedPassword = generator.generate();
    } else {
      _generatedPassword = '';
    }
  }

  void clear() {
    _masterPassword = '';
    _uniquePhrase = '';
    _variation = 0;
    _generatedPassword = '';
    _showPassword = false;
    notifyListeners();
  }
}
