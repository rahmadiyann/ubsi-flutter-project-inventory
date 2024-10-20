import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventaris_flutter/models.dart';
import 'package:intl/intl.dart';
import 'package:inventaris_flutter/api_call/medicine_operation.dart';

class MedicinePage extends StatefulWidget {
  final Medicine medicine;
  final User currentUser;
  const MedicinePage(
      {super.key, required this.medicine, required this.currentUser});

  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dosageController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _descriptionController =
        TextEditingController(text: widget.medicine.description);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _priceController =
        TextEditingController(text: widget.medicine.price.toString());
    _quantityController =
        TextEditingController(text: widget.medicine.quantity.toString());
    _expiryDateController =
        TextEditingController(text: widget.medicine.expiryDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_expiryDateController.text),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showEditDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3))
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Edit Medicine',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Medicine Name',
                        Icons.medical_services),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Description',
                        Icons.description),
                    const SizedBox(height: 16),
                    _buildTextField(
                        _dosageController, 'Dosage', Icons.medication),
                    const SizedBox(height: 16),
                    _buildTextField(
                        _priceController, 'Price', Icons.attach_money,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(
                        _quantityController, 'Quantity', Icons.inventory,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildTextField(_expiryDateController,
                            'Expiry Date', Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await updateMedicine(
                                widget.medicine.id,
                                _nameController.text,
                                _descriptionController.text,
                                _dosageController.text,
                                double.parse(_priceController.text),
                                int.parse(_quantityController.text),
                                DateTime.parse(_expiryDateController.text),
                                widget.medicine.stockOpname,
                              );
                              Navigator.of(context).pop();
                              _showSnackBar(
                                  'Medicine updated successfully', true);
                            } catch (e) {
                              _showSnackBar(
                                  'Failed to update medicine: $e', false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text('Save',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (widget.currentUser.role == 'admin')
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await deleteMedicine(widget.medicine.id);
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pop(true); // Pass true to indicate update
                              _showSnackBar(
                                  'Medicine deleted successfully', true);
                            } catch (e) {
                              _showSnackBar(
                                  'Failed to delete medicine: $e', false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text('Delete Medicine',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      keyboardType: keyboardType,
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.currentUser.role != 'viewer')
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _showEditDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildMedicineInfo(theme),
            if (widget.currentUser.role != 'viewer')
              widget.medicine.stockOpname == false
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await confirmStockOpname(widget.medicine.id);
                            _showSnackBar(
                                'Stock opname confirmed successfully', true);
                          } catch (e) {
                            _showSnackBar(
                                'Failed to confirm stock opname: $e', false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text('Confirm Stock Opname',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primaryColor, theme.colorScheme.secondary],
        ),
      ),
      child: Center(
        child: Text(
          widget.medicine.name,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile('Description', widget.medicine.description, theme),
          _buildInfoTile('Dosage', widget.medicine.dosage, theme),
          _buildInfoTile(
              'Price', '\$${widget.medicine.price.toStringAsFixed(2)}', theme),
          _buildInfoTile(
              'Quantity', widget.medicine.quantity.toString(), theme),
          _buildInfoTile(
              'Expiry Date',
              DateFormat('dd/MM/yyyy')
                  .format(DateTime.parse(widget.medicine.expiryDate)),
              theme),
          _buildInfoTile('Stock Opname',
              widget.medicine.stockOpname ? 'Confirmed' : 'Unconfirmed', theme),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
