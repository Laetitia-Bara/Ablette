import 'package:flutter/material.dart';

import '../../../app.dart';
import '../models/maintenance.dart';
import '../models/vehicle.dart';
import '../services/maintenance_schedule.dart';
import '../widgets/status_pill.dart';

class VehicleDetailPage extends StatelessWidget {
  const VehicleDetailPage({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final store = GarageScope.of(context);
    final vehicle = store.vehicleById(vehicleId);
    final statuses = MaintenanceSchedule.statusesFor(vehicle);

    return Scaffold(
      appBar: AppBar(title: Text(vehicle.displayName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _VehicleSummary(vehicle: vehicle),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openMileageDialog(context, vehicle),
              icon: const Icon(Icons.speed),
              label: const Text('Mettre a jour les km'),
            ),
            const SizedBox(height: 22),
            Text(
              'Entretiens',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...statuses.map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MaintenanceTile(
                  vehicle: vehicle,
                  status: status,
                  onDone: () {
                    store.markDone(vehicle.id, status.rule.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${status.rule.title} marque fait'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMileageDialog(BuildContext context, Vehicle vehicle) async {
    final controller = TextEditingController(
      text: vehicle.currentMileage.toString(),
    );
    final store = GarageScope.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kilometrage'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              suffixText: 'km',
              prefixIcon: Icon(Icons.speed),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final mileage = int.tryParse(controller.text.trim());
                if (mileage == null || mileage < 0) {
                  return;
                }
                store.updateMileage(vehicle.id, mileage);
                Navigator.of(context).pop();
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car_filled_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.identity,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${vehicle.year} - ${vehicle.fuel}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Metric(
                  icon: Icons.speed,
                  label: '${_km(vehicle.currentMileage)} km',
                ),
                _Metric(
                  icon: Icons.trending_up,
                  label: '${vehicle.monthlyMileageEstimate} km/mois',
                ),
                if (vehicle.referenceCode != null)
                  _Metric(
                    icon: Icons.tag_outlined,
                    label: vehicle.referenceCode!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _km(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({
    required this.vehicle,
    required this.status,
    required this.onDone,
  });

  final Vehicle vehicle;
  final MaintenanceStatus status;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final record = vehicle.maintenanceRecords[status.rule.id];
    final color = status.isDue
        ? const Color(0xFFB3261E)
        : status.isSoon
        ? const Color(0xFF9A6500)
        : const Color(0xFF2F6F5E);
    final label = status.isDue
        ? 'A faire'
        : status.isSoon
        ? 'Bientot'
        : 'OK';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconFor(status.rule.kind), color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.rule.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(status.rule.description),
                    ],
                  ),
                ),
                StatusPill(label: label, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(status.reason),
            if (record != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dernier: ${_date(record.doneAt)} a ${_km(record.mileage)} km',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check),
                label: const Text('Fait'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(MaintenanceKind kind) {
    return switch (kind) {
      MaintenanceKind.engine => Icons.settings_outlined,
      MaintenanceKind.safety => Icons.health_and_safety_outlined,
      MaintenanceKind.wear => Icons.handyman_outlined,
      MaintenanceKind.admin => Icons.assignment_outlined,
    };
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _km(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }
}
