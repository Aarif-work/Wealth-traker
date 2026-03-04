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

class WealthProvider with ChangeNotifier {
  double _cashSavings = 12500.0;
  final double _cashSavingsGoal = 25000.0; // Goal: $250,000
  double _digitalGoldInGrams = 0.45; // 0.45 grams
  final double _goldGoldInGrams = 1.0; // Goal: 1 gram
  final double _goldPricePerGram = 6500.0; // Simulated gold price
  final double _lendingLimit = 2000.0; // Monthly lending limit

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
  double get goldGoldInGrams => _goldGoldInGrams;
  double get goldRatio => (_digitalGoldInGrams / _goldGoldInGrams).clamp(0.0, 1.0);
  double get goldValue => _digitalGoldInGrams * _goldPricePerGram;
  double get totalWealth => _cashSavings + goldValue;
  List<Transaction> get transactions => [..._transactions.reversed];
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

  double get netBalance => monthlyIncome - monthlyExpenses;

  // Actions
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

  void helpSave(String name, double amount, bool toGold) {
    if (toGold) {
      final grams = amount / _goldPricePerGram;
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: $name (Gold)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.gold,
      );
      _digitalGoldInGrams += grams;
      _transactions.add(newTransaction);
    } else {
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: $name (Savings)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.income,
      );
      _cashSavings += amount;
      _transactions.add(newTransaction);
    }
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
