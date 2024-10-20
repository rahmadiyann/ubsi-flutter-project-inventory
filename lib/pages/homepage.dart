import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:inventaris_flutter/api_call/category_operation.dart';
import 'package:inventaris_flutter/api_call/medicine_operation.dart';
import 'package:inventaris_flutter/api_call/suppliers_operation.dart';
import 'package:inventaris_flutter/api_call/transaction_operation.dart';
import 'package:inventaris_flutter/api_call/users_operation.dart';
import 'package:inventaris_flutter/models.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inventaris_flutter/pages/authpage.dart';
import 'package:inventaris_flutter/pages/categories/categorypage.dart';
import 'package:inventaris_flutter/pages/categories/newcategorypage.dart';
import 'package:inventaris_flutter/pages/medicines/medicinepage.dart';
import 'package:inventaris_flutter/pages/medicines/newmedicinepage.dart';
import 'package:inventaris_flutter/pages/suppliers/newsupplierpage.dart';
import 'package:inventaris_flutter/pages/suppliers/supplierpage.dart';
import 'package:inventaris_flutter/pages/transactions/transactionpage.dart';
import 'package:inventaris_flutter/pages/users/userpage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:inventaris_flutter/pages/transactions/newtransactionpage.dart';

class Homepage extends StatefulWidget {
  final User user;

  const Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.medication, label: 'Medicines'),
    _NavItem(icon: Icons.list_alt, label: 'Categories'),
    _NavItem(icon: Icons.receipt, label: 'Transactions'),
    _NavItem(icon: Icons.people, label: 'Suppliers'),
    _NavItem(icon: Icons.person, label: 'Operators'),
  ];

  int _selectedIndex = 2;
  late Future<void> _dataFuture;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _filterStockOpname = false;
  String _filterCategoryName = '';
  String _filterOperatorName = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _filterSupplierName = '';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      getTransactions(),
      getMedicines(),
      getUsers(),
      getCategories(),
      getSuppliers(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/logout_animations.json',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Authpage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20 * _animation.value),
                    bottomRight: Radius.circular(20 * _animation.value),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    _navItems[_selectedIndex].icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _navItems[_selectedIndex].label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: _logout,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        Icons.logout,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return FadeTransition(
            opacity: _animation,
            child: _buildBody(widget.user),
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        color: theme.primaryColor,
        buttonBackgroundColor: theme.colorScheme.secondary,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: _navItems
            .map((item) => Icon(item.icon, color: Colors.white))
            .toList(),
        onTap: _onItemTapped,
        index: _selectedIndex,
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(User currentUser) {
    switch (_selectedIndex) {
      case 0:
        return MedicinesPage(currentUser: currentUser);
      case 1:
        return CategoriesPage(currentUser: currentUser);
      case 2:
        return const TransactionsPage();
      case 3:
        return SuppliersPage(currentUser: currentUser);
      case 4:
        return OperatorsPage(currentUser: currentUser);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFloatingActionButton(ThemeData theme) {
    if (_selectedIndex == 4) return null; // No FAB for Users tab

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      backgroundColor: theme.colorScheme.secondary,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: theme.primaryColor,
          onTap: () => _onAddButtonTapped(context, widget.user),
          label: 'Add ${_getAddButtonLabel()}',
          labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, color: theme.primaryColor),
          labelBackgroundColor: Colors.white,
        ),
        SpeedDialChild(
          child: const Icon(Icons.filter_list, color: Colors.white),
          backgroundColor: theme.primaryColor,
          onTap: () => _onFilterButtonTapped(context),
          label: 'Filter ${_navItems[_selectedIndex].label}',
          labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, color: theme.primaryColor),
          labelBackgroundColor: Colors.white,
        ),
      ],
    );
  }

  String _getAddButtonLabel() {
    switch (_selectedIndex) {
      case 0:
        return 'Medicine';
      case 1:
        return 'Category';
      case 2:
        return 'Transaction';
      case 3:
        return 'Supplier';
      default:
        return '';
    }
  }

  void _onAddButtonTapped(BuildContext context, User currentUser) {
    switch (_selectedIndex) {
      case 0:
        // Navigate to Add Medicine page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewMedicinePage()));
        break;
      case 1:
        // Navigate to Add Category page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewCategoryPage()));
        break;
      case 2:
        // Navigate to Add Transaction page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTransactionPage(currentUser: currentUser),
          ),
        );
        break;
      case 3:
        // Navigate to Add Supplier page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewSupplierPage()));
        break;
    }
  }

  void _onFilterButtonTapped(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter ${_navItems[_selectedIndex].label}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFilterOptions(setState),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildFilterOptions(StateSetter setState) {
    switch (_selectedIndex) {
      case 0: // Medicines
        return [
          CheckboxListTile(
            title: const Text('Stock Opname Status'),
            value: _filterStockOpname,
            onChanged: (bool? value) {
              setState(() {
                _filterStockOpname = value ?? false;
              });
            },
          ),
        ];
      case 1: // Categories
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Category Name'),
            onChanged: (value) {
              setState(() {
                _filterCategoryName = value;
              });
            },
          ),
        ];
      case 2: // Transactions
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Operator Name'),
            onChanged: (value) {
              setState(() {
                _filterOperatorName = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Date Range:'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _filterStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _filterStartDate = picked;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: _filterStartDate != null
                        ? DateFormat('yyyy-MM-dd').format(_filterStartDate!)
                        : '',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'End Date'),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _filterEndDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _filterEndDate = picked;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: _filterEndDate != null
                        ? DateFormat('yyyy-MM-dd').format(_filterEndDate!)
                        : '',
                  ),
                ),
              ),
            ],
          ),
        ];
      case 3: // Suppliers
        return [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Supplier Name'),
            onChanged: (value) {
              setState(() {
                _filterSupplierName = value;
              });
            },
          ),
        ];
      default:
        return [];
    }
  }

  void _applyFilters() {
    // Here you would typically update your data source with the applied filters
    // For now, we'll just print the filter values
    debugPrint('Applying filters:');
    debugPrint('Stock Opname: $_filterStockOpname');
    debugPrint('Category Name: $_filterCategoryName');
    debugPrint('Operator Name: $_filterOperatorName');
    debugPrint('Start Date: $_filterStartDate');
    debugPrint('End Date: $_filterEndDate');
    debugPrint('Supplier Name: $_filterSupplierName');

    // TODO: Implement actual filtering logic here
    // This might involve calling an API or filtering local data
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: getTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox.shrink());
        }
        final transactions = snapshot.data!;
        final sortedTransactions = transactions
          ..sort((a, b) => DateTime.parse(b.createdAt)
              .compareTo(DateTime.parse(a.createdAt)));
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: sortedTransactions.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _TransactionCard(
                      transaction: sortedTransactions[index],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSale = transaction.type == 'sale';
    final cardColor = isSale ? Colors.green[800] : Colors.orange[800];
    const textColor = Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionPage(transaction: transaction),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/drugs.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.medicine.name,
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleMedium,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isSale ? 'Sale' : 'Purchase',
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodySmall,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodySmall,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        transaction.quantity.toString(),
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleLarge,
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(
                          DateTime.parse(transaction.createdAt).toLocal(),
                        ),
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodySmall,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(
                          DateTime.parse(transaction.createdAt).toLocal(),
                        ),
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodyMedium,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person, color: textColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    transaction.operator.name,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicinesPage extends StatelessWidget {
  final User currentUser;
  const MedicinesPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Medicine>>(
      future: getMedicines(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox.shrink());
        }
        final medicines = snapshot.data!;
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _MedicineCard(
                        medicine: medicines[index], currentUser: currentUser),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final User currentUser;

  const _MedicineCard({required this.medicine, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expired =
        DateTime.parse(medicine.expiryDate).isBefore(DateTime.now());
    final daysUntilExpiry =
        DateTime.parse(medicine.expiryDate).difference(DateTime.now()).inDays;
    final cardColor = expired
        ? Colors.red[800]
        : (medicine.stockOpname ? Colors.blue[800] : Colors.orange[800]);
    const textColor = Colors.white;
    final soCardColor = medicine.stockOpname ? Colors.white : Colors.black;
    final soTextColor = medicine.stockOpname ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MedicinePage(medicine: medicine, currentUser: currentUser),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.titleMedium,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: soCardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      medicine.stockOpname ? 'Confirmed' : 'Unconfirmed',
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodySmall,
                        color: soTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodySmall,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        medicine.quantity.toString(),
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleLarge,
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Price',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodySmall,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '\$${medicine.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleMedium,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services,
                          color: textColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        medicine.dosage,
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodyMedium,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.event, color: textColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        expired
                            ? 'Expired'
                            : '${daysUntilExpiry.abs()} days ${daysUntilExpiry >= 0 ? 'to expiry' : 'ago'}',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodyMedium,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  final User currentUser;
  const CategoriesPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox.shrink());
        }
        final categories = snapshot.data!;
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _CategoryCard(
                        category: categories[index], currentUser: currentUser),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final User currentUser;
  const _CategoryCard({required this.category, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Colors.purple[800];
    const textColor = Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CategoryPage(category: category, currentUser: currentUser),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.titleMedium,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${category.medicines.length} Medicines',
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodySmall,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Medicines:',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.bodySmall,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              ...category.medicines.map((medicine) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${medicine.name}',
                            style: GoogleFonts.poppins(
                              textStyle: theme.textTheme.bodyMedium,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Qty: ${medicine.quantity}',
                          style: GoogleFonts.poppins(
                            textStyle: theme.textTheme.bodySmall,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(category.createdAt))}',
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodySmall,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Updated: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(category.updatedAt))}',
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodySmall,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuppliersPage extends StatelessWidget {
  final User currentUser;
  const SuppliersPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Suppliers>>(
      future: getSuppliers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox.shrink());
        }
        final suppliers = snapshot.data!;
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _SupplierCard(
                        supplier: suppliers[index], currentUser: currentUser),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Suppliers supplier;
  final User currentUser;
  const _SupplierCard({required this.supplier, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Colors.teal[800];
    const textColor = Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SupplierPage(supplier: supplier, currentUser: currentUser)),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      supplier.name,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.titleMedium,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${supplier.medicines?.length ?? 0} Medicines',
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodySmall,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone, color: textColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    supplier.contact,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, color: textColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    supplier.email,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: textColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supplier.address,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodyMedium,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Medicines:',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.bodySmall,
                  color: textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              ...(supplier.medicines ?? []).map((medicine) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${medicine.name}',
                            style: GoogleFonts.poppins(
                              textStyle: theme.textTheme.bodyMedium,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Qty: ${medicine.quantity}',
                          style: GoogleFonts.poppins(
                            textStyle: theme.textTheme.bodySmall,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class OperatorsPage extends StatelessWidget {
  final User currentUser;
  const OperatorsPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: getUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: SizedBox.shrink());
        }
        final operators = snapshot.data!;
        operators.sort(
            (a, b) => a.id.compareTo(b.id)); // Sort by ID in ascending order
        return AnimationLimiter(
          child: ListView.builder(
            itemCount: operators.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _OperatorCard(
                        operator: operators[index], currentUser: currentUser),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final User operator;
  final User currentUser;
  const _OperatorCard({required this.operator, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = switch (operator.role) {
      'admin' => Colors.red[800],
      'operator' => Colors.blue[800],
      'stakeholder' => Colors.green[800],
      'viewer' => Colors.orange[800],
      _ => Colors.indigo[800],
    };
    const textColor = Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OperatorPage(operator: operator, currentUser: currentUser),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      operator.name,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.titleMedium,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      operator.role,
                      style: GoogleFonts.poppins(
                        textStyle: theme.textTheme.bodySmall,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.email, color: textColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    operator.email,
                    style: GoogleFonts.poppins(
                      textStyle: theme.textTheme.bodyMedium,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID',
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.bodySmall,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        operator.id.toString(),
                        style: GoogleFonts.poppins(
                          textStyle: theme.textTheme.titleLarge,
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.person,
                    color: textColor,
                    size: 48,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
