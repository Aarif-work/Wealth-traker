import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  String amount = "0";
  String? selectedCategory = "Food";

  final List<Map<String, dynamic>> categories = [
    {"label": "Food", "icon": Icons.restaurant_rounded, "color": const Color(0xFFFFB74D)}, // Soft Orange
    {"label": "Salary", "icon": Icons.wallet_rounded, "color": AppTheme.primaryGreen},
    {"label": "Investment", "icon": Icons.trending_up_rounded, "color": const Color(0xFF64B5F6)}, // Soft Blue
    {"label": "Rent", "icon": Icons.home_rounded, "color": const Color(0xFFBA68C8)}, // Soft Purple
    {"label": "Shopping", "icon": Icons.shopping_bag_rounded, "color": const Color(0xFFF06292)}, // Soft Pink
    {"label": "Health", "icon": Icons.health_and_safety_rounded, "color": const Color(0xFFE57373)}, // Soft Red
    {"label": "Other", "icon": Icons.more_horiz_rounded, "color": Colors.blueGrey.shade100},
  ];

  void _onNumberPressed(String value) {
    setState(() {
      if (amount == "0") {
        if (value == "0" || value == "00") return;
        amount = value;
      } else {
        if (amount.length + value.length > 10) return;
        amount += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
        if (amount.endsWith(".")) amount = amount.substring(0, amount.length - 1);
        if (amount.isEmpty) amount = "0";
      } else {
        amount = "0";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wealthProvider = Provider.of<WealthProvider>(context, listen: false);
    final themeColor = isExpense ? const Color(0xFFE53935) : AppTheme.primaryGreen;
    final bgGradientColor = Colors.white;

    return Scaffold(
      backgroundColor: bgGradientColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppTheme.textGray, size: 28),
        ),
        title: const Text(
          "New Transaction", 
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppTheme.textBlack,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            // Swipe Right -> Switch to Expense
            if (!isExpense) setState(() => isExpense = true);
          } else if (details.primaryVelocity! < -500) {
            // Swipe Left -> Switch to Income
            if (isExpense) setState(() => isExpense = false);
          }
        },
        child: Column(
          children: [
          const SizedBox(height: 16),
          _buildToggle(themeColor),
          const SizedBox(height: 32),
          _buildAmountDisplay(themeColor),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: themeColor.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, -10)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildCategoryList(),
                  const Spacer(),
                  _buildKeypad(),
                  const SizedBox(height: 24),
                  _buildSaveButton(wealthProvider, themeColor),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildToggle(Color activeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.softGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            alignment: isExpense ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isExpense = true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "EXPENSE",
                      style: TextStyle(
                        color: isExpense ? const Color(0xFFE53935) : Colors.blueGrey.shade400,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isExpense = false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "INCOME",
                      style: TextStyle(
                        color: !isExpense ? AppTheme.primaryGreen : Colors.blueGrey.shade400,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(Color color) {
    return Column(
      children: [
        Text(
          "ENTER AMOUNT", 
          style: TextStyle(
            color: color.withValues(alpha: 0.6), 
            fontSize: 12, 
            fontWeight: FontWeight.w800, 
            letterSpacing: 2.0
          )
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "₹",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              amount,
              style: TextStyle(
                fontSize: 64, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.textBlack,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            "Category", 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800, letterSpacing: 0.5)
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat['label'];
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: isSelected ? cat['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: isSelected ? [
                      BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
                    ] : [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5, offset: const Offset(0, 2))
                    ],
                    border: isSelected ? null : Border.all(color: Colors.black.withValues(alpha: 0.04)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'], 
                        size: 20, 
                        color: isSelected ? Colors.white : (cat['color'] as Color).withValues(alpha: 0.8)
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          cat['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["00", "0", "DEL"],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == "DEL") {
                  return _buildKeyBtn(
                    const Icon(Icons.backspace_rounded, size: 24, color: AppTheme.textBlack), 
                    _onBackspace,
                    true
                  );
                }
                return _buildKeyBtn(
                  Text(
                    key, 
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w800, 
                      color: AppTheme.textBlack.withValues(alpha: 0.8),
                    )
                  ), 
                  () => _onNumberPressed(key),
                  false
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton(WealthProvider provider, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final double val = double.tryParse(amount) ?? 0.0;
            if (val > 0) {
              if (isExpense) {
                provider.addExpense(selectedCategory ?? "Other", val);
              } else {
                provider.addIncome(selectedCategory ?? "Other", val);
              }
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_rounded, size: 22),
              SizedBox(width: 12),
              Text(
                "SAVE TRANSACTION", 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildKeyBtn(Widget child, VoidCallback onTap, bool isAction) {
    return _TactileButton(
      onTap: onTap,
      isAction: isAction,
      child: child,
    );
  }
}

class _TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isAction;

  const _TactileButton({
    required this.child,
    required this.onTap,
    required this.isAction,
  });

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 85,
            height: 65,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isAction ? Colors.white.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!widget.isAction)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

}
