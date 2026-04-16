import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService apiService = ApiService();

  bool _isAuthenticated = false;
  String? _authToken;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
  String? get userName => _userName;

  void setAuthenticated(bool value, {String? token, String? userName}) {
    _isAuthenticated = value;
    _authToken = token;
    _userName = userName;
    apiService.setAuthToken(token);
    notifyListeners();
  }

  void setApiBaseUrl(String baseUrl) {
    apiService.setBaseUrl(baseUrl);
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _authToken = null;
    apiService.setAuthToken(null);
    notifyListeners();
  }
}
