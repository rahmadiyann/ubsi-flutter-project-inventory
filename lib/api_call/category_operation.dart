import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<List<Category>> getCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=categories'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        .map<Category>((json) => Category.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<List<Map<String, dynamic>>> getSpecificInfoOnAllCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=categories&specific=true'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load specific info on category');
  }
}

Future<Category> getCategoryById(String id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=category&id=$id'),
  );

  if (response.statusCode == 200) {
    return Category.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load category');
  }
}

Future<int> createCategory(String name) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'actionType': 'category',
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return response.statusCode;
    } else {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to create category: $e');
  }
}

Future<int> updateCategory(int id, String name) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'category',
      'id': id,
      'name': name,
    }),
  );

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to update category');
  }
}

Future<void> deleteCategory(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({'actionType': 'category', 'id': id}),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to delete category');
  }
}
