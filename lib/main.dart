import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/wealth_provider.dart';
import 'widgets/main_layout.dart';
import 'screens/lock_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  // Initialize Indian date formatting support
  await initializeDateFormatting('en_IN', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => WealthProvider(),
      child: const PersonalWealthApp(),
    ),
  );
}

class PersonalWealthApp extends StatelessWidget {
  const PersonalWealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wealth Tracker',
      theme: AppTheme.lightTheme,
      home: const LockScreen(child: MainLayout()),
    );
  }
}
