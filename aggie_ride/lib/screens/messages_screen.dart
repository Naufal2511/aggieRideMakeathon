import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Map<String, dynamic>? _selectedConversation;
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _openChatDialog(BuildContext context, Map<String, dynamic> conv) {
    setState(() {
      _selectedConversation = conv;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final messages = List<Map<String, dynamic>>.from(conv['messages'] ?? []);
            final partnerName = conv['partnerName'] ?? 'Aggie Student';
            final partnerAvatar = conv['partnerAvatar'] ?? '';
            final contextRide = conv['contextRide'] ?? 'Shared Ride';
            final pickupZone = conv['pickupZone'] ?? 'College Station';

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                top: 12,
                left: 16,
                right: 16,
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 10),

                  // Header
                  Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundImage: NetworkImage(partnerAvatar)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(partnerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const Text('Verified TAMU Student', style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Contextual Ride Header at Top of Conversation
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.aggieMaroon.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contextRide, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('Pickup: $pickupZone', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Confirmed', style: TextStyle(color: Color(0xFF047857), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Messages Stream
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, idx) {
                        final msg = messages[idx];
                        final isMe = msg['isMe'] == true;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppTheme.aggieMaroon : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  msg['time'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : Colors.black45,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: InputDecoration(
                            hintText: 'Type a message to coordinate pickup...',
                            hintStyle: const TextStyle(fontSize: 12.5),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          final text = _msgController.text.trim();
                          if (text.isNotEmpty) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            appState.sendChatMessage(conv['conversationId'] as String, text);
                            _msgController.clear();
                            setModalState(() {});
                          }
                        },
                        style: IconButton.styleFrom(backgroundColor: AppTheme.aggieMaroon),
                        icon: const Icon(Icons.send, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final convs = appState.conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Coordination', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Privacy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFEF2F2),
            child: const Row(
              children: [
                Icon(Icons.shield, color: AppTheme.aggieMaroon, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phone numbers are kept private. Coordinate safely with fellow verified Texas A&M students.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D)),
                  ),
                ),
              ],
            ),
          ),

          // Conversation List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: convs.length,
              itemBuilder: (context, idx) {
                final conv = convs[idx];
                final unread = (conv['unreadCount'] as int?) ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(conv['partnerAvatar'] as String),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(conv['partnerName'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(conv['timestamp'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          conv['lastMessage'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            conv['contextRide'] as String,
                            style: const TextStyle(fontSize: 10, color: AppTheme.aggieMaroon, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    trailing: unread > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        : null,
                    onTap: () => _openChatDialog(context, conv),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

