import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventaris_flutter/models.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventaris_flutter/pages/medicines/medicinepage.dart';
import 'package:inventaris_flutter/api_call/suppliers_operation.dart';

class SupplierPage extends StatefulWidget {
  final Suppliers supplier;
  final User currentUser;
  const SupplierPage(
      {super.key, required this.supplier, required this.currentUser});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _emailController = TextEditingController(text: widget.supplier.email);
    _contactController = TextEditingController(text: widget.supplier.contact);
    _addressController = TextEditingController(text: widget.supplier.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
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
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Supplier',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _nameController, 'Supplier Name', Icons.business),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, 'Email', Icons.email),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _contactController, 'Contact', Icons.phone),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _addressController, 'Address', Icons.location_on),
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
                                await updateSupplier(
                                  widget.supplier.id,
                                  _nameController.text,
                                  _emailController.text,
                                  _contactController.text,
                                  _addressController.text,
                                );
                                Navigator.of(context).pop();
                                _showSnackBar(
                                    'Supplier updated successfully', true);
                              } catch (e) {
                                _showSnackBar(
                                    'Failed to update supplier: $e', false);
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
                                await deleteSupplier(widget.supplier.id);
                                Navigator.of(context).pop();
                                Navigator.of(context)
                                    .pop(true); // Pass true to indicate update
                                _showSnackBar(
                                    'Supplier deleted successfully', true);
                              } catch (e) {
                                _showSnackBar(
                                    'Failed to delete supplier: $e', false);
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
                            child: Text('Delete Supplier',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
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
            _buildSupplierInfo(theme),
            _buildMedicinesList(theme),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                widget.supplier.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.supplier.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(Icons.email, 'Email', widget.supplier.email, theme),
          _buildInfoTile(
              Icons.phone, 'Contact', widget.supplier.contact, theme),
          _buildInfoTile(
              Icons.location_on, 'Address', widget.supplier.address, theme),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 10),
          Column(
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
        ],
      ),
    );
  }

  Widget _buildMedicinesList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Supplied Medicines',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.supplier.medicines?.length ?? 0,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget.supplier.medicines != null
                        ? _buildMedicineCard(widget.supplier.medicines![index],
                            theme, widget.currentUser)
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(
      Medicine medicine, ThemeData theme, User currentUser) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MedicinePage(
                medicine: medicine, currentUser: widget.currentUser)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.primaryColor,
            child: SvgPicture.asset(
              'assets/svgs/drugs.svg',
              width: 24,
              height: 24,
            ),
          ),
          title: Text(
            medicine.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Quantity: ${medicine.quantity}',
            style: GoogleFonts.poppins(),
          ),
          trailing: Text(
            '\$${medicine.price.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
