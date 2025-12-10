import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class NotificationService extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchNotifications();
        _subscribeToRealtime();
      } else {
        _notifications = [];
        notifyListeners();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      await fetchNotifications();
      _subscribeToRealtime();
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      final data = await client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(20);

      _notifications = (data as List).map((e) => NotificationModel.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Notification Fetch Error: \$e");
    }
  }

  void _subscribeToRealtime() {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid,
          ),
          callback: (payload) {
            final newNotif = NotificationModel.fromMap(payload.newRecord);
            _notifications.insert(0, newNotif);
            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String id) async {
    try {
      final client = Supabase.instance.client;
      await client.from('notifications').update({'is_read': true}).eq('id', id);
      
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true, // Optimistic update
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Mark Read Error: \$e");
    }
  }
  
  Future<void> markAllAsRead() async {
     try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      await client.from('notifications').update({'is_read': true}).eq('user_id', uid).eq('is_read', false);
      
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
           _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            type: _notifications[i].type,
            isRead: true,
            createdAt: _notifications[i].createdAt,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Mark All Read Error: \$e");
    }
  }
}
