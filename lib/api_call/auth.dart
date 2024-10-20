import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

Future<AuthResponse> authenticate(String email, String password,
    {bool isRegistration = false, String? name}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'isRegistration': isRegistration,
        if (isRegistration) 'name': name,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 401) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      debugPrint('Authentication error: ${response.body}');
      throw Exception('Failed to authenticate');
    }
  } catch (e) {
    debugPrint('Authentication error: $e');
    throw Exception('Failed to authenticate');
  }
}

Future<AuthResponse> login(String email, String password) async {
  return authenticate(email, password, isRegistration: false);
}

Future<AuthResponse> register(
    String name, String email, String password) async {
  return authenticate(email, password, isRegistration: true, name: name);
}
