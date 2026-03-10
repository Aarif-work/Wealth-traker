import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  final Widget child;
  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  String _authError = "";

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _isAuthenticated = true; // Skip lock if device doesn't support it
        });
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access your Wealth Tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        setState(() {
          _isAuthenticated = true;
        });
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      setState(() {
        _authError = "Security verification failed. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Wealth Locked",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Unlock to track your destiny",
              style: TextStyle(
                color: AppTheme.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_authError.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _authError,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.textBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "UNLOCK NOW",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
