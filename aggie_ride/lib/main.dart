import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/find_rides_screen.dart';
import 'screens/my_rides_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AggieRideApp());
}

class AggieRideApp extends StatelessWidget {
  const AggieRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: MaterialApp(
        title: 'AggieRide — Where Aggies Go, Aggies Ride | Texas A&M',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Authentication Gate: Shows Login if unauthenticated, otherwise launches MainScaffold
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.aggieMaroon),
              SizedBox(height: 16),
              Text(
                'Connecting to AggieRide...',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.aggieMaroon),
              ),
            ],
          ),
        ),
      );
    }

    if (!appState.isAuthenticated) {
      return const LoginScreen();
    }

    return const MainScaffold();
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // 5 Tab Navigation: 0: Home, 1: Discover, 2: My Journeys, 3: Messages, 4: Profile
  final List<Widget> _pages = const [
    HomeScreen(),
    FindRidesScreen(),
    MyRidesScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final unreadNotifCount = appState.unreadNotificationsCount;
    final isDriver = appState.isDriver;

    // Listen for toast messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.toastMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.toastMessage!),
            backgroundColor: AppTheme.aggieMaroonDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(milliseconds: 2500),
          ),
        );
        appState.clearToast();
      }
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppTheme.aggieMaroon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AggieRide',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3),
                  ),
                  Text(
                    'Where Aggies Go, Aggies Ride',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFFFCA5A5), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // User Avatar Pill
            if (currentUser != null)
              GestureDetector(
                onTap: () => appState.setTab(4), // Profile
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(currentUser.avatar),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentUser.name.split(' ').first,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (currentUser.isTamuVerified) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.verified, size: 12, color: Color(0xFF86EFAC)),
                      ],
                    ],
                  ),
                ),
              ),

            // Notifications Icon with Badge
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, size: 22),
                  if (unreadNotifCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE047),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadNotifCount',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),

            // Quick Persona Switcher Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) async {
                if (val == 'signout') {
                  await appState.signOut();
                } else if (val == 'reset') {
                  await appState.resetDemo();
                } else if (val.startsWith('user:')) {
                  final uid = val.substring(5);
                  await appState.switchUser(uid);
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'SWITCH TEST PERSONA',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  ...appState.users.map((u) {
                    final isCurrent = currentUser?.userId == u.userId;
                    return PopupMenuItem(
                      value: 'user:${u.userId}',
                      child: Row(
                        children: [
                          Icon(
                            isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 16,
                            color: isCurrent ? AppTheme.aggieMaroon : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${u.name} (${u.isDriverVerified ? "Driver" : "Passenger"})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.restart_alt, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Reset Demo Data', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ];
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: appState.activeTab,
          children: _pages,
        ),
      ),
      // Floating Action Button: ONLY visible for registered drivers!
      floatingActionButton: (isDriver && appState.activeTab <= 1)
          ? FloatingActionButton.extended(
              onPressed: () {
                _showOfferRideSheet(context, appState);
              },
              backgroundColor: AppTheme.aggieMaroon,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('Offer a Ride', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      // 5-Tab Navigation Bar (Notice: "Offer" removed from bottom nav for regular users!)
      bottomNavigationBar: NavigationBar(
        selectedIndex: appState.activeTab,
        onDestinationSelected: (idx) => appState.setTab(idx),
        indicatorColor: AppTheme.primaryContainer,
        backgroundColor: Colors.white,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppTheme.aggieMaroon),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_work_outlined),
            selectedIcon: Icon(Icons.group_work, color: AppTheme.aggieMaroon),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route, color: AppTheme.aggieMaroon),
            label: 'My Journeys',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.aggieMaroon),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.aggieMaroon),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showOfferRideSheet(BuildContext context, AppState appState) {
    final originController = TextEditingController(text: 'Northgate / College Main');
    final destController = TextEditingController(text: 'Walmart Supercenter (Bryan / CS)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Offer Seats to Aggies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Publish an empty car trip to a destination group.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 14),
            TextField(controller: originController, decoration: const InputDecoration(labelText: 'Starting Point')),
            const SizedBox(height: 10),
            TextField(controller: destController, decoration: const InputDecoration(labelText: 'Destination')),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                    notes: 'Leaving at 11 AM sharp. Trunk space for groceries.',
                    isRecurring: false,
                    recurringDays: const [],
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Publish Ride to Destination Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
