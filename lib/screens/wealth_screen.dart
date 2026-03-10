import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

// Strongly-typed model for character cards
// Local HelpCharacter is removed, using the one from WealthProvider

class WealthScreen extends StatefulWidget {
  const WealthScreen({super.key});

  @override
  State<WealthScreen> createState() => _WealthScreenState();
}

class _WealthScreenState extends State<WealthScreen> {
  bool _isProcessing = false;
  bool _isProcessingDone = false;
  bool _showThankYou = false;
  HelpCharacter? _currentActiveChar;

  void _startHelpProcess(HelpCharacter char, WealthProvider provider) async {
    setState(() {
      _currentActiveChar = char;
      _isProcessing = true;
      _isProcessingDone = false;
    });

    // Simulated "Gold Inverse Process" delay
    await Future.delayed(const Duration(seconds: 3));

    await provider.helpSave(char.id);
    
    if (mounted) {
      setState(() {
        _isProcessingDone = true;
      });
    }
  }

  void _completeProcess() async {
    setState(() {
      _isProcessing = false;
      _isProcessingDone = false;
      _showThankYou = true;
    });

    // Show Thank You for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showThankYou = false;
        _currentActiveChar = null;
      });
    }
  }

  void _confirmDeleteCharacter(BuildContext context, HelpCharacter char, WealthProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Character?", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to remove ${char.name}? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCharacter(char.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("DELETE", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAddCharacterSheet(BuildContext context, WealthProvider provider) {
    String name = "";
    double amount = 0;
    bool toGold = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 450,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("New Character", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textBlack)),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: "Character Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Amount (₹)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("GOLD"),
                    selected: toGold,
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    onSelected: (val) => setState(() => toGold = true),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("SAVINGS"),
                    selected: !toGold,
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                    onSelected: (val) => setState(() => toGold = false),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && amount > 0) {
                      provider.addNewCharacter(HelpCharacter(
                        id: DateTime.now().toString(),
                        tag: 'PERSONAL',
                        tagColorValue: 0xFF1B5E20,
                        name: name,
                        message: 'Every help matters for our destiny.',
                        amount: amount,
                        iconCodePoint: 0xe491, // person_rounded
                        avatarBgValue: 0xFFE8F5E9,
                        avatarFgValue: 0xFF2E7D32,
                        badgeIconCodePoint: 0xe5fa, // stars_rounded
                        badgeColorValue: 0xFF00F04F,
                        isGold: toGold,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.textBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("ADD TO LIST", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final provider = Provider.of<WealthProvider>(context);

    // Calculate real impact from transactions
    final helpSaveTotal = provider.transactions
        .where((tx) => tx.title.startsWith('Help Save:'))
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final displayImpact = helpSaveTotal;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, provider),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    children: [
                      _buildHeroText(),
                      const SizedBox(height: 28),
                      _buildImpactBanner(displayImpact, currencyFormat),
                      const SizedBox(height: 32),
                      ...provider.characters.map((char) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildHelpCard(context, char, currencyFormat, provider),
                      )),
                      const SizedBox(height: 32),
                      _buildHelpLogs(provider, currencyFormat),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isProcessing) _buildProcessingOverlay(),
        if (_showThankYou) _buildThankYouOverlay(),
      ],
    );
  }

  Widget _buildHelpLogs(WealthProvider provider, NumberFormat format) {
    final helpLogs = provider.transactions.where((tx) => tx.title.startsWith('Help Save:')).toList();
    if (helpLogs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("HELP LOGS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.textGray)),
        const SizedBox(height: 16),
        ...helpLogs.map((tx) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.title.replaceFirst('Help Save:', '').trim(), style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(format.format(tx.amount), style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, WealthProvider provider) {
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
          GestureDetector(
            onTap: () => _showAddCharacterSheet(context, provider),
            child: _appBarButton(Icons.person_add_alt_1_rounded),
          ),
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
            color: AppTheme.textBlack.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.textBlack.withValues(alpha: 0.04)),
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
          colors: [AppTheme.primaryGreen.withValues(alpha: 0.1), AppTheme.primaryGreen.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppTheme.primaryGreen, size: 14),
                    SizedBox(width: 4),
                    Text(
                      '12%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
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
    bool canHelp = char.canHelpThisMonth;
    Color tagColor = Color(char.tagColorValue);
    Color avatarBg = Color(char.avatarBgValue);
    Color avatarFg = Color(char.avatarFgValue);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: tagColor.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: AppTheme.textBlack.withValues(alpha: 0.02), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              IconData(char.iconCodePoint, fontFamily: 'MaterialIcons'),
              size: 160,
              color: tagColor.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: avatarBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: avatarFg.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Icon(IconData(char.iconCodePoint, fontFamily: 'MaterialIcons'), color: avatarFg, size: 34),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(char.badgeColorValue),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: Icon(IconData(char.badgeIconCodePoint, fontFamily: 'MaterialIcons'), size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
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
                                  color: tagColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(char.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: tagColor, letterSpacing: 1.0)),
                              ),
                              if (char.currentHelpedCount == 0)
                                GestureDetector(
                                  onTap: () => _confirmDeleteCharacter(context, char, provider),
                                  child: Icon(Icons.delete_outline_rounded, color: Colors.red.withValues(alpha: 0.3), size: 20),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(char.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textBlack, letterSpacing: -0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: avatarBg.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4)),
                    border: Border.all(color: avatarBg.withValues(alpha: 0.8)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, color: avatarFg.withValues(alpha: 0.4), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"${char.message}"',
                          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade800, fontStyle: FontStyle.italic, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Help amount', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(format.format(char.amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textBlack, letterSpacing: -1)),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: (canHelp ? AppTheme.primaryGreen : Colors.grey).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: canHelp ? () => _startHelpProcess(char, provider) : null,
                        icon: Icon(canHelp ? Icons.favorite_rounded : Icons.check_circle_rounded, size: 18),
                        label: Text(canHelp ? 'HELP' : 'DONE', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canHelp ? AppTheme.primaryGreen : Colors.grey.shade300,
                          foregroundColor: canHelp ? AppTheme.textBlack : Colors.grey,
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

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isProcessingDone)
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen), strokeWidth: 8)
          else
            const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 80),
          const SizedBox(height: 40),
          Text(
            _isProcessingDone ? "Process Complete!" : "Inverse Gold Process Running...",
            style: const TextStyle(color: AppTheme.textBlack, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            _isProcessingDone ? "Your impact is now secured into gold assets." : "Securing your impact into gold assets.",
            style: const TextStyle(color: AppTheme.textGray, fontSize: 16),
          ),
          if (_isProcessingDone) ...[
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                onPressed: _completeProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.textBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThankYouOverlay() {
    return Container(
      color: AppTheme.primaryGreenSoft,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded, color: AppTheme.primaryGreen, size: 200),
          const SizedBox(height: 40),
          const Text(
            "THANK YOU!",
            style: TextStyle(color: AppTheme.textBlack, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "${_currentActiveChar?.name} is very happy now! You've made a real difference today.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGray, fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
