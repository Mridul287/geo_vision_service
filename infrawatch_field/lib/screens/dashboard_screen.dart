
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/incident.dart';
import 'incident_detail_screen.dart';
import 'notifications_history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final incidentsAsync = ref.watch(incidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Incidents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0f172a)),
              accountName: Text(auth.engineerName ?? 'Engineer'),
              accountEmail: Text('ID: ${auth.engineerId ?? 'N/A'}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xFF6366f1),
                child: Icon(Icons.person, color: Colors.white),
              ),
              otherAccountsPictures: const [
                Chip(
                  label: Text('Field Engineer', style: TextStyle(fontSize: 10)),
                  backgroundColor: Color(0xFF1e293b),
                ),
              ],
            ),
          ],
        ),
      ),
      body: incidentsAsync.when(
        data: (incidents) => incidents.isEmpty
            ? const Center(child: Text('No assigned incidents'))
            : ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return IncidentCard(
                    incident: incident,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetailScreen(incidentId: incident.id),
                        ),
                      );
                    },
                    severityColor: _getSeverityColor(incident.severity),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(incidentsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;
  final Color severityColor;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    incident.assetId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: severityColor),
                    ),
                    child: Text(
                      incident.severity.toUpperCase(),
                      style: TextStyle(color: severityColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident.assetType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    incident.location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned: ${DateFormat('yyyy-MM-dd HH:mm').format(incident.assignedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                  Text(
                    'Risk: ${incident.riskScore.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
