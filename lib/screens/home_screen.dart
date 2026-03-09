import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wealthProvider = Provider.of<WealthProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    final compactFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTotalWealthCard(wealthProvider, currencyFormat),
              const SizedBox(height: 24),
              _buildMonthlyStats(wealthProvider, compactFormat),
              const SizedBox(height: 32),
              _buildSectionTitle('WEALTH BREAKDOWN'),
              const SizedBox(height: 16),
              _buildWealthBreakdown(wealthProvider),
              const SizedBox(height: 32),
              _buildGoldGoalTracker(wealthProvider),
              const SizedBox(height: 32),
              _buildRecentActivityHeader(context),
              const SizedBox(height: 16),
              _buildRecentActivityList(wealthProvider, currencyFormat),
              const SizedBox(height: 100), // Space for footer
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMMM').format(now);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppTheme.textBlack,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getGreeting(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade400,
              ),
            ),
          ],
        ),
        Text(
          dateStr.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryGreen,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalWealthCard(WealthProvider provider, NumberFormat format) {
    final parts = format.format(provider.totalWealth).split('.');
    final mainAmount = parts[0];
    final decimals = parts.length > 1 ? parts[1] : '00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.softGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
          color: AppTheme.textBlack.withValues(alpha: 0.04),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
    ),
      child: Column(
        children: [
          Text(
            'TOTAL WEALTH',
            style: TextStyle(
              color: Colors.blueGrey.shade300,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD54F), // Gold yellow
                ),
              ),
              const SizedBox(width: 4),
              Text(
                mainAmount.replaceAll('₹', ''),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textBlack,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '.$decimals',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade200,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(WealthProvider provider, NumberFormat format) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'MONTHLY SPENDING',
            format.format(provider.monthlyExpenses),
            Icons.arrow_downward_rounded,
            const Color(0xFFFF8A80), // Soft red
            0.4, // Simplified ratio for UI
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'MONTHLY INCOME',
            format.format(provider.monthlyIncome),
            Icons.arrow_upward_rounded,
            AppTheme.primaryGreen,
            0.7, // Simplified ratio for UI
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String amount, IconData icon, Color color, double ratio) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.softGray.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.blueGrey.shade300, size: 20),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppTheme.textBlack,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWealthBreakdown(WealthProvider provider) {
    final double income = provider.monthlyIncome;
    final double expenses = provider.monthlyExpenses;
    final double gold = provider.monthlyGoldAmount;
    
    // Calculate percentages relative to income
    final int expensePct = income > 0 ? ((expenses / income) * 100).round() : 0;
    final int goldPct = income > 0 ? ((gold / income) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.softGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textBlack.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MONTHLY ANALYSIS',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.analytics_outlined, color: Colors.blueGrey.shade100, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          // Expense Bar (Inverted - starting from left but with red)
          _buildAnalysisBar("Expenses", expensePct, AppTheme.expenseRed),
          const SizedBox(height: 16),
          // Gold Bar (Inverted - maybe the user means the logic is focused on gold)
          _buildAnalysisBar("Gold Savings", goldPct, AppTheme.primaryGreen),
          const SizedBox(height: 24),
          Text(
            "This month your expenses are $expensePct% and gold savings are $goldPct% of your income.",
            style: const TextStyle(
              color: AppTheme.textBlack,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisBar(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppTheme.textBlack, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              '$percentage%',
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.softGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (percentage / 100).clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildGoldGoalTracker(WealthProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GOLD GOAL TRACKER',
                  style: TextStyle(
                    color: Color(0xFFE6A500),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Almost there! You\'ve reached ${provider.digitalGoldGrams}g of your ${provider.activeGoldGoalGrams}g goal.',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: provider.activeGoldRatio,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFFFF3CD),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                ),
              ),
              Text(
                '${(provider.activeGoldRatio * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE6A500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textBlack,
            letterSpacing: 0.5,
          ),
        ),
        TextButton(
          onPressed: () {}, // Handled by Activity tab in footer
          child: const Text(
            'VIEW ALL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(WealthProvider provider, NumberFormat format) {
    final recent = provider.transactions.take(3).toList();
    if (recent.isEmpty) {
      return const Center(child: Text('No recent activity'));
    }

    return Column(
      children: recent.map((tx) => _buildActivityItem(tx, format)).toList(),
    );
  }

  Widget _buildActivityItem(Transaction tx, NumberFormat format) {
    final isIncome = tx.type == TransactionType.income;
    final isGold = tx.type == TransactionType.gold;

    IconData icon;
    Color iconColor;
    Color iconBg;

    if (isIncome) {
      icon = Icons.wallet_rounded;
      iconColor = AppTheme.primaryGreen;
      iconBg = AppTheme.primaryGreen.withValues(alpha: 0.1);
    } else if (isGold) {
      icon = Icons.auto_awesome_rounded;
      iconColor = const Color(0xFFFFD54F);
      iconBg = const Color(0xFFFFF8E1);
    } else {
      icon = Icons.shopping_cart_rounded;
      iconColor = Colors.blueGrey;
      iconBg = AppTheme.softGray;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    fontSize: 15,
                    color: AppTheme.textBlack,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(tx.date),
                  style: TextStyle(
                    color: Colors.blueGrey.shade300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${format.format(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIncome ? AppTheme.primaryGreen : AppTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
