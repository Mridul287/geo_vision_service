
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/incident.dart';

class IncidentDetailScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends ConsumerState<IncidentDetailScreen> {
  final _reportController = TextEditingController();
  String _selectedOutcome = 'Issue Confirmed';
  bool _isSubmitting = false;

  final List<String> _outcomes = [
    'Issue Confirmed',
    'Issue Not Found',
    'Requires Further Inspection',
  ];

  Future<void> _updateStatus(String status) async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiServiceProvider).updateIncidentStatus(widget.incidentId, status);
      ref.invalidate(incidentDetailProvider(widget.incidentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitReport() async {
    if (_reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a field report before submitting')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final auth = ref.read(authProvider);
      await ref.read(apiServiceProvider).submitFieldReport(
            incidentId: widget.incidentId,
            outcome: _selectedOutcome,
            message: _reportController.text,
            engineerId: auth.engineerId!,
            timestamp: DateTime.now(),
          );
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Field report has been successfully submitted.'),
            const SizedBox(height: 16),
            Text(
              'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to dashboard
              ref.invalidate(incidentsProvider);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidentAsync = ref.watch(incidentDetailProvider(widget.incidentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Detail')),
      body: incidentAsync.when(
        data: (incident) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(incident),
              const Divider(height: 32),
              _buildShapFactors(incident),
              const Divider(height: 32),
              _buildStatusSection(incident),
              const Divider(height: 32),
              _buildReportSection(),
              const SizedBox(height: 32),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                _buildActionButtons(incident),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(Incident incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              incident.assetId,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildSeverityBadge(incident.severity),
          ],
        ),
        const SizedBox(height: 8),
        Text('Type: ${incident.assetType}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('Location: ${incident.location}', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text('Assigned: ${DateFormat('yyyy-MM-dd HH:mm').format(incident.assignedAt)}', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toUpperCase()) {
      case 'CRITICAL': color = Colors.red; break;
      case 'HIGH': color = Colors.orange; break;
      case 'MEDIUM': color = Colors.yellow; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildShapFactors(Incident incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Why was this flagged?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...incident.shapFactors.map((factor) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(factor)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildStatusSection(Incident incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Current Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(incident.status, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Field Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedOutcome,
          decoration: const InputDecoration(labelText: 'Outcome'),
          items: _outcomes.map((outcome) => DropdownMenuItem(value: outcome, child: Text(outcome))).toList(),
          onChanged: (val) => setState(() => _selectedOutcome = val!),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reportController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Findings',
            hintText: 'Describe your field findings here...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Incident incident) {
    return Column(
      children: [
        if (incident.status != 'In Progress' && incident.status != 'Resolved')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus('In Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark In Progress'),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: incident.status == 'Resolved' ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit & Mark Resolved'),
          ),
        ),
      ],
    );
  }
}
