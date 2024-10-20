import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<List<User>> getUsers() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=users'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        .map<User>((json) => User.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load users');
  }
}

Future<void> updateUser(
  int userId,
  String name,
  String email,
  String role,
) async {
  try {
    await http.put(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'actionType': 'operator',
        'id': userId,
        'name': name,
        'email': email,
        'role': role,
      }),
    );
  } catch (e) {
    debugPrint('Error in updateUser: $e');
    throw Exception('Error updating user: $e');
  }
}
