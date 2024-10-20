import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventaris_flutter/models.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inventaris_flutter/pages/medicines/medicinepage.dart';
import 'package:inventaris_flutter/api_call/category_operation.dart';

class CategoryPage extends StatefulWidget {
  final Category category;
  final User currentUser;
  const CategoryPage(
      {super.key, required this.category, required this.currentUser});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: GoogleFonts.poppins(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        prefixIcon:
                            const Icon(Icons.category, color: Colors.white70),
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
                              await updateCategory(
                                  widget.category.id, _nameController.text);
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pop(true); // Pass true to indicate update
                              _showSnackBar(
                                  'Category updated successfully', true);
                            } catch (e) {
                              _showSnackBar(
                                  'Failed to update category: $e', false);
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
                              await deleteCategory(widget.category.id);
                              Navigator.of(context).pop();
                              Navigator.of(context)
                                  .pop(true); // Pass true to indicate update
                              _showSnackBar(
                                  'Category deleted successfully', true);
                            } catch (e) {
                              _showSnackBar(
                                  'Failed to delete category: $e', false);
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
                          child: Text('Delete Category',
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
          onPressed: () => Navigator.of(context)
              .pop(false), // Pass false to indicate no update
        ),
        actions: [
          if (widget.currentUser.role != 'viewer')
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _showEditDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(child: _buildMedicinesList(theme, widget.currentUser)),
        ],
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
          _nameController.text,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesList(ThemeData theme, User currentUser) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: widget.category.medicines.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildMedicineCard(
                    widget.category.medicines[index], theme, currentUser),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicineCard(
      Medicine medicine, ThemeData theme, User currentUser) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MedicinePage(medicine: medicine, currentUser: currentUser)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
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
