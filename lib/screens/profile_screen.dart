import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _currentTime;
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    final now = DateTime.now();
    _currentTime = DateFormat('hh:mm a').format(now);
    _currentDate = DateFormat('EEEE, d MMM').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WealthProvider>(context);
    final totalWealth = provider.totalWealth;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildWealthQuickView(totalWealth, currencyFormat),
                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.shrink(),
          Positioned(
            right: 0,
            child: Icon(Icons.settings_outlined, color: Colors.blueGrey.shade300, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/image.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 25, offset: const Offset(0, 12)),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: const Icon(Icons.edit_outlined, size: 16, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Master Wayne",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textBlack, letterSpacing: -1.0),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.calendar_today_rounded, size: 12, color: Colors.blueGrey.shade300),
             const SizedBox(width: 6),
             Text(
              "$_currentDate • $_currentTime",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade300),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWealthQuickView(double total, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryGreenSoft, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Wealth", style: TextStyle(color: AppTheme.textGray, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(format.format(total), style: const TextStyle(color: AppTheme.textBlack, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, color: Colors.blueGrey.shade100),
        ],
      ),
    );
  }



}
