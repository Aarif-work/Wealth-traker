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
  String amount = "0.00";
  String? selectedCategory = "Food";

  final List<Map<String, dynamic>> categories = [
    {"label": "Food", "icon": Icons.restaurant_rounded, "color": Colors.orange},
    {"label": "Salary", "icon": Icons.wallet_rounded, "color": Colors.green},
    {"label": "Investment", "icon": Icons.trending_up_rounded, "color": Colors.blue},
    {"label": "Rent", "icon": Icons.home_rounded, "color": Colors.purple},
    {"label": "Shopping", "icon": Icons.shopping_bag_rounded, "color": Colors.pink},
    {"label": "Health", "icon": Icons.health_and_safety_rounded, "color": Colors.red},
    {"label": "Other", "icon": Icons.more_horiz_rounded, "color": Colors.grey},
  ];

  void _onNumberPressed(String value) {
    setState(() {
      if (amount == "0.00") {
        amount = value;
      } else {
        if (value == "." && amount.contains(".")) return;
        // Limit to 2 decimal places
        if (amount.contains(".") && amount.split(".")[1].length >= 2) return;
        // Limit max length
        if (amount.length >= 10) return;
        amount += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
        if (amount.endsWith(".")) amount = amount.substring(0, amount.length - 1);
        if (amount.isEmpty) amount = "0.00";
      } else {
        amount = "0.00";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wealthProvider = Provider.of<WealthProvider>(context, listen: false);
    final themeColor = isExpense ? AppTheme.expenseRed : AppTheme.wealthGreen;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Transaction", 
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildToggle(themeColor),
          const SizedBox(height: 24),
          _buildAmountDisplay(themeColor),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.softGray.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildCategoryList(),
                  const Spacer(),
                  _buildKeypad(),
                  const SizedBox(height: 16),
                  _buildSaveButton(wealthProvider, themeColor),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(Color activeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.softGray,
        borderRadius: BorderRadius.circular(27),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isExpense ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isExpense = true),
                  child: Center(
                    child: Text(
                      "EXPENSE",
                      style: TextStyle(
                        color: isExpense ? AppTheme.expenseRed : Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isExpense = false),
                  child: Center(
                    child: Text(
                      "INCOME",
                      style: TextStyle(
                        color: !isExpense ? AppTheme.wealthGreen : Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
            color: Colors.grey.shade500, 
            fontSize: 12, 
            fontWeight: FontWeight.w700, 
            letterSpacing: 1.5
          )
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "₹",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 56, 
                fontWeight: FontWeight.w800, 
                color: AppTheme.textBlack,
                letterSpacing: -1,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Category", 
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat['label'];
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = cat['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.textBlack : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'], 
                        size: 18, 
                        color: isSelected ? Colors.white : cat['color']
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cat['label'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textBlack,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
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
      [".", "0", "DEL"],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    _onBackspace
                  );
                }
                return _buildKeyBtn(
                  Text(
                    key, 
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppTheme.textBlack)
                  ), 
                  () => _onNumberPressed(key)
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyBtn(Widget child, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSaveButton(WealthProvider provider, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_rounded, size: 24),
              SizedBox(width: 12),
              Text(
                "Save Transaction", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
