class Suppliers {
  final int id;
  final String name;
  final String contact;
  final String email;
  final String address;
  final String createdAt;
  final String updatedAt;
  final List<Medicine>? medicines;

  Suppliers({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.medicines,
  });

  factory Suppliers.fromJson(Map<String, dynamic> json) {
    return Suppliers(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((medicineJson) =>
                  Medicine.fromJson(medicineJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'medicines':
          medicines?.map((medicine) => medicine.toJson()).toList() ?? [],
    };
  }
}

class Medicine {
  final int id;
  final String name;
  final String description;
  final String dosage;
  final double price;
  final int quantity;
  final String expiryDate;
  final int? supplierId;
  final int? categoryId;
  final String? createdAt;
  final String? updatedAt;
  final bool stockOpname;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
    required this.price,
    required this.quantity,
    required this.expiryDate,
    this.supplierId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    required this.stockOpname,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      dosage: json['dosage'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      expiryDate: json['expiryDate'],
      supplierId: json['supplierId'],
      categoryId: json['categoryId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      stockOpname: json['stockOpname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
      'price': price,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'supplierId': supplierId,
      'categoryId': categoryId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stockOpname': stockOpname,
    };
  }
}

class Category {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;
  List<Medicine> medicines;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.medicines,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      medicines: (json['medicines'] as List<dynamic>)
          .map((medicineJson) =>
              Medicine.fromJson(medicineJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class TransactionOperator {
  final String name;

  TransactionOperator({
    required this.name,
  });

  factory TransactionOperator.fromJson(Map<String, dynamic> json) {
    return TransactionOperator(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class TransactionMedicine {
  final String name;
  final int quantity;
  final String price;

  TransactionMedicine({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory TransactionMedicine.fromJson(Map<String, dynamic> json) {
    return TransactionMedicine(
      name: json['name'] ?? '',
      quantity: json['quantity'].toInt(),
      price: json['price'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Transaction {
  final int id;
  final String type;
  final int quantity;
  final String createdAt;
  final TransactionOperator operator;
  final TransactionMedicine medicine;

  Transaction({
    required this.id,
    required this.type,
    required this.quantity,
    required this.createdAt,
    required this.operator,
    required this.medicine,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      quantity: json['quantity'],
      createdAt: json['createdAt'],
      operator: TransactionOperator.fromJson(json['operator']),
      medicine: TransactionMedicine.fromJson(json['medicine']),
    );
  }
}
