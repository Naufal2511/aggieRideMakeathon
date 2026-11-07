import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'tamu_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _majorController = TextEditingController(text: 'Computer Science');
  final _phoneController = TextEditingController();

  // Driver options
  bool _isDriver = false;
  final _carModelController = TextEditingController();
  final _licensePlateController = TextEditingController();

  String _selectedClassYear = "'26 (Junior)";
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _classYears = [
    "'28 (Freshman)",
    "'27 (Sophomore)",
    "'26 (Junior)",
    "'25 (Senior)",
    "Graduate Student",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();
      final user = await appState.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        classYear: _selectedClassYear,
        major: _majorController.text.trim(),
        phone: _phoneController.text.trim(),
        carModel: _isDriver ? _carModelController.text.trim() : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to TAMU Verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TamuVerificationScreen(
              email: user.email,
              userName: user.name,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Aggie Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppTheme.aggieMaroon,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.aggieMaroon.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school, color: AppTheme.aggieMaroon, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Join AggieRide',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroonDark),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Only verified Texas A&M students with active @tamu.edu emails can participate.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Full Name
                    const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Reveille Aggie',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name.' : null,
                    ),
                    const SizedBox(height: 16),

                    // TAMU Email
                    const Text('Texas A&M Email (@tamu.edu)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'your_netid@tamu.edu',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required.';
                        if (!v.trim().toLowerCase().endsWith('@tamu.edu')) {
                          return 'Must be an official @tamu.edu student address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Min 6 chars',
                                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                                ),
                                validator: (v) => v == null || v.length < 6 ? 'Min 6 chars.' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Confirm Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Repeat password',
                                  prefixIcon: Icon(Icons.lock_reset, size: 20),
                                ),
                                validator: (v) {
                                  if (v != _passwordController.text) return 'Does not match.';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Class Year & Major
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class Year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedClassYear,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                items: _classYears.map((y) {
                                  return DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 12)));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedClassYear = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Major / College', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _majorController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Engineering',
                                  prefixIcon: Icon(Icons.menu_book, size: 20),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Major required.' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    const Text('Mobile Phone (for pickup SMS alerts)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '(979) 555-0199',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required for ride communication.' : null,
                    ),
                    const SizedBox(height: 20),

                    // Driver Profile Switch
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car, color: AppTheme.aggieMaroon, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('I Plan to Offer Rides (Driver Profile)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('Register your vehicle so passengers can identify you', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isDriver,
                                activeThumbColor: AppTheme.aggieMaroon,
                                onChanged: (val) => setState(() => _isDriver = val),
                              ),
                            ],
                          ),
                          if (_isDriver) ...[
                            const Divider(height: 20),
                            const Text('Vehicle Make & Model', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _carModelController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 2023 Toyota Camry (Silver)',
                                prefixIcon: Icon(Icons.drive_eta, size: 18),
                              ),
                              validator: (v) => _isDriver && (v == null || v.trim().isEmpty) ? 'Please enter vehicle details.' : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.aggieMaroon,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Register & Verify @tamu.edu',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}