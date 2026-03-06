import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/wealth_provider.dart';
import 'widgets/main_layout.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'my wealth',
      theme: AppTheme.lightTheme,
      home: const MainLayout(),
    );
  }
}
