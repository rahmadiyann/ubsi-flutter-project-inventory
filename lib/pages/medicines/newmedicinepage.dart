import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventaris_flutter/api_call/medicine_operation.dart';
import 'package:inventaris_flutter/api_call/category_operation.dart';
import 'package:inventaris_flutter/api_call/suppliers_operation.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class NewMedicinePage extends StatefulWidget {
  const NewMedicinePage({super.key});

  @override
  State<NewMedicinePage> createState() => _NewMedicinePageState();
}

class _NewMedicinePageState extends State<NewMedicinePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _dosageController = TextEditingController();
  final _expiryDateController = TextEditingController();
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _isHovered = false;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _suppliers = [];
  int? _selectedCategoryId;
  int? _selectedSupplierId;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadCategoriesAndSuppliers();
  }

  Future<void> _loadCategoriesAndSuppliers() async {
    try {
      final categories = await getSpecificInfoOnAllCategories();
      final suppliers = await getSpecificInfoOnAllSuppliers();
      setState(() {
        _categories = List<Map<String, dynamic>>.from(categories);
        _suppliers = List<Map<String, dynamic>>.from(suppliers);
      });
    } catch (e) {
      debugPrint('Error loading categories and suppliers: $e');
      _showSnackBar(
          context, "Failed to load categories and suppliers: $e", false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _dosageController.dispose();
    _expiryDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: CustomPaint(
        painter: SnackBarPainter(isSuccess: isSuccess),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSuccess ? 'Success' : 'Error',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await createMedicine(
          _nameController.text,
          _descriptionController.text,
          _priceController.text,
          _stockController.text,
          _selectedCategoryId!.toInt(),
          _selectedSupplierId!.toInt(),
          _dosageController.text,
          _expiryDateController.text,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        _showSnackBar(context,
            "Medicine '${_nameController.text}' created successfully!", true);

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        _showSnackBar(context, "Failed to create medicine: $e", false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        _expiryDateController.text =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedExpiryDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Lottie.asset(
                    'assets/animations/medical_animation.json',
                    height: 200,
                    controller: _animationController,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    labelText: 'Medicine Name',
                    prefixIcon: Icons.medical_services,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    prefixIcon: Icons.description,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    labelText: 'Price',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stockController,
                    labelText: 'Stock',
                    prefixIcon: Icons.inventory,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a stock amount';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dosageController,
                    labelText: 'Dosage',
                    prefixIcon: Icons.medication,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a dosage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    controller: _expiryDateController,
                    labelText: 'Expiry Date',
                    prefixIcon: Icons.calendar_today,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an expiry date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    items: _categories,
                    value: _selectedCategoryId,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    labelText: 'Category',
                    prefixIcon: Icons.category,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    items: _suppliers,
                    value: _selectedSupplierId,
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplierId = value;
                      });
                    },
                    labelText: 'Supplier',
                    prefixIcon: Icons.business,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : Column(
                          children: [
                            MouseRegion(
                              onEnter: (_) => setState(() => _isHovered = true),
                              onExit: (_) => setState(() => _isHovered = false),
                              child: GestureDetector(
                                onTap: _submitForm,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: _isHovered
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Create Medicine',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: _isHovered
                                            ? Colors.white
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await confirmStockOpname(
                                      int.parse(_stockController.text));
                                  _showSnackBar(
                                      context,
                                      "Stock opname confirmed successfully!",
                                      true);
                                } catch (e) {
                                  _showSnackBar(
                                      context,
                                      "Failed to confirm stock opname: $e",
                                      false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Confirm Stock Opname',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required VoidCallback onTap,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
      ),
      readOnly: true,
      onTap: onTap,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required List<Map<String, dynamic>> items,
    required int? value,
    required void Function(int?) onChanged,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['name']),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.white70),
      ),
      style: GoogleFonts.poppins(color: Colors.white),
      dropdownColor: Theme.of(context).primaryColor,
      validator: (value) {
        if (value == null) {
          return 'Please select a $labelText';
        }
        return null;
      },
    );
  }
}

class SnackBarPainter extends CustomPainter {
  final bool isSuccess;

  SnackBarPainter({required this.isSuccess});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isSuccess
            ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
            : [const Color(0xFFE53935), const Color(0xFFD32F2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 10)
      ..lineTo(0, size.height - 10)
      ..arcToPoint(Offset(10, size.height), radius: const Radius.circular(10))
      ..lineTo(size.width - 10, size.height)
      ..arcToPoint(Offset(size.width, size.height - 10),
          radius: const Radius.circular(10))
      ..lineTo(size.width, 10)
      ..arcToPoint(Offset(size.width - 10, 0),
          radius: const Radius.circular(10))
      ..lineTo(10, 0)
      ..arcToPoint(const Offset(0, 10), radius: const Radius.circular(10))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
