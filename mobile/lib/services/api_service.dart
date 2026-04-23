// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Web localhost
  // For iOS simulator, use: 'http://localhost:8000/api'
  // For physical device, use your computer's IP address

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  ApiService() {
    _setupInterceptors();
  }

  String? _authToken;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Authentication methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {'username': username, 'password': password},
      );
      return response.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    {
    String role = 'client',
    String? coachJoinCode,
    }
  ) async {
    try {
      final payload = {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };
      if (coachJoinCode != null && coachJoinCode.trim().isNotEmpty) {
        payload['coach_join_code'] = coachJoinCode.trim().toUpperCase();
      }

      final response = await _dio.post(
        '/auth/register/',
        data: payload,
      );
      return response.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Program methods
  Future<List<TrainingProgram>> getPrograms() async {
    try {
      final response = await _dio.get('/programs/');
      final dynamic responseData = response.data;
      final List<dynamic> data = responseData is Map<String, dynamic> && responseData.containsKey('results')
          ? responseData['results'] as List<dynamic>
          : responseData as List<dynamic>;
      return data.map((json) => TrainingProgram.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load programs: $e');
    }
  }

  Future<TrainingProgram> getProgram(int id) async {
    try {
      final response = await _dio.get('/programs/$id/');
      return TrainingProgram.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load program: $e');
    }
  }

  Future<TrainingProgram> createProgram({
    required String name,
    required int weekTotal,
    String programType = 'hypertrophy',
  }) async {
    try {
      final response = await _dio.post(
        '/programs/',
        data: {
          'name': name,
          'week_total': weekTotal,
          'program_type': programType,
        },
      );
      return TrainingProgram.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create program: $e');
    }
  }

  // Exercise methods
  Future<List<Exercise>> getExercises() async {
    try {
      final response = await _dio.get('/exercises/');
      final dynamic responseData = response.data;
      final List<dynamic> data = responseData is Map<String, dynamic> && responseData.containsKey('results')
          ? responseData['results'] as List<dynamic>
          : responseData as List<dynamic>;
      return data.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }

  // Dashboard data
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}
