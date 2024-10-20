import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<List<Medicine>> getMedicines() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=medicines'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        .map<Medicine>((json) => Medicine.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load medicines');
  }
}

Future<List<Map<String, dynamic>>> getSpecificInfoOnAllMedicines() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=medicines&specific=true'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load specific info on medicine');
  }
}

Future<Medicine> getMedicineById(String id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=medicine&id=$id'),
  );

  if (response.statusCode == 200) {
    return Medicine.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load medicine');
  }
}

Future<Medicine> createMedicine(
    String name,
    String description,
    String price,
    String quantity,
    int categoryId,
    int supplierId,
    String dosage,
    String expiryDate) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'medicine',
      'name': name,
      'description': description,
      'price': double.parse(price),
      'quantity': int.parse(quantity),
      'categoryId': categoryId,
      'supplierId': supplierId,
      'dosage': dosage,
      'expiryDate': DateTime.parse(expiryDate).toIso8601String(),
    }),
  );

  if (response.statusCode == 200) {
    return Medicine.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create medicine');
  }
}

Future<Medicine> updateMedicine(
  int id,
  String name,
  String description,
  String dosage,
  double price,
  int quantity,
  DateTime expiryDate,
  bool stockOpname,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/prisma'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'medicine',
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
      'expiryDate': expiryDate.toIso8601String(),
      'stockOpname': stockOpname,
      'price': price,
      'quantity': quantity,
    }),
  );

  if (response.statusCode == 200) {
    return Medicine.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update medicine');
  }
}

Future<void> confirmStockOpname(int id) async {
  try {
    await http.put(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'actionType': 'confirm-stock-opname', 'id': id}),
    );
  } catch (e) {
    throw Exception('Failed to confirm stock opname');
  }
}

Future<void> deleteMedicine(int id) async {
  try {
    await http.delete(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'actionType': 'medicine', 'id': id}),
    );
  } catch (e) {
    throw Exception('Failed to delete medicine');
  }
}
