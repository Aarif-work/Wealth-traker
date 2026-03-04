import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

// Strongly-typed model for character cards
class HelpCharacter {
  final String tag;
  final Color tagColor;
  final String name;
  final String sideLabel;
  final String message;
  final double amount;
  final IconData icon;
  final Color avatarBg;
  final Color avatarFg;
  final IconData badgeIcon;
  final Color badgeColor;
  final bool isGold;

  const HelpCharacter({
    required this.tag,
    required this.tagColor,
    required this.name,
    required this.sideLabel,
    required this.message,
    required this.amount,
    required this.icon,
    required this.avatarBg,
    required this.avatarFg,
    required this.badgeIcon,
    required this.badgeColor,
    required this.isGold,
  });
}

class WealthScreen extends StatefulWidget {
  const WealthScreen({super.key});

  @override
  State<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends State<WealthScreen> {
  double _localImpact = 4250.0;

  static const List<HelpCharacter> characters = [
    HelpCharacter(
      tag: 'WIFE',
      tagColor: Color(0xFFFFA000), // Amber
      name: 'Future Home',
      sideLabel: 'Target: ₹2L',
      message: 'Could you help with our future home? Every little bit counts.',
      amount: 500.0,
      icon: Icons.woman_rounded,
      avatarBg: Color(0xFFFFF3E0),
      avatarFg: Color(0xFFFF9800),
      badgeIcon: Icons.favorite_rounded,
      badgeColor: Color(0xFFFF5252),
      isGold: false,
    ),
    HelpCharacter(
      tag: 'MOTHER',
      tagColor: Color(0xFF1976D2), // Blue
      name: 'Healthcare Fund',
      sideLabel: 'Safety Net',
      message: 'Let\'s save for medicine, just in case. Health comes first.',
      amount: 200.0,
      icon: Icons.elderly_woman_rounded,
      avatarBg: Color(0xFFE3F2FD),
      avatarFg: Color(0xFF1976D2),
      badgeIcon: Icons.health_and_safety_rounded,
      badgeColor: Color(0xFF2196F3),
      isGold: false,
    ),
    HelpCharacter(
      tag: 'FUTURE CHILD',
      tagColor: Color(0xFFC2185B), // Pink/Purple
      name: 'Education Fund',
      sideLabel: 'Long-term',
      message: 'Every penny secures a brighter tomorrow and better education.',
      amount: 1000.0,
      icon: Icons.child_care_rounded,
      avatarBg: Color(0xFFFCE4EC),
      avatarFg: Color(0xFFC2185B),
      badgeIcon: Icons.school_rounded,
      badgeColor: Color(0xFFFF9800),
      isGold: true,
    ),
    HelpCharacter(
      tag: 'EMERGENCY',
      tagColor: Color(0xFFD32F2F), // Red
      name: 'Emergency Fund',
      sideLabel: 'Critical',
      message: 'Being prepared protects you from life\'s sudden surprises.',
      amount: 250.0,
      icon: Icons.shield_rounded,
      avatarBg: Color(0xFFFFEBEE),
      avatarFg: Color(0xFFD32F2F),
      badgeIcon: Icons.bolt_rounded,
      badgeColor: Color(0xFFFF9800),
      isGold: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final provider = Provider.of<WealthProvider>(context);

    // Calculate real impact from transactions
    final helpSaveTotal = provider.transactions
        .where((tx) => tx.title.startsWith('Help Save:'))
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final displayImpact = _localImpact + helpSaveTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // Minimalist light grey/white background
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                children: [
                  _buildHeroText(),
                  const SizedBox(height: 28),
                  _buildImpactBanner(displayImpact, currencyFormat),
                  const SizedBox(height: 32),
                  ...characters.map((char) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildHelpCard(context, char, currencyFormat, provider),
                  )),
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
            'Help & Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          _appBarButton(Icons.info_outline_rounded),
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

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Turn your savings into a\nmeaningful act of care.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.textBlack,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Emotional motivators for your financial discipline.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactBanner(double total, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF6E5), const Color(0xFFFFEAB8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFEAB8).withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TOTAL IMPACT SAVED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.brown.shade400,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                format.format(total),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textBlack,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: Color(0xFF00C853), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '12%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context,
    HelpCharacter char,
    NumberFormat format,
    WealthProvider provider,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias, // Ensures watermark stays inside
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: char.tagColor.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.02), width: 1.5),
      ),
      child: Stack(
        children: [
          // Background Icon Watermark
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              char.icon,
              size: 160,
              color: char.tagColor.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Area
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Enhanced Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: char.avatarBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: char.avatarFg.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(char.icon, color: char.avatarFg, size: 34),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: char.badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: Icon(char.badgeIcon, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Name & Tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: char.tagColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  char.tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: char.tagColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              Text(
                                char.sideLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey.shade300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            char.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textBlack,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Quoted Message Bubble
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: char.avatarBg.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4), // Tail effect
                    ),
                    border: Border.all(color: char.avatarBg.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: char.avatarFg.withValues(alpha: 0.4), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"${char.message}"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey.shade800,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Amount & Help Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          format.format(char.amount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textBlack,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.helpSave(char.name, char.amount, char.isGold);
                          setState(() => _localImpact += char.amount);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${format.format(char.amount)} saved for ${char.name} 💚',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.textBlack,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        label: const Text(
                          'HELP',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB800), // vibrant amber-gold
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
