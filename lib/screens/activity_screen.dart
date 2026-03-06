import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Income", "Expenses", "Gold"];
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wealthProvider = Provider.of<WealthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final filteredTransactions = wealthProvider.transactions.where((tx) {
      if (_searchQuery.isNotEmpty && !tx.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (selectedFilter == "All") return true;
      if (selectedFilter == "Income") return tx.type == TransactionType.income;
      if (selectedFilter == "Expenses") return tx.type == TransactionType.expense;
      if (selectedFilter == "Gold") return tx.type == TransactionType.gold;
      return true;
    }).toList();

    final todayTransactions = filteredTransactions.where((tx) => tx.date.isAfter(today) || tx.date.isAtSameMomentAs(today)).toList();
    final yesterdayTransactions = filteredTransactions.where((tx) => tx.date.isAfter(yesterday) && tx.date.isBefore(today)).toList();
    final olderTransactions = filteredTransactions.where((tx) => tx.date.isBefore(yesterday)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (todayTransactions.isNotEmpty) ...[
                    _buildSectionHeader("TODAY"),
                    const SizedBox(height: 16),
                    ...todayTransactions.map((tx) => _buildTransactionCard(tx, currencyFormat)),
                  ],
                  if (yesterdayTransactions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader("YESTERDAY"),
                    const SizedBox(height: 16),
                    ...yesterdayTransactions.map((tx) => _buildTransactionCard(tx, currencyFormat)),
                  ],
                  if (olderTransactions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader("OLDER"),
                    const SizedBox(height: 16),
                    ...olderTransactions.map((tx) => _buildTransactionCard(tx, currencyFormat)),
                  ],
                  const SizedBox(height: 100), // Space for FAB/Bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!_isSearchOpen) ...[
            const Text(
              'History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textBlack,
                letterSpacing: -0.5,
              ),
            ),
          ] else ...[
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: "Search transactions...",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppTheme.textGray),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          GestureDetector(
            onTap: () {
              setState(() {
                if (_isSearchOpen) {
                  _isSearchOpen = false;
                  _searchQuery = "";
                  _searchController.clear();
                } else {
                  _isSearchOpen = true;
                }
              });
            },
            child: _appBarButton(_isSearchOpen ? Icons.close_rounded : Icons.search_rounded, color: _isSearchOpen ? AppTheme.expenseRed : null),
          ),
        ],
      ),
    );
  }

  Widget _appBarButton(IconData icon, {Color? color}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Icon(icon, size: 20, color: color ?? AppTheme.textBlack),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          Color activeColor = AppTheme.textBlack;
          IconData icon = Icons.tune_rounded;
          
          if (filter == "Income") {
            activeColor = AppTheme.primaryGreen;
            icon = Icons.south_west_rounded;
          } else if (filter == "Expenses") {
            activeColor = AppTheme.expenseRed;
            icon = Icons.north_east_rounded;
          } else if (filter == "Gold") {
            activeColor = const Color(0xFFFFB800);
            icon = Icons.star_rounded;
          } else if (filter == "All") {
            activeColor = AppTheme.textBlack;
            icon = Icons.grid_view_rounded;
          }

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? activeColor : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.blueGrey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blueGrey.shade400,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx, NumberFormat format) {
    final isIncome = tx.type == TransactionType.income;
    final isGold = tx.type == TransactionType.gold;
    
    Color iconBgColor;
    Color iconColor;
    IconData icon;
    String categoryLabel;

    if (isIncome) {
      iconBgColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
      iconColor = AppTheme.primaryGreen;
      icon = Icons.account_balance_rounded;
      categoryLabel = tx.title.startsWith("Help Save:") ? "Emotional Save" : "Income";
    } else if (isGold) {
      iconBgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFFFB300);
      icon = Icons.workspace_premium_rounded;
      categoryLabel = tx.title.startsWith("Help Save:") ? "Emotional Save" : "Investment";
    } else {
      iconBgColor = const Color(0xFFF5F5F7);
      iconColor = Colors.blueGrey.shade600;
      icon = Icons.payments_rounded;
      categoryLabel = "Expense";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title.replaceFirst('Help Save: ', ''), // clean up title for view
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppTheme.textBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$categoryLabel • ${DateFormat('hh:mm a').format(tx.date)}",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}${format.format(tx.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isIncome ? AppTheme.primaryGreen : AppTheme.textBlack,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
