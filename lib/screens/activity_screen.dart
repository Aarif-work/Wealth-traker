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
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    
    // Simple grouping logic for "Today" and "Yesterday"
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
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textBlack, size: 20),
          onPressed: () {}, // This is part of main layout tabs, but UI has it
        ),
        title: Text(
          "History",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.textBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00E676) : const Color(0xFFF5F6F9),
                borderRadius: BorderRadius.circular(24),
                border: isSelected ? null : Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blueGrey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
    return Text(
      title,
      style: TextStyle(
        color: Colors.blueGrey.shade300,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx, NumberFormat format) {
    final isIncome = tx.type == TransactionType.income;
    final isGold = tx.type == TransactionType.gold;
    
    Color iconBgColor;
    IconData icon;
    String categoryLabel;

    if (isIncome) {
      iconBgColor = const Color(0xFFE8F5E9);
      icon = Icons.account_balance_wallet_rounded;
      categoryLabel = "Income";
    } else if (isGold) {
      iconBgColor = const Color(0xFFFFF8E1);
      icon = Icons.auto_awesome_rounded;
      categoryLabel = "Investment";
    } else {
      iconBgColor = const Color(0xFFF5F5F5);
      icon = Icons.shopping_cart_rounded;
      categoryLabel = tx.title; // Simulating category from title for demo
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF5F6F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isIncome ? const Color(0xFF00E676) : (isGold ? Colors.orange : Colors.blueGrey),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$categoryLabel • ${DateFormat('hh:mm a').format(tx.date)}",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isIncome ? '+' : '-'}${format.format(tx.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isIncome ? const Color(0xFF00E676) : AppTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
