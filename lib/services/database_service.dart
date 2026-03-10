import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/wealth_provider.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = dotenv.get('DEFAULT_USER_ID', fallback: 'user_1');

  // --- Transactions ---
  Future<void> saveTransaction(Transaction tx) async {
    await _db.collection('users').doc(userId).collection('transactions').doc(tx.id).set({
      'title': tx.title,
      'amount': tx.amount,
      'date': tx.date.toIso8601String(),
      'type': tx.type.index,
      'note': tx.note,
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _db.collection('users').doc(userId).collection('transactions').doc(id).delete();
  }

  // --- Goals ---
  Future<void> saveGoal(FinancialGoal goal) async {
    await _db.collection('users').doc(userId).collection('goals').doc(goal.id).set({
      'targetWealth': goal.targetWealth,
      'targetGoldGrams': goal.targetGoldGrams,
      'targetHelpActivities': goal.targetHelpActivities,
      'startingWealth': goal.startingWealth,
      'startingGoldGrams': goal.startingGoldGrams,
      'startingHelpCount': goal.startingHelpCount,
      'startDate': goal.startDate.toIso8601String(),
      'isCompleted': goal.isCompleted,
    });
  }

  // --- Characters ---
  Future<void> saveCharacter(HelpCharacter char) async {
    await _db.collection('users').doc(userId).collection('characters').doc(char.id).set({
      'tag': char.tag,
      'tagColorValue': char.tagColorValue,
      'name': char.name,
      'message': char.message,
      'amount': char.amount,
      'iconCodePoint': char.iconCodePoint,
      'avatarBgValue': char.avatarBgValue,
      'avatarFgValue': char.avatarFgValue,
      'badgeIconCodePoint': char.badgeIconCodePoint,
      'badgeColorValue': char.badgeColorValue,
      'isGold': char.isGold,
      'currentHelpedCount': char.currentHelpedCount,
      'lastHelpedDate': char.lastHelpedDate?.toIso8601String(),
    });
  }

  Future<void> deleteCharacter(String id) async {
    await _db.collection('users').doc(userId).collection('characters').doc(id).delete();
  }

  Future<void> resetUserData() async {
    // Delete profile
    await _db.collection('users').doc(userId).delete();
    
    // Note: Deleting subcollections in Firestore requires deleting each document.
    // We'll handle this by fetching then deleting for simplicity in this dev environment.
    final txs = await _db.collection('users').doc(userId).collection('transactions').get();
    for (var doc in txs.docs) { await doc.reference.delete(); }
    
    final goals = await _db.collection('users').doc(userId).collection('goals').get();
    for (var doc in goals.docs) { await doc.reference.delete(); }
    
    final chars = await _db.collection('users').doc(userId).collection('characters').get();
    for (var doc in chars.docs) { await doc.reference.delete(); }
  }

  // --- Profile / Global State ---
  Future<void> updateProfile(double cashSavings, double digitalGoldGrams) async {
    await _db.collection('users').doc(userId).set({
      'cashSavings': cashSavings,
      'digitalGoldInGrams': digitalGoldGrams,
    }, SetOptions(merge: true));
  }

  // --- Fetching Data ---
  Future<Map<String, dynamic>?> fetchProfile() async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<List<Transaction>> fetchTransactions() async {
    final snapshot = await _db.collection('users').doc(userId).collection('transactions').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Transaction(
        id: doc.id,
        title: data['title'],
        amount: (data['amount'] as num).toDouble(),
        date: DateTime.parse(data['date']),
        type: TransactionType.values[data['type']],
        note: data['note'] ?? "",
      );
    }).toList();
  }

  Future<List<FinancialGoal>> fetchGoals() async {
    final snapshot = await _db.collection('users').doc(userId).collection('goals').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FinancialGoal(
        id: doc.id,
        targetWealth: (data['targetWealth'] as num).toDouble(),
        targetGoldGrams: (data['targetGoldGrams'] as num).toDouble(),
        targetHelpActivities: data['targetHelpActivities'],
        startingWealth: (data['startingWealth'] as num).toDouble(),
        startingGoldGrams: (data['startingGoldGrams'] as num).toDouble(),
        startingHelpCount: data['startingHelpCount'],
        startDate: DateTime.parse(data['startDate']),
        isCompleted: data['isCompleted'] ?? false,
      );
    }).toList();
  }

  Future<List<HelpCharacter>> fetchCharacters() async {
    final snapshot = await _db.collection('users').doc(userId).collection('characters').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HelpCharacter(
        id: doc.id,
        tag: data['tag'],
        tagColorValue: data['tagColorValue'],
        name: data['name'],
        message: data['message'],
        amount: (data['amount'] as num).toDouble(),
        iconCodePoint: data['iconCodePoint'],
        avatarBgValue: data['avatarBgValue'],
        avatarFgValue: data['avatarFgValue'],
        badgeIconCodePoint: data['badgeIconCodePoint'],
        badgeColorValue: data['badgeColorValue'],
        isGold: data['isGold'],
        currentHelpedCount: data['currentHelpedCount'] ?? 0,
        lastHelpedDate: data['lastHelpedDate'] != null ? DateTime.parse(data['lastHelpedDate']) : null,
      );
    }).toList();
  }
}
