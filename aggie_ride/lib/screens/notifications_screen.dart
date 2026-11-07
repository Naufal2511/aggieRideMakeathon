import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifs = appState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          if (notifs.isNotEmpty) ...[
            TextButton(
              onPressed: () => appState.markAllNotificationsRead(),
              child: const Text('Mark Read', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              tooltip: 'Clear All',
              onPressed: () => appState.clearAllNotifications(),
            ),
          ],
        ],
      ),
      body: notifs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_none, size: 52, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'You\'ll receive real-time alerts when someone requests a seat or accepts your ride!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifs[index];
                IconData icon;
                Color iconColor;

                switch (n.type) {
                  case 'REQUEST_RECEIVED':
                    icon = Icons.notification_important;
                    iconColor = AppTheme.statusAmber;
                    break;
                  case 'REQUEST_ACCEPTED':
                    icon = Icons.check_circle;
                    iconColor = AppTheme.statusGreen;
                    break;
                  case 'REQUEST_REJECTED':
                    icon = Icons.cancel;
                    iconColor = Colors.red;
                    break;
                  default:
                    icon = Icons.directions_car;
                    iconColor = AppTheme.aggieMaroon;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.12),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(n.body, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                      const SizedBox(height: 4),
                      Text(
                        n.createdAt.contains('T')
                            ? n.createdAt.split('T').first
                            : n.createdAt,
                        style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: !n.isRead
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.aggieMaroon,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
