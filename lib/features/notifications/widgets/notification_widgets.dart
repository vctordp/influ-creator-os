import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height + 10,
        right: MediaQuery.of(context).size.width - (offset.dx + size.width),
        child: Material(
          color: Colors.transparent,
          child: NotificationDropdown(
            onClose: () {
              _removeOverlay();
              setState(() => _isOpen = false);
            },
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // Watch service for count
    final unreadCount = context.watch<NotificationService>().unreadCount;

    if (unreadCount > 0) {
      _controller.forward().then((_) => _controller.reverse());
    }

    return GestureDetector(
      onTap: _toggleDropdown,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCFF00), // Acid Green
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationDropdown extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationDropdown({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationService>().notifications;

    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<NotificationService>().markAllAsRead();
                  },
                  child: const Text(
                    "Mark all read",
                    style: TextStyle(color: Color(0xFFCCFF00), fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          
          // List
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  "No notifications yet",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return InkWell(
                    onTap: () {
                      if (!n.isRead) {
                        context.read<NotificationService>().markAsRead(n.id);
                      }
                    },
                    child: Container(
                      color: n.isRead ? Colors.transparent : Colors.white.withOpacity(0.05),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIcon(n.type),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  timeago.format(n.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFCCFF00),
                                shape: BoxShape.circle,
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'success':
      case 'reward':
        icon = Icons.check_circle_outline;
        color = const Color(0xFFCCFF00);
        break;
      case 'warning':
        icon = Icons.warning_amber_rounded;
        color = Colors.orangeAccent;
        break;
      case 'info':
      default:
        icon = Icons.info_outline;
        color = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
