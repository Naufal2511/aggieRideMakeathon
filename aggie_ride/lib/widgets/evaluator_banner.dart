import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class EvaluatorBanner extends StatelessWidget {
  const EvaluatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    return Container(
      color: AppTheme.aggieMaroonDark,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Brand pill, Persona Switcher & Reset
          Row(
            children: [
              // TAMU Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.aggieMaroon,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ATM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Makeathon',
                      style: TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Active Persona Dropdown
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentUser?.userId,
                      isExpanded: true,
                      dropdownColor: AppTheme.aggieMaroonDark,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                      items: appState.users.map((u) {
                        final isDriver = u.carModel != null;
                        final label = '${u.name} (${isDriver ? "Driver" : "Passenger"})';
                        return DropdownMenuItem<String>(
                          value: u.userId,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) appState.switchUser(val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Reset Button
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.restart_alt, color: Colors.white70, size: 18),
                tooltip: 'Reset Demo Data',
                onPressed: () => appState.resetDemo(),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 1-Click Makeathon Test Flow Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFFFDE047), size: 14),
                const SizedBox(width: 4),
                const Text(
                  '1-Click Test Flows: ',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                _buildFlowChip(
                  label: 'Flow 1: Find (Walmart)',
                  onTap: () => appState.runFlow1(),
                ),
                const SizedBox(width: 6),
                _buildFlowChip(
                  label: 'Flow 2: Offer (H-E-B)',
                  onTap: () => appState.runFlow2(),
                ),
                const SizedBox(width: 6),
                _buildFlowChip(
                  label: 'Flow 3: Accept Request',
                  onTap: () => appState.runFlow3(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

