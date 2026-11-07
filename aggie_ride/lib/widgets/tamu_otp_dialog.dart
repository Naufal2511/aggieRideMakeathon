import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class TamuOtpDialog extends StatefulWidget {
  const TamuOtpDialog({super.key});

  @override
  State<TamuOtpDialog> createState() => _TamuOtpDialogState();
}

class _TamuOtpDialogState extends State<TamuOtpDialog> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AppState>().currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _autofillDemoCode() {
    const code = ['1', '2', '1', '1', '9', '2'];
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = code[i];
    }
  }

  void _submitVerification() {
    final email = _emailController.text.trim().toLowerCase();
    if (!email.endsWith('@tamu.edu')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Texas A&M email ending in @tamu.edu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit verification code.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<AppState>().verifyCurrentUserTamu(email);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: AppTheme.aggieMaroon, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify @tamu.edu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Texas A&M Student Access',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AggieRide requires an active university email to ensure safe, student-only ride sharing.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 14),

            // Email Input
            const Text(
              'TAMU Student Email',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'netid@tamu.edu',
                prefixIcon: Icon(Icons.mail_outline, size: 18),
              ),
            ),

            const SizedBox(height: 16),

            // OTP Header & Autofill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '6-Digit OTP Code',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: _autofillDemoCode,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Auto-fill Demo Code', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 6 OTP Box Inputs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 38,
                  height: 44,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitVerification,
          child: const Text('Verify Student Status'),
        ),
      ],
    );
  }
}

