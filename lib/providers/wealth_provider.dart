import 'package:flutter/foundation.dart';

enum TransactionType { income, expense, gold }

class Lending {
  final String id;
  final String personName;
  final double amount;
  final DateTime dueDate;
  bool isReturned;

  Lending({
    required this.id,
    required this.personName,
    required this.amount,
    required this.dueDate,
    this.isReturned = false,
  });
}

class FinancialGoal {
  final String id;
  final double targetWealth;
  final double targetGoldGrams;
  final int targetHelpActivities;
  final double startingWealth;
  final double startingGoldGrams;
  final int startingHelpCount;
  final DateTime startDate;
  bool isCompleted;

  FinancialGoal({
    required this.id,
    required this.targetWealth,
    required this.targetGoldGrams,
    required this.targetHelpActivities,
    required this.startingWealth,
    required this.startingGoldGrams,
    required this.startingHelpCount,
    required this.startDate,
    this.isCompleted = false,
  });
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class HelpCharacter {
  final String id;
  final String tag;
  final int tagColorValue;
  final String name;
  final String message;
  final double amount;
  final int iconCodePoint;
  final int avatarBgValue;
  final int avatarFgValue;
  final int badgeIconCodePoint;
  final int badgeColorValue;
  final bool isGold;
  int currentHelpedCount;
  DateTime? lastHelpedDate;

  HelpCharacter({
    required this.id,
    required this.tag,
    required this.tagColorValue,
    required this.name,
    required this.message,
    required this.amount,
    required this.iconCodePoint,
    required this.avatarBgValue,
    required this.avatarFgValue,
    required this.badgeIconCodePoint,
    required this.badgeColorValue,
    required this.isGold,
    this.currentHelpedCount = 0,
    this.lastHelpedDate,
  });

  bool get canHelpThisMonth {
    if (lastHelpedDate == null) return true;
    final now = DateTime.now();
    return (lastHelpedDate!.month != now.month || lastHelpedDate!.year != now.year);
  }
}

class WealthProvider with ChangeNotifier {
  double _cashSavings = 12500.0;
  final double _cashSavingsGoal = 25000.0; 
  
  double _digitalGoldInGrams = 0.45; // 0.45 grams
  final double _goldPricePerGram = 6500.0; // Simulated gold price
  final double _lendingLimit = 2000.0; // Monthly lending limit

  final List<FinancialGoal> _goals = [
    FinancialGoal(
      id: 'g1',
      targetWealth: 50000.0,
      targetGoldGrams: 1.0,
      targetHelpActivities: 5,
      startingWealth: 10000.0,
      startingGoldGrams: 0.4,
      startingHelpCount: 2,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  final List<HelpCharacter> _characters = [
    HelpCharacter(
      id: 'c1',
      tag: 'WIFE',
      tagColorValue: 0xFFFFA000,
      name: 'Future Home',
      message: 'Could you help with our future home? Every little bit counts.',
      amount: 500.0,
      iconCodePoint: 0xe6bb, // woman_rounded
      avatarBgValue: 0xFFFFF3E0,
      avatarFgValue: 0xFFFF9800,
      badgeIconCodePoint: 0xe25b, // favorite_rounded
      badgeColorValue: 0xFFFF5252,
      isGold: false,
    ),
    HelpCharacter(
      id: 'c2',
      tag: 'MOTHER',
      tagColorValue: 0xFF1976D2,
      name: 'Healthcare Fund',
      message: 'Let\'s save for medicine, just in case. Health comes first.',
      amount: 200.0,
      iconCodePoint: 0xe21f, // elderly_woman_rounded
      avatarBgValue: 0xFFE3F2FD,
      avatarFgValue: 0xFF1976D2,
      badgeIconCodePoint: 0xe2e4, // health_and_safety_rounded
      badgeColorValue: 0xFF2196F3,
      isGold: false,
    ),
  ];

  final List<Lending> _lendingList = [
    Lending(
      id: 'l1',
      personName: 'Alex Smith',
      amount: 450.0,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isReturned: false,
    ),
    Lending(
      id: 'l2',
      personName: 'Sarah J.',
      amount: 120.0,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      isReturned: true,
    ),
  ];

  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      title: 'Salary Credit',
      amount: 5000.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: TransactionType.income,
    ),
    Transaction(
      id: '2',
      title: 'Grocery Shopping',
      amount: 150.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
    ),
    Transaction(
      id: '3',
      title: 'Bought 0.05g Gold',
      amount: 325.0,
      date: DateTime.now(),
      type: TransactionType.gold,
    ),
  ];

  // Getters
  double get cashSavings => _cashSavings;
  double get cashSavingsGoal => _cashSavingsGoal;
  double get savingsRatio => (_cashSavings / _cashSavingsGoal).clamp(0.0, 1.0);
  double get digitalGoldGrams => _digitalGoldInGrams;
  double get goldPricePerGram => _goldPricePerGram;
  double get goldValue => _digitalGoldInGrams * _goldPricePerGram;
  double get totalWealth => _cashSavings + goldValue;
  List<FinancialGoal> get goals => [..._goals];
  
  double get activeGoldGoalGrams {
    if (_goals.isEmpty) return 1.0;
    return _goals.last.targetGoldGrams;
  }
  
  double get activeGoldRatio {
    if (_goals.isEmpty) return (_digitalGoldInGrams / 1.0).clamp(0.0, 1.0);
    final goal = _goals.last;
    final currentGoldGained = (_digitalGoldInGrams - goal.startingGoldGrams).clamp(0.0, 999.0);
    return (currentGoldGained / goal.targetGoldGrams).clamp(0.0, 1.0);
  }

  // Total help activities for lifetime
  int get totalHelpActivitiesCount => _transactions.where((t) => t.title.startsWith('Help Save')).length;

  List<Transaction> get transactions => [..._transactions.reversed];
  List<HelpCharacter> get characters => _characters;
  
  void addNewGoal(double wealthTarget, double goldTarget, int helpTarget) {
    _goals.add(FinancialGoal(
      id: DateTime.now().toString(),
      targetWealth: wealthTarget,
      targetGoldGrams: goldTarget,
      targetHelpActivities: helpTarget,
      startingWealth: totalWealth,
      startingGoldGrams: _digitalGoldInGrams,
      startingHelpCount: totalHelpActivitiesCount,
      startDate: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateGoal(String id, double wealthTarget, double goldTarget, int helpTarget) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final old = _goals[index];
      _goals[index] = FinancialGoal(
        id: old.id,
        targetWealth: wealthTarget,
        targetGoldGrams: goldTarget,
        targetHelpActivities: helpTarget,
        startingWealth: old.startingWealth,
        startingGoldGrams: old.startingGoldGrams,
        startingHelpCount: old.startingHelpCount,
        startDate: old.startDate,
        isCompleted: old.isCompleted,
      );
      notifyListeners();
    }
  }
  List<Lending> get lendingList => [..._lendingList];
  double get lendingLimit => _lendingLimit;
  double get currentLent => _lendingList.where((l) => !l.isReturned).fold(0.0, (sum, l) => sum + l.amount);
  double get lendingRatio => (currentLent / _lendingLimit).clamp(0.0, 1.0);

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.income && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyGoldAmount {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.gold && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => monthlyIncome - monthlyExpenses - monthlyGoldAmount;

  // Actions
  void addNewCharacter(HelpCharacter character) {
    _characters.add(character);
    notifyListeners();
  }

  void addLending(String name, double amount, DateTime dueDate) {
    _lendingList.add(Lending(
      id: DateTime.now().toString(),
      personName: name,
      amount: amount,
      dueDate: dueDate,
      isReturned: false,
    ));
    _cashSavings -= amount;
    notifyListeners();
  }

  void toggleLendingStatus(String id) {
    final index = _lendingList.indexWhere((l) => l.id == id);
    if (index != -1) {
      final lending = _lendingList[index];
      lending.isReturned = !lending.isReturned;
      if (lending.isReturned) {
        _cashSavings += lending.amount;
      } else {
        _cashSavings -= lending.amount;
      }
      notifyListeners();
    }
  }

  Future<void> helpSave(String charId) async {
    final index = _characters.indexWhere((c) => c.id == charId);
    if (index == -1) return;
    
    final char = _characters[index];
    if (!char.canHelpThisMonth) return;

    final amount = char.amount;
    final toGold = char.isGold;

    if (toGold) {
      final grams = amount / _goldPricePerGram;
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: ${char.name} (Gold)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.gold,
      );
      _digitalGoldInGrams += grams;
      _transactions.add(newTransaction);
    } else {
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: ${char.name} (Savings)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.income,
      );
      _cashSavings += amount;
      _transactions.add(newTransaction);
    }

    char.currentHelpedCount++;
    char.lastHelpedDate = DateTime.now();
    
    notifyListeners();
  }

  void addIncome(String title, double amount) {
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.income,
    );
    _cashSavings += amount;
    _transactions.add(newTransaction);
    notifyListeners();
  }

  void addExpense(String title, double amount) {
    if (_cashSavings < amount) return; // Simple check
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.expense,
    );
    _cashSavings -= amount;
    _transactions.add(newTransaction);
    notifyListeners();
  }

  void buyGold(double grams) {
    final cost = grams * _goldPricePerGram;
    if (_cashSavings < cost) return;
    
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: 'Bought ${grams}g Gold',
      amount: cost,
      date: DateTime.now(),
      type: TransactionType.gold,
    );
    _cashSavings -= cost;
    _digitalGoldInGrams += grams;
    _transactions.add(newTransaction);
    notifyListeners();
  }
}
