import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventaris_flutter/models.dart';

const String baseUrl = 'https://inventaris-three.vercel.app';

Future<List<Transaction>> getTransactions() async {
  try {
    final response =
        await http.get(Uri.parse('$baseUrl/api/prisma?type=transactions'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Transaction.fromJson(item)).toList();
    } else {
      debugPrint('Failed to load transactions: ${response.body}');
      throw Exception('Failed to load transactions');
    }
  } catch (e) {
    debugPrint('Error in getTransactions: $e');
    throw Exception('Error fetching transactions: $e');
  }
}

Future<Transaction> getTransactionById(String id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/prisma?type=transaction&id=$id'),
  );

  if (response.statusCode == 200) {
    return Transaction.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load transaction');
  }
}

Future<void> createTransaction(
  int medicineId,
  String transactionType,
  int quantity,
  int operatorId,
) async {
  try {
    await http.post(
      Uri.parse('$baseUrl/api/prisma'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'actionType': 'transaction',
        'medicineId': medicineId,
        'transactionType': transactionType,
        'quantity': quantity,
        'operatorId': operatorId,
      }),
    );
  } catch (e) {
    debugPrint('Error in createTransaction: $e');
    throw Exception('Error creating transaction: $e');
  }
}

Future<Transaction> updateTransaction(
  String id,
  String medicineId,
  String quantity,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/prisma?type=transaction&id=$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'actionType': 'transaction',
      'medicineId': medicineId,
      'quantity': quantity,
    }),
  );

  if (response.statusCode == 200) {
    return Transaction.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update transaction');
  }
}

Future<void> deleteTransaction(String id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/prisma?type=transaction&id=$id'),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('Failed to delete transaction');
  }
}
