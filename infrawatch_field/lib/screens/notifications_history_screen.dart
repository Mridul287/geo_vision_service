
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String assetId;
  final String severity;
  final String location;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.assetId,
    required this.severity,
    required this.location,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsHistoryScreen extends StatefulWidget {
  const NotificationsHistoryScreen({super.key});

  @override
  State<NotificationsHistoryScreen> createState() => _NotificationsHistoryScreenState();
}

class _NotificationsHistoryScreenState extends State<NotificationsHistoryScreen> {
  // Placeholder notifications
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'NOT_001',
      assetId: 'BRIDGE_001',
      severity: 'CRITICAL',
      location: '19.0760, 72.8777',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NOT_002',
      assetId: 'TRANSFORMER_007',
      severity: 'HIGH',
      location: '19.0900, 72.8900',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: 'NOT_003',
      assetId: 'PIPE_042',
      severity: 'MEDIUM',
      location: '19.0820, 72.8830',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications History'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n.isRead = true;
                }
              });
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF1e293b)),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  tileColor: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(notification.severity).withOpacity(0.2),
                    child: Icon(
                      Icons.notifications,
                      color: _getSeverityColor(notification.severity),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        notification.assetId,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSeverityTag(notification.severity),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Location: ${notification.location}'),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(notification.timestamp),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: notification.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () {
                    setState(() {
                      notification.isRead = true;
                    });
                    // TODO: Navigate to incident detail
                  },
                );
              },
            ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.orange;
      case 'MEDIUM': return Colors.yellow;
      default: return Colors.green;
    }
  }

  Widget _buildSeverityTag(String severity) {
    final color = _getSeverityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        severity,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
