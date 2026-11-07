import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/ride_group_model.dart';

class FindRidesScreen extends StatelessWidget {
  const FindRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final groups = appState.filteredRideGroups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Discover', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => appState.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search destination, store, campus building...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.aggieMaroon),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Ride available',
                      'Looking for a driver',
                      'Groceries',
                      'Campus',
                    ].map((cat) {
                      final isSelected = appState.selectedCategory.toLowerCase() == cat.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.aggieMaroon,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppTheme.aggieMaroon : const Color(0xFFE5E7EB)),
                          onSelected: (val) {
                            if (val) appState.setSelectedCategory(cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Destination Groups List
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          'No destination groups found',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try clearing filters or search query.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            appState.setSearchQuery('');
                            appState.setSelectedCategory('All');
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: groups.length,
                    itemBuilder: (context, idx) {
                      final group = groups[idx];
                      return _buildGroupCard(context, group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, RideGroupModel group) {
    Color statusBg = const Color(0xFFECFDF5);
    Color statusFg = const Color(0xFF047857);

    if (group.status == 'Looking for a driver') {
      statusBg = const Color(0xFFFFFBEB);
      statusFg = const Color(0xFFB45309);
    } else if (group.status == 'Ride filling up') {
      statusBg = const Color(0xFFFFF7ED);
      statusFg = const Color(0xFFC2410C);
    } else if (group.status == 'Gathering interest') {
      statusBg = const Color(0xFFF5F3FF);
      statusFg = const Color(0xFF6D28D9);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context, group),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    group.destination,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    group.status,
                    style: TextStyle(color: statusFg, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${group.date} • ${group.timeWindow}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 10),

            // 3 Explicit Community Metrics
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metric('${group.interestedCount}', 'Interested'),
                  _metric('${group.availableDriversCount}', 'Drivers'),
                  _metric('${group.openSeatsCount}', 'Open Seats'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: group.studentAvatars.take(3).map((a) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(a)),
                    );
                  }).toList(),
                ),
                const Row(
                  children: [
                    Text('Join or View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroon)),
                    Icon(Icons.chevron_right, size: 16, color: AppTheme.aggieMaroon),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String val, String lbl) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        Text(lbl, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
      ],
    );
  }

  void _openDetails(BuildContext context, RideGroupModel group) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isJoined = group.studentAvatars.contains(appState.currentUser?.avatar);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.destination, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${group.date} • ${group.timeWindow}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 14),
            Text('Pickup Hub: ${group.pickupZone}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isJoined) {
                    appState.leaveGroup(group.groupId);
                  } else {
                    appState.joinGroup(group.groupId);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isJoined ? 'Leave Destination Group' : 'Join Destination Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
