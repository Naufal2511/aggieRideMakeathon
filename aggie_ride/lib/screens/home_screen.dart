import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/ride_group_model.dart';
import '../services/seed_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _destinationController = TextEditingController();
  String _selectedPickupZone = 'Park West Apartments';
  String _selectedDate = 'Saturday, Nov 8';
  String _selectedTime = '11:00 AM';
  String _selectedFlexibility = '±1 hour';
  int _selectedPassengers = 1;
  int _factIndex = 0;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _cycleFact(int totalFacts) {
    setState(() {
      _factIndex = (_factIndex + 1) % totalFacts;
    });
  }

  void _showDelightConfirmation(BuildContext context, String destination, int interestedCount, String groupId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: AppTheme.aggieMaroon,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your plan is out there!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.aggieMaroon,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$interestedCount other Aggies are interested in heading to $destination! We have matched you with an active destination group.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openGroupDetailsSheet(context, groupId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.aggieMaroon,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('View Destination Group'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss', style: TextStyle(color: Color(0xFF6B7280))),
            ),
          ],
        ),
      ),
    );
  }

  void _openGroupDetailsSheet(BuildContext context, String groupId) {
    final appState = Provider.of<AppState>(context, listen: false);
    final group = appState.rideGroups.firstWhere(
      (g) => g.groupId == groupId,
      orElse: () => appState.rideGroups[0],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<AppState>(
          builder: (context, state, _) {
            final isJoined = group.studentAvatars.contains(state.currentUser?.avatar);
            final isDriver = state.isDriver;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(group.status),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    group.destination,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                  ),
                  Text(
                    '${group.date} • ${group.timeWindow}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),

                  // 3 Explicit Community Metrics
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('${group.interestedCount}', 'Interested'),
                        _buildMetricCol('${group.availableDriversCount}', 'Drivers'),
                        _buildMetricCol('${group.openSeatsCount}', 'Open Seats'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Coordinated Pickup Hubs:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [group.pickupZone, 'MSC / Rudder Plaza'].map((p) => Chip(
                      label: Text(p, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppTheme.aggieMaroon.withOpacity(0.2)),
                      avatar: const Icon(Icons.pin_drop, size: 14, color: AppTheme.aggieMaroon),
                    )).toList(),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Participating Aggies:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: group.studentAvatars.length,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(group.studentAvatars[idx]),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Aggie Participant #${idx + 1}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                idx == 0 ? 'Driver' : 'Passenger',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: idx == 0 ? AppTheme.aggieMaroon : const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      if (group.openSeatsCount > 0 && !isDriver)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final primaryRide = state.rides.firstWhere(
                                (r) => r.rideId == group.primaryRideId,
                                orElse: () => state.rides[0],
                              );
                              state.requestRide(ride: primaryRide, message: 'Howdy! Would love to join.');
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.airline_seat_recline_normal, size: 16),
                            label: const Text('Request Seat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.aggieMaroon,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      if (isDriver)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openOfferRideDialog(context, group.destination);
                            },
                            icon: const Icon(Icons.add_circle, size: 16),
                            label: const Text('Offer Seats to Group'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.aggieMaroon,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          if (isJoined) {
                            state.leaveGroup(group.groupId);
                          } else {
                            state.joinGroup(group.groupId);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isJoined ? 'Leave Group' : 'Join Group'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openOfferRideDialog(BuildContext context, String destination) {
    final appState = Provider.of<AppState>(context, listen: false);
    final originController = TextEditingController(text: 'Northgate / College Main');
    final destController = TextEditingController(text: destination);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Offer Seats to Aggies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: originController, decoration: const InputDecoration(labelText: 'Starting Hub')),
            const SizedBox(height: 8),
            TextField(controller: destController, decoration: const InputDecoration(labelText: 'Destination')),
            const SizedBox(height: 8),
            const Text('Offering 3 passenger seats with flexible trunk space.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appState.offerRide(
                origin: originController.text,
                destination: destController.text,
                departureDate: 'Saturday, Nov 8',
                departureTime: '11:00 AM',
                seats: 3,
                contribution: 2,
                category: 'Shopping',
                pickupSpot: 'Park West Tower 1',
                notes: 'Aggies ride free or \$2 gas split.',
                isRecurring: false,
                recurringDays: const [],
              );
              Navigator.pop(ctx);
            },
            child: const Text('Publish Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFECFDF5);
    Color fg = const Color(0xFF047857);

    if (status == 'Looking for a driver') {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFB45309);
    } else if (status == 'Ride filling up') {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFC2410C);
    } else if (status == 'Gathering interest') {
      bg = const Color(0xFFF5F3FF);
      fg = const Color(0xFF6D28D9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final facts = appState.tamuFacts;
    final currentFact = facts.isNotEmpty ? facts[_factIndex % facts.length] : null;
    final groups = appState.rideGroups;
    final events = appState.events;
    final isDriver = appState.isDriver;

    return RefreshIndicator(
      onRefresh: () => appState.initialize(),
      color: AppTheme.aggieMaroon,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section B: Aggie Fact of the Day
            if (currentFact != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryContainer.withOpacity(0.35),
                      const Color(0xFFFFFBEB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.aggieMaroon.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school, color: AppTheme.aggieMaroon, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DID YOU KNOW, AGGIE? • ${currentFact['tag']}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.aggieMaroon,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            currentFact['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            currentFact['text'] ?? '',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
                      onPressed: () => _cycleFact(facts.length),
                    ),
                  ],
                ),
              ),

            // Driver Prompt Banner (Only when active user is a verified driver)
            if (isDriver)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF380000), AppTheme.aggieMaroon],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.aggieMaroon.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Color(0xFFFDE047), size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver Demand Alert',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '6 Aggies want to visit Walmart this Saturday. Are you heading there?',
                            style: TextStyle(color: Color(0xFFFCE8E6), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _openOfferRideDialog(context, 'Walmart Supercenter (Bryan / CS)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.aggieMaroon,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Offer Ride'),
                    ),
                  ],
                ),
              ),

            // Section C: Primary Travel Intention Section ("Where are you heading?")
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.aggieMaroon.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Where are you heading?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tell us where you want to go. We'll help you find Aggies going the same way.",
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),

                  // Destination Input
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Enter destination (e.g. Walmart, H-E-B, Target)...',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.location_on, color: AppTheme.aggieMaroon),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pickup Zone Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedPickupZone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.pin_drop, color: AppTheme.aggieMaroon, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: appState.pickupZones.map((z) {
                      final name = z['name'] as String;
                      return DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 12.5)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPickupZone = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDate,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.aggieMaroon, size: 18),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Today (Friday)', child: Text('Today', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Saturday, Nov 8', child: Text('Saturday', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'Sunday, Nov 9', child: Text('Sunday', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDate = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTime,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.schedule, color: AppTheme.aggieMaroon, size: 18),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: '11:00 AM', child: Text('11:00 AM', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: '2:00 PM', child: Text('2:00 PM', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: '4:30 PM', child: Text('4:30 PM', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: '6:30 PM', child: Text('6:30 PM', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTime = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // "Find My People" Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final dest = _destinationController.text.trim();
                        if (dest.isEmpty) {
                          appState.showToast('Please enter where you want to go!');
                          return;
                        }
                        final intent = await appState.postTravelIntention(
                          destination: dest,
                          pickupZone: _selectedPickupZone,
                          date: _selectedDate,
                          time: _selectedTime,
                          flexibility: _selectedFlexibility,
                          passengers: _selectedPassengers,
                        );
                        _showDelightConfirmation(context, dest, 4, intent.matchedGroupId ?? 'group-walmart-sat');
                      },
                      icon: const Icon(Icons.groups, size: 18),
                      label: const Text('Find my people', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.aggieMaroon,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _selectedFlexibility = 'Anytime that day');
                        appState.showToast('Time flexibility set to anytime that day.');
                      },
                      child: const Text(
                        'Not sure when? Just express your interest.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section D: Popular Destinations Shortcuts
            const Text(
              'Popular Destinations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPopularChip('Walmart', Icons.shopping_bag, 'Walmart Supercenter (Bryan / CS)'),
                  _buildPopularChip('H-E-B', Icons.local_grocery_store, 'H-E-B (Jones Crossing / Wellborn Rd)'),
                  _buildPopularChip('Target', Icons.storefront, 'Target (University Dr & 29th St)'),
                  _buildPopularChip('Costco', Icons.inventory_2, 'Costco Wholesale (Midtown Bryan)'),
                  _buildPopularChip('Campus', Icons.school, 'Texas A&M Campus (MSC / Rudder Plaza)'),
                  _buildPopularChip('Downtown Bryan', Icons.nightlife, 'Downtown Bryan (Historic District)'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Section E: Where Aggies are Heading Today (Destination Groups)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Where Aggies are heading today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                ),
                TextButton(
                  onPressed: () => appState.setTab(1),
                  child: const Text('See all', style: TextStyle(color: AppTheme.aggieMaroon, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...groups.take(4).map((group) => _buildGroupCard(context, group)),

            const SizedBox(height: 22),

            // Section F: What's Happening Around Aggieland?
            const Text(
              "What's happening around Aggieland?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, idx) {
                  final e = events[idx];
                  return Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          e['image'] as String,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${e['date']} • ${e['venue']}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await appState.postTravelIntention(
                                      destination: e['title'] as String,
                                      pickupZone: 'Park West Apartments',
                                      date: e['date'] as String,
                                      time: '9:00 AM',
                                      flexibility: '±30 mins',
                                    );
                                    appState.showToast('Travel intention created for ${e['title']}!');
                                    appState.setTab(2); // My Journeys
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Find Aggies going', style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Section G: Student Interests
            const Text(
              'Find your kind of people',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: SeedDataService.studentInterests.map((interest) {
                return ActionChip(
                  label: Text(interest, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  onPressed: () {
                    appState.showToast('Filtered groups for $interest');
                    appState.setTab(1); // Discover
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularChip(String name, IconData icon, String fullDestination) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppTheme.aggieMaroon),
        label: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppTheme.aggieMaroon.withOpacity(0.12)),
        onPressed: () {
          setState(() {
            _destinationController.text = fullDestination;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prefilled $name destination!'), duration: const Duration(seconds: 1)),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, RideGroupModel group) {
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
        onTap: () => _openGroupDetailsSheet(context, group.groupId),
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
                _buildStatusBadge(group.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${group.date} • ${group.timeWindow}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 10),

            // 3 Explicit Metrics Breakdown
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCol('${group.interestedCount}', 'Interested'),
                  _buildMetricCol('${group.availableDriversCount}', 'Drivers'),
                  _buildMetricCol('${group.openSeatsCount}', 'Open Seats'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: group.studentAvatars.take(3).map((avatar) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(avatar),
                      ),
                    );
                  }).toList(),
                ),
                const Row(
                  children: [
                    Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroon)),
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
}
