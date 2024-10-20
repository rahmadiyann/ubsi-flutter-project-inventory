import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<List<Suppliers>> getSuppliers() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=suppliers'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        .map<Suppliers>((json) => Suppliers.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load suppliers');
  }
}

Future<List<Map<String, dynamic>>> getSpecificInfoOnAllSuppliers() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=suppliers&specific=true'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load specific info on supplier');
  }
}

Future<Suppliers> getSupplierById(String id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=supplier&id=$id'),
  );
  if (response.statusCode == 200) {
    return Suppliers.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load supplier');
  }
}

Future<void> createSupplier(
    String name, String email, String contact, String address) async {
  try {
    await http.post(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'actionType': 'supplier',
        'name': name,
        'email': email,
        'contact': contact,
        'address': address,
      }),
    );
  } catch (e) {
    throw Exception('Failed to create supplier: $e');
  }
}

Future<Suppliers> updateSupplier(
    int id, String name, String email, String contact, String address) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'supplier',
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'address': address,
    }),
  );

  if (response.statusCode == 200) {
    return Suppliers.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update supplier');
  }
}

Future<void> deleteSupplier(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'supplier',
      'id': id,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to delete supplier');
  }
}
