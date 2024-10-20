import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<Map<String, dynamic>> getDashboardData() async {
  final response = await http.get(Uri.parse('$baseUrl/api/dashboard'));

  if (response.statusCode == 200) {
    debugPrint('data: ${jsonDecode(response.body)}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to load dashboard data');
  }
}
