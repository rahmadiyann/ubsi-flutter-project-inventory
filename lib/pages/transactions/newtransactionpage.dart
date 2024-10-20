import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventaris_flutter/api_call/transaction_operation.dart';
import 'package:inventaris_flutter/api_call/medicine_operation.dart';
import 'package:inventaris_flutter/models.dart';
import 'package:lottie/lottie.dart';

class NewTransactionPage extends StatefulWidget {
  final User currentUser;
  const NewTransactionPage({super.key, required this.currentUser});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  late AnimationController _animationController;
  bool _isLoading = false;
  bool _isHovered = false;

  List<Map<String, dynamic>> _medicines = [];
  int? _selectedMedicineId;
  String _transactionType = 'sale';
  int _currentMedicineQuantity = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await getSpecificInfoOnAllMedicines();
      setState(() {
        _medicines = List<Map<String, dynamic>>.from(medicines);
      });
    } catch (e) {
      debugPrint('Error loading medicines: $e');
      _showSnackBar("Failed to load medicines: $e", false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await createTransaction(
          _selectedMedicineId!,
          _transactionType,
          int.parse(_quantityController.text),
          widget.currentUser.id,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        _showSnackBar("Transaction created successfully!", true);
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnackBar("Failed to create transaction: $e", false);
      }
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
                    'assets/animations/transaction_animation.json',
                    height: 200,
                    controller: _animationController,
                  ),
                  const SizedBox(height: 24),
                  _buildTransactionTypeSwitch(),
                  const SizedBox(height: 16),
                  _buildMedicineDropdown(),
                  const SizedBox(height: 16),
                  _buildQuantityField(),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Purchase', style: GoogleFonts.poppins(color: Colors.white)),
        Switch(
          value: _transactionType == 'sale',
          onChanged: (value) {
            setState(() {
              _transactionType = value ? 'sale' : 'purchase';
            });
          },
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.blue,
        ),
        Text('Sale', style: GoogleFonts.poppins(color: Colors.white)),
      ],
    );
  }

  Widget _buildMedicineDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMedicineId,
      items: _medicines.map((medicine) {
        return DropdownMenuItem<int>(
          value: medicine['id'],
          child: Text(medicine['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMedicineId = value;
          _currentMedicineQuantity = _medicines
              .firstWhere((medicine) => medicine['id'] == value)['quantity'];
        });
      },
      decoration: InputDecoration(
        labelText: 'Select Medicine',
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
      ),
      style: GoogleFonts.poppins(color: Colors.white),
      dropdownColor: Theme.of(context).primaryColor,
      validator: (value) {
        if (value == null) {
          return 'Please select a medicine';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Quantity',
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
        prefixIcon: const Icon(Icons.shopping_cart, color: Colors.white70),
        suffixText: _selectedMedicineId != null
            ? 'Available: $_currentMedicineQuantity'
            : null,
        suffixStyle: GoogleFonts.poppins(color: Colors.white70),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a quantity';
        }
        int? quantity = int.tryParse(value);
        if (quantity == null || quantity <= 0) {
          return 'Please enter a valid quantity';
        }
        if (_transactionType == 'sale' && quantity > _currentMedicineQuantity) {
          return 'Quantity cannot exceed available stock';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _submitForm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 55,
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              'Create Transaction',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    _isHovered ? Colors.white : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
