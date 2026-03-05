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

  @override
  Widget build(BuildContext context) {
    final wealthProvider = Provider.of<WealthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final filteredTransactions = wealthProvider.transactions.where((tx) {
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
      backgroundColor: const Color(0xFFF7F8FA),
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
          _appBarButton(Icons.arrow_back_ios_new_rounded),
          const Text(
            'History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          _appBarButton(Icons.search_rounded),
        ],
      ),
    );
  }

  Widget _appBarButton(IconData icon) {
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
      child: Icon(icon, size: 20, color: AppTheme.textBlack),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          Color activeColor = const Color(0xFF1D1D1F);
          if (filter == "Income") activeColor = const Color(0xFF00C853);
          if (filter == "Expenses") activeColor = const Color(0xFFE53935);
          if (filter == "Gold") activeColor = const Color(0xFFF57F17);

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isSelected ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blueGrey.shade400,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blueGrey.shade300,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
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
      iconBgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF00C853);
      icon = Icons.account_balance_wallet_rounded;
      categoryLabel = tx.title.startsWith("Help Save:") ? "Emotional Save" : "Income";
    } else if (isGold) {
      iconBgColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFFFB300);
      icon = Icons.auto_awesome_rounded;
      categoryLabel = tx.title.startsWith("Help Save:") ? "Emotional Save" : "Investment";
    } else {
      iconBgColor = const Color(0xFFF5F5F5);
      iconColor = Colors.blueGrey.shade600;
      icon = Icons.shopping_cart_rounded;
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
              color: isIncome ? const Color(0xFF00C853) : AppTheme.textBlack,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
