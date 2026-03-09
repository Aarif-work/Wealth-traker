import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  void _showAddGoalSheet(BuildContext context, WealthProvider provider, {FinancialGoal? existingGoal}) {
    double wealthTarget = existingGoal?.targetWealth ?? 50000.0;
    double goldTarget = existingGoal?.targetGoldGrams ?? 1.0;
    int helpTarget = existingGoal?.targetHelpActivities ?? 5;

    final wealthController = TextEditingController(text: wealthTarget.toStringAsFixed(0));
    final goldController = TextEditingController(text: goldTarget.toString());
    final helpController = TextEditingController(text: helpTarget.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existingGoal == null ? "Create New Goal" : "Update Goal", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textBlack)),
              const SizedBox(height: 24),
              TextField(
                controller: wealthController,
                decoration: InputDecoration(
                  labelText: "Wealth Goal (₹)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryGreen),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => wealthTarget = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: goldController,
                decoration: InputDecoration(
                  labelText: "Gold Goal (Grams)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => goldTarget = double.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: helpController,
                decoration: InputDecoration(
                  labelText: "Help Activities Goal (Times)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.favorite_rounded, color: AppTheme.primaryGreen),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => helpTarget = int.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (existingGoal == null) {
                      provider.addNewGoal(wealthTarget, goldTarget, helpTarget);
                    } else {
                      provider.updateGoal(existingGoal.id, wealthTarget, goldTarget, helpTarget);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.textBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(existingGoal == null ? "START GOAL" : "UPDATE GOAL", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
    final provider = Provider.of<WealthProvider>(context);
    final goals = provider.goals.reversed.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, provider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildMilestoneSummary(context, provider, goals.firstOrNull),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      "ACTIVE CYCLES",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (goals.isEmpty)
                    _buildEmptyState(context, provider)
                  else
                    ...goals.map((goal) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildRecurringGoalCard(goal, provider),
                        )),
                  const SizedBox(height: 100), // spacing for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context, provider),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.textBlack,
        elevation: 4,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("UPDATE MILESTONE", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WealthProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes_rounded, size: 80, color: Colors.blueGrey.shade100),
          const SizedBox(height: 16),
          const Text(
            "No active goals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGray),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddGoalSheet(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreenSoft,
              foregroundColor: AppTheme.primaryGreen,
              elevation: 0,
            ),
            child: const Text("Create your first goal"),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WealthProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recurring Goals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textBlack, letterSpacing: -1.0),
              ),
              Text(
                'Gold & Help targets',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textGray),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history_rounded, color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringGoalCard(FinancialGoal goal, WealthProvider provider) {
    final currentWealthGained = (provider.totalWealth - goal.startingWealth).clamp(0.0, double.infinity);
    final wealthProgress = (goal.targetWealth > 0) ? (currentWealthGained / goal.targetWealth).clamp(0.0, 1.0) : 0.0;

    final currentGoldGained = (provider.digitalGoldGrams - goal.startingGoldGrams).clamp(0.0, double.infinity);
    final goldProgress = (goal.targetGoldGrams > 0) ? (currentGoldGained / goal.targetGoldGrams).clamp(0.0, 1.0) : 0.0;

    final currentHelpCount = (provider.totalHelpActivitiesCount - goal.startingHelpCount).clamp(0, 999999);
    final helpProgress = (goal.targetHelpActivities > 0) ? (currentHelpCount / goal.targetHelpActivities).clamp(0.0, 1.0) : 0.0;
    
    final overallProgress = (goldProgress + helpProgress + wealthProgress) / 3;
    final isDone = overallProgress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textBlack.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(goal.startDate),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGray, letterSpacing: 1.0),
              ),
              Row(
                children: [
                  if (isDone)
                    const Icon(Icons.verified_rounded, color: AppTheme.primaryGreen, size: 20)
                  else
                    Text(
                      "${(overallProgress * 100).toInt()}% READY",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAddGoalSheet(context, provider, existingGoal: goal),
                    child: Icon(Icons.edit_note_rounded, size: 22, color: Colors.blueGrey.shade300),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSubProgress(
            "Wealth Target",
            "₹${currentWealthGained.toStringAsFixed(0)} / ₹${goal.targetWealth.toStringAsFixed(0)}",
            wealthProgress,
            AppTheme.primaryGreen,
            Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 20),
          _buildSubProgress(
            "Gold Target",
            "${currentGoldGained.toStringAsFixed(2)} / ${goal.targetGoldGrams}g",
            goldProgress,
            const Color(0xFFFFB300),
            Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 20),
          _buildSubProgress(
            "Help Target",
            "$currentHelpCount / ${goal.targetHelpActivities} activities",
            helpProgress,
            Colors.redAccent,
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 24),
          if (!isDone)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.auto_graph_rounded, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Keep it up! You are ${(overallProgress * 100).toInt()}% through this cycle.",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubProgress(String title, String value, double progress, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textBlack)),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneSummary(BuildContext context, WealthProvider provider, FinancialGoal? currentGoal) {
    if (currentGoal == null) return const SizedBox.shrink();

    final currentWealthGained = (provider.totalWealth - currentGoal.startingWealth).clamp(0.0, double.infinity);
    final wealthProgress = (currentGoal.targetWealth > 0) ? (currentWealthGained / currentGoal.targetWealth).clamp(0.0, 1.0) : 0.0;

    final currentGoldGained = (provider.digitalGoldGrams - currentGoal.startingGoldGrams).clamp(0.0, double.infinity);
    final goldProgress = (currentGoal.targetGoldGrams > 0) ? (currentGoldGained / currentGoal.targetGoldGrams).clamp(0.0, 1.0) : 0.0;

    final currentHelpCount = (provider.totalHelpActivitiesCount - currentGoal.startingHelpCount).clamp(0, 999999);
    final helpProgress = (currentGoal.targetHelpActivities > 0) ? (currentHelpCount / currentGoal.targetHelpActivities).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          _buildCircularMilestoneCard(
            title: "Total Wealth",
            currentAmount: "₹${provider.totalWealth.toStringAsFixed(0)}",
            targetAmount: "Target: ₹${currentGoal.targetWealth.toStringAsFixed(0)}",
            progress: wealthProgress,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          _buildCircularMilestoneCard(
            title: "Gold Milestone",
            currentAmount: "${provider.digitalGoldGrams.toStringAsFixed(2)}g",
            targetAmount: "Target: ${currentGoal.targetGoldGrams}g",
            progress: goldProgress,
            color: const Color(0xFFFFB300), // Amber Gold
          ),
          const SizedBox(height: 16),
          _buildLinearMilestoneCard(
            title: "Help Milestone",
            tag: "EMPATHY",
            currentAmount: "${provider.totalHelpActivitiesCount} Acts",
            targetAmountStr: "Target: ${currentGoal.targetHelpActivities} Acts",
            progress: helpProgress,
            color: Colors.redAccent, // Red for Help
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMilestoneCard({
    required String title,
    required String currentAmount,
    required String targetAmount,
    required double progress,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textBlack.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textBlack.withValues(alpha: 0.9),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CircularPercentIndicator(
            radius: 65.0,
            lineWidth: 8.0,
            animation: true,
            percent: progress,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textBlack),
                ),
                Text(
                  "REACHED",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 8, color: Colors.blueGrey.shade400, letterSpacing: 0.5),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.1),
            progressColor: color,
          ),
          const SizedBox(height: 24),
          Text(
            currentAmount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.textBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            targetAmount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinearMilestoneCard({
    required String title,
    required String tag,
    required String currentAmount,
    required String targetAmountStr,
    required double progress,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.textBlack.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textBlack.withValues(alpha: 0.9),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade600, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentAmount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppTheme.textBlack,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                targetAmountStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade300,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: progress,
              padding: EdgeInsets.zero,
              progressColor: color,
              backgroundColor: color.withValues(alpha: 0.1),
              barRadius: const Radius.circular(8),
              animation: true,
            ),
          ),
        ],
      ),
    );
  }

}
