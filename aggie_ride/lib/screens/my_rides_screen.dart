import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../models/travel_intention_model.dart';
import '../models/ride_group_model.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDriver = appState.isDriver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journeys', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.primaryContainer,
          tabs: [
            const Tab(text: 'My Intentions'),
            const Tab(text: 'Joined Groups'),
            const Tab(text: 'Upcoming Rides'),
            if (isDriver)
              const Tab(text: 'Offered Rides (Driver)')
            else
              const Tab(text: 'Driver Tools 🔒'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIntentionsTab(context, appState),
          _buildJoinedGroupsTab(context, appState),
          _buildUpcomingRidesTab(context, appState),
          isDriver
              ? _buildOfferedRidesTab(context, appState)
              : _buildNonDriverPrompt(context, appState),
        ],
      ),
    );
  }

  // 1. My Intentions Tab
  Widget _buildIntentionsTab(BuildContext context, AppState appState) {
    final myIntentions = appState.myIntentions;

    if (myIntentions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alt_route, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No travel intentions yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Where are you planning to go? Express your interest on the Home tab to discover other Aggies going your way!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => appState.setTab(0),
                child: const Text('Post a Travel Intention'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myIntentions.length,
      itemBuilder: (context, idx) {
        final intent = myIntentions[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        intent.destination,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        intent.status,
                        style: const TextStyle(color: Color(0xFF6D28D9), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${intent.preferredDate} • ${intent.earliestDeparture} (${intent.latestDeparture})',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                ),
                Text(
                  'Pickup Hub: ${intent.pickupLocation}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                if (intent.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"${intent.notes}"', style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => appState.withdrawIntention(intent.intentionId),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Withdraw Intention', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. Joined Groups Tab
  Widget _buildJoinedGroupsTab(BuildContext context, AppState appState) {
    final groups = appState.myJoinedGroups;

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No joined travel groups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'Explore where Aggies are heading on Discover and join active travel groups!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => appState.setTab(1),
                child: const Text('Explore Groups'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, idx) {
        final group = groups[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.destination, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${group.date} • ${group.timeWindow}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  '${group.interestedCount} Aggies participating • ${group.availableDriversCount} Drivers offering seats',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => appState.leaveGroup(group.groupId),
                    child: const Text('Leave Group', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Upcoming Rides (Passenger Seat Bookings)
  Widget _buildUpcomingRidesTab(BuildContext context, AppState appState) {
    final myRequests = appState.myJoinRequests;

    if (myRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No active ride requests or upcoming rides.\nExplore destination groups with open driver seats to request a ride!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRequests.length,
      itemBuilder: (context, idx) {
        final req = myRequests[idx];
        final ride = appState.rides.firstWhere((r) => r.rideId == req.rideId, orElse: () => appState.rides[0]);
        final driver = appState.getDriver(req.driverId);
        final isConfirmed = req.status == 'ACCEPTED';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ride.destination,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isConfirmed ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isConfirmed ? 'Confirmed Ride' : 'Request Pending',
                        style: TextStyle(
                          color: isConfirmed ? const Color(0xFF047857) : const Color(0xFFB45309),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Driver: ${driver.name} • Departure: ${ride.departureTime}'),
                const SizedBox(height: 8),

                // Boarding Pass if confirmed
                if (isConfirmed) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF93C5FD)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BOARDING OTP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                            Text('AG-7193', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8))),
                          ],
                        ),
                        Text('Show to driver at pickup', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => appState.setTab(3), // Messages
                      icon: const Icon(Icons.chat, size: 14),
                      label: const Text('Message Driver', style: TextStyle(fontSize: 11.5)),
                    ),
                    TextButton(
                      onPressed: () => appState.cancelRequest(req.requestId),
                      child: const Text('Cancel Request', style: TextStyle(color: Colors.red, fontSize: 11.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Offered Rides (Drivers only)
  Widget _buildOfferedRidesTab(BuildContext context, AppState appState) {
    final myRides = appState.myOfferedRides;

    if (myRides.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No rides offered yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('You are a registered driver! Offer seats to community destination groups from the Home screen.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRides.length,
      itemBuilder: (context, idx) {
        final ride = myRides[idx];
        final pendingReqs = appState.requests.where((r) => r.rideId == ride.rideId && r.status == 'PENDING').toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(ride.destination, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    Text('${ride.availableSeats} of ${ride.totalSeats} seats open', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.aggieMaroon)),
                  ],
                ),
                Text('Departure: ${ride.departureDate} at ${ride.departureTime}'),
                const SizedBox(height: 10),

                // Pending requests for this driver
                if (pendingReqs.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Incoming Passenger Requests (${pendingReqs.length}):', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        const SizedBox(height: 6),
                        ...pendingReqs.map((req) {
                          final p = appState.users.firstWhere((u) => u.userId == req.passengerId, orElse: () => appState.users[0]);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p.name} (1 seat)', style: const TextStyle(fontSize: 12)),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => appState.acceptRequest(req.requestId),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                  const SizedBox(width: 4),
                                  OutlinedButton(
                                    onPressed: () => appState.rejectRequest(req.requestId),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      textStyle: const TextStyle(fontSize: 11),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNonDriverPrompt(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Driver Tools Restricted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Every user is a student; not every user is a driver. To offer rides, register as a driver in your Profile.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => appState.setTab(4), // Profile
              child: const Text('Go to Profile to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
