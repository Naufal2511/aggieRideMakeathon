import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/seed_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openDriverRegistrationDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final makeController = TextEditingController(text: 'Toyota');
    final modelController = TextEditingController(text: 'Corolla (2023)');
    int seats = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Register as an Aggie Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  '⚠️ Demo Verification: Licence and safety verification is simulated as "Demo Verified Driver" for testing.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Vehicle Make (e.g. Honda, Toyota)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Vehicle Model & Year (e.g. Civic 2022)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: seats,
                decoration: const InputDecoration(labelText: 'Passenger Seats Available'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 Seat')),
                  DropdownMenuItem(value: 2, child: Text('2 Seats')),
                  DropdownMenuItem(value: 3, child: Text('3 Seats')),
                  DropdownMenuItem(value: 4, child: Text('4 Seats')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => seats = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                appState.registerAsDriver(
                  carMake: makeController.text,
                  carModel: modelController.text,
                  seats: seats,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Complete Demo Registration'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEmailVerifyDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final emailController = TextEditingController(text: appState.currentUser?.email ?? 'student@tamu.edu');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify @tamu.edu Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your official Texas A&M email to verify your student status.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'TAMU Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appState.verifyCurrentUserTamu(emailController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDriver = user.isDriverVerified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(user.avatar),
                    backgroundColor: AppTheme.primaryContainer,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  Text(
                    '${user.classYear} • ${user.major}',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),

                  // Verification Badge
                  if (user.isTamuVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 14, color: Color(0xFF047857)),
                          SizedBox(width: 4),
                          Text(
                            'TAMU Email Verified (@tamu.edu)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _openEmailVerifyDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mark_email_unread, size: 14, color: Color(0xFFB45309)),
                            SizedBox(width: 4),
                            Text(
                              'Unverified • Tap to verify @tamu.edu',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), height: 1.35),
                  ),
                  const SizedBox(height: 14),

                  // Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileMetric('${user.ridesJoined}', 'Rides Joined'),
                      _buildProfileMetric('${user.ridesOffered}', 'Rides Offered'),
                      _buildProfileMetric('${user.rating} ★', 'Rating'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Driver Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDriver ? const Color(0xFFFFFBFB) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDriver ? AppTheme.aggieMaroon.withOpacity(0.2) : const Color(0xFFE5E7EB)),
              ),
              child: isDriver
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user, color: AppTheme.aggieMaroon, size: 20),
                            SizedBox(width: 8),
                            Text('Demo Verified Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.aggieMaroon)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Vehicle: ${user.carModel ?? "2022 Honda Civic (White)"}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const Text('Registered to offer seats to Texas A&M destination groups.', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.directions_car, color: AppTheme.aggieMaroon, size: 20),
                            SizedBox(width: 8),
                            Text('Become an Aggie Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Have a car in College Station? Register to share empty seats, help Aggies, and coordinate trips.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _openDriverRegistrationDialog(context),
                            child: const Text('Register as Driver'),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Student Interests
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: SeedDataService.studentInterests.take(4).map((i) {
                      return Chip(
                        label: Text(i, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppTheme.primaryContainer.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Persona Switcher for Evaluators
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Switch Demo Persona:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: appState.users.map((u) {
                      final isCurrent = u.userId == user.userId;
                      return ActionChip(
                        avatar: CircleAvatar(radius: 10, backgroundImage: NetworkImage(u.avatar)),
                        label: Text(
                          '${u.name.split(" ").first} (${u.isDriverVerified ? "Driver" : "Passenger"})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: isCurrent ? AppTheme.aggieMaroon : Colors.white,
                        onPressed: () => appState.switchUser(u.userId),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMetric(String val, String lbl) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        Text(lbl, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }
}
