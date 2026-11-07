import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class TamuVerificationScreen extends StatefulWidget {
  final String email;
  final String userName;

  const TamuVerificationScreen({
    super.key,
    required this.email,
    required this.userName,
  });

  @override
  State<TamuVerificationScreen> createState() => _TamuVerificationScreenState();
}

class _TamuVerificationScreenState extends State<TamuVerificationScreen> {
  final List<TextEditingController> _digitControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendCooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _digitControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _autofillCode(String code) {
    for (int i = 0; i < 6 && i < code.length; i++) {
      _digitControllers[i].text = code[i];
    }
    _verifyCode();
  }

  Future<void> _verifyCode() async {
    final code = _digitControllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the verification code.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final success = await appState.verifyTamuCode(widget.email, code);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Texas A&M Student Identity Verified! Whoop! 👍'),
              backgroundColor: Color(0xFF15803D),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScaffold()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Invalid verification code. Please check your email or try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Verification error: $e';
      });
    }
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0) return;
    try {
      final appState = context.read<AppState>();
      await appState.sendTamuVerificationEmail(widget.email);
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New verification PIN sent to your @tamu.edu inbox.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not resend code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final activeOtp = authService.lastGeneratedOtp ?? '121192';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Verify Student Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppTheme.aggieMaroon,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.mark_email_read, size: 40, color: AppTheme.aggieMaroon),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Howdy, ${widget.userName}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroonDark),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'We dispatched a 6-digit Texas A&M security PIN to:\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Development quick-fill pill
                  Center(
                    child: ActionChip(
                      avatar: const Icon(Icons.flash_on, size: 16, color: AppTheme.aggieBrass),
                      label: Text('Autofill Sent Code: $activeOtp', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: const Color(0xFFFEF3C7),
                      side: const BorderSide(color: Color(0xFFFDE68A)),
                      onPressed: () => _autofillCode(activeOtp),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 6 Digit Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextFormField(
                          controller: _digitControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroon),
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.aggieMaroon, width: 2)),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (index == 5 && value.isNotEmpty) {
                              _verifyCode();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Verify Button
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.aggieMaroon,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Verify & Launch AggieRide', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),

                  // Resend Button
                  Center(
                    child: TextButton.icon(
                      onPressed: _resendCooldown > 0 ? null : _resendCode,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(
                        _resendCooldown > 0
                            ? 'Resend PIN in $_resendCooldown s'
                            : 'Resend Verification Code',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _resendCooldown > 0 ? Colors.grey : AppTheme.aggieMaroon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

