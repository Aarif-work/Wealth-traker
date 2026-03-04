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

    return SafeArea(
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
    );
  }

  Widget _buildHeader() {
    return Column(
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
          'Good Evening!',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade300,
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
          color: Colors.black.withValues(alpha: 0.04),
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
            const Color(0xFF00E676), // Vibrant green
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
    // Simplified breakdown logic based on current balances
    final double total = provider.totalWealth;
    final double cashRatio = total > 0 ? provider.cashSavings / total : 0.7;
    final double goldRatio = 1.0 - cashRatio;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (cashRatio * 100).toInt(),
                    child: Container(color: const Color(0xFF00E676)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: (goldRatio * 100).toInt(),
                    child: Container(color: const Color(0xFFFFD54F)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('Cash Savings', (cashRatio * 100).toInt(), const Color(0xFF00E676)),
              _buildLegendItem('Digital Gold', (goldRatio * 100).toInt(), const Color(0xFFFFD54F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($percentage%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey.shade600,
          ),
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
                  'Almost there! You\'ve reached ${provider.digitalGoldGrams}g of your ${provider.goldGoldInGrams}g goal.',
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
                  value: provider.goldRatio,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFFFF3CD),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                ),
              ),
              Text(
                '${(provider.goldRatio * 100).toInt()}%',
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
              color: Color(0xFF00E676),
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
      iconColor = const Color(0xFF00E676);
      iconBg = const Color(0xFFE8F5E9);
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
              color: isIncome ? const Color(0xFF00E676) : AppTheme.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
