import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/database_service.dart';

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
  final String note;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.note = "",
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
  final DatabaseService _dbService = DatabaseService();
  bool _isInitialized = false;

  double _cashSavings = 0.0;
  final double _cashSavingsGoal = double.parse(dotenv.get('CASH_SAVINGS_GOAL', fallback: '25000.0')); 
  
  double _digitalGoldInGrams = 0.0;
  final double _goldPricePerGram = double.parse(dotenv.get('GOLD_PRICE_PER_GRAM', fallback: '6500.0')); 
  final double _lendingLimit = double.parse(dotenv.get('LENDING_LIMIT', fallback: '2000.0')); 

  List<FinancialGoal> _goals = [
    FinancialGoal(
      id: 'g-initial',
      targetWealth: 50000.0,
      targetGoldGrams: 1.0,
      targetHelpActivities: 5,
      startingWealth: 0.0,
      startingGoldGrams: 0.0,
      startingHelpCount: 0,
      startDate: DateTime.now(),
    ),
  ];

  List<HelpCharacter> _characters = [];

  final List<Lending> _lendingList = [];

  List<Transaction> _transactions = [];

  bool get isInitialized => _isInitialized;

  WealthProvider() {
    initialize();
  }

  Future<void> initialize() async {
    print("WealthProvider: Initializing...");
    try {
      final profile = await _dbService.fetchProfile();
      
      if (profile != null) {
        print("WealthProvider: Found profile in cloud. Loading data...");
        _cashSavings = (profile['cashSavings'] as num).toDouble();
        _digitalGoldInGrams = (profile['digitalGoldInGrams'] as num).toDouble();
        
        _transactions = await _dbService.fetchTransactions();
        _goals = await _dbService.fetchGoals();
        _characters = await _dbService.fetchCharacters();
        print("WealthProvider: Data loaded successfully. Txs: ${_transactions.length}, Goals: ${_goals.length}");
      } else {
        print("WealthProvider: No profile found. Initializing clean state...");
        // Ensure starting with zero/empty
        _cashSavings = 0.0;
        _digitalGoldInGrams = 0.0;
        _transactions = [];
        _characters = [];
        _goals = [
          FinancialGoal(
            id: 'g-initial-${DateTime.now().millisecondsSinceEpoch}',
            targetWealth: 50000.0,
            targetGoldGrams: 1.0,
            targetHelpActivities: 5,
            startingWealth: 0.0,
            startingGoldGrams: 0.0,
            startingHelpCount: 0,
            startDate: DateTime.now(),
          ),
        ];

        await _syncProfile();
        for (var goal in _goals) { await _dbService.saveGoal(goal); }
      }
    } catch (e) {
      print("WealthProvider: Error during initialization: $e");
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _syncProfile() async {
    await _dbService.updateProfile(_cashSavings, _digitalGoldInGrams);
  }

  Future<void> wipeDataAndReset() async {
    _isInitialized = false;
    notifyListeners();
    
    await _dbService.resetUserData();
    
    _cashSavings = 0.0;
    _digitalGoldInGrams = 0.0;
    _transactions = [];
    _characters = [];
    _goals = [
      FinancialGoal(
        id: 'g-initial-${DateTime.now().millisecondsSinceEpoch}',
        targetWealth: 50000.0,
        targetGoldGrams: 1.0,
        targetHelpActivities: 5,
        startingWealth: 0.0,
        startingGoldGrams: 0.0,
        startingHelpCount: 0,
        startDate: DateTime.now(),
      ),
    ];

    await _syncProfile();
    for (var goal in _goals) { await _dbService.saveGoal(goal); }
    
    _isInitialized = true;
    notifyListeners();
  }

  // Getters
  double get cashSavings => _cashSavings;
  double get cashSavingsGoal => _cashSavingsGoal;
  double get savingsRatio => (_cashSavings / _cashSavingsGoal).clamp(0.0, 1.0);
  double get digitalGoldGrams => _digitalGoldInGrams;
  double get goldPricePerGram => _goldPricePerGram;
  double get goldValue => _digitalGoldInGrams * _goldPricePerGram;
  double get totalWealth => goldValue; // Total Wealth is now defined as exclusively Gold Value
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
  
  Future<void> addNewGoal(double wealthTarget, double goldTarget, int helpTarget) async {
    final goal = FinancialGoal(
      id: DateTime.now().toString(),
      targetWealth: wealthTarget,
      targetGoldGrams: goldTarget,
      targetHelpActivities: helpTarget,
      startingWealth: totalWealth,
      startingGoldGrams: _digitalGoldInGrams,
      startingHelpCount: totalHelpActivitiesCount,
      startDate: DateTime.now(),
    );
    _goals.add(goal);
    await _dbService.saveGoal(goal);
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

  double get availableBalance {
    final income = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final goldSpent = _transactions
        .where((t) => t.type == TransactionType.gold)
        .fold(0.0, (sum, t) => sum + t.amount);
        
    // Balance is purely money from salary/income minus what was spent on expenses and gold
    return income - expenses - goldSpent;
  }

  double get bankBalance => availableBalance;

  double get netBalance => monthlyIncome - monthlyExpenses - monthlyGoldAmount;

  // Actions
  Future<void> addNewCharacter(HelpCharacter character) async {
    _characters.add(character);
    await _dbService.saveCharacter(character);
    notifyListeners();
  }

  Future<void> deleteCharacter(String id) async {
    _characters.removeWhere((c) => c.id == id);
    await _dbService.deleteCharacter(id);
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

    Transaction tx;
    if (toGold) {
      final grams = amount / _goldPricePerGram;
      tx = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: ${char.name} (Gold)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.gold,
      );
      _digitalGoldInGrams += grams;
    } else {
      tx = Transaction(
        id: DateTime.now().toString(),
        title: 'Help Save: ${char.name} (Savings)',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.income,
      );
      _cashSavings += amount;
    }

    _transactions.add(tx);
    char.currentHelpedCount++;
    char.lastHelpedDate = DateTime.now();
    
    await _dbService.saveTransaction(tx);
    await _dbService.saveCharacter(char);
    await _syncProfile();
    notifyListeners();
  }

  Future<void> addIncome(String title, double amount, {String note = ""}) async {
    final tx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.income,
      note: note,
    );
    _cashSavings += amount;
    _transactions.add(tx);
    await _dbService.saveTransaction(tx);
    await _syncProfile();
    notifyListeners();
  }

  Future<void> addExpense(String title, double amount, {String note = ""}) async {
    if (_cashSavings < amount) return; // Simple check
    final tx = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.expense,
      note: note,
    );
    _cashSavings -= amount;
    _transactions.add(tx);
    await _dbService.saveTransaction(tx);
    await _syncProfile();
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

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = _transactions[index];
      
      // Reverse the financial impact
      if (tx.type == TransactionType.income) {
        _cashSavings -= tx.amount;
      } else if (tx.type == TransactionType.expense) {
        _cashSavings += tx.amount;
      } else if (tx.type == TransactionType.gold) {
        _cashSavings += tx.amount;
        final grams = tx.amount / _goldPricePerGram;
        _digitalGoldInGrams -= grams;
      }
      
      _transactions.removeAt(index);
      await _dbService.deleteTransaction(id);
      await _syncProfile();
      notifyListeners();
    }
  }

  Future<void> buyGoldByAmount(double amount, {String note = ""}) async {
    if (_cashSavings < amount) return;
    final grams = amount / _goldPricePerGram;
    
    final tx = Transaction(
      id: DateTime.now().toString(),
      title: 'Digital Gold',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.gold,
      note: note,
    );
    _cashSavings -= amount;
    _digitalGoldInGrams += grams;
    _transactions.add(tx);
    await _dbService.saveTransaction(tx);
    await _syncProfile();
    notifyListeners();
  }
}
