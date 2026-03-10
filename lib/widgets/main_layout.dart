import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wealth_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/wealth_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/add_transaction_screen.dart';


class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper to map bottom nav index to PageView index
  int _navToPage(int index) {
    if (index < 2) return index;
    if (index > 2) return index - 1;
    return 0; // Fallback
  }

  // Helper to map PageView index to bottom nav index
  int _pageToNav(int index) {
    if (index < 2) return index;
    return index + 1;
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const ActivityScreen(),
    const WealthScreen(),
    const GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WealthProvider>(context);

    if (!provider.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text(
                "Syncing your wealth...",
                style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = _pageToNav(index);
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textBlack.withValues(alpha: 0.04), // Soft subtle shadow
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, "Home"),
              _buildNavItem(1, Icons.history_rounded, "History"),
              _buildAddButton(),
              _buildNavItem(3, Icons.favorite_outline_rounded, "Save", activeIcon: Icons.favorite_rounded),
              _buildNavItem(4, Icons.track_changes_rounded, "Milestones", activeIcon: Icons.track_changes_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {IconData? activeIcon}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          _navToPage(index),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, isSelected ? -4 : 0, 0),
              child: Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                color: isSelected ? AppTheme.primaryGreen : Colors.blueGrey.shade100,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primaryGreen : Colors.blueGrey.shade100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AddTransactionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.fastOutSlowIn;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppTheme.textBlack,
          size: 28,
        ),
      ),
    );
  }
}

