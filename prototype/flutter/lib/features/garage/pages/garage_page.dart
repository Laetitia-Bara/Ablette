import 'package:flutter/material.dart';

import '../../../app.dart';
import '../models/vehicle.dart';
import '../services/maintenance_schedule.dart';
import '../widgets/status_pill.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_page.dart';
import 'vehicle_detail_page.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _GarageTab(onAddVehicle: _openAddVehicle, onOpenVehicle: _openVehicle),
      _RemindersTab(onOpenVehicle: _openVehicle),
      const _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ablette'),
        actions: [
          IconButton(
            tooltip: 'Ajouter',
            onPressed: _openAddVehicle,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'Garage',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Rappels',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Future<void> _openAddVehicle() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddVehiclePage()));
  }

  Future<void> _openVehicle(Vehicle vehicle) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleDetailPage(vehicleId: vehicle.id),
      ),
    );
  }
}

class _GarageTab extends StatelessWidget {
  const _GarageTab({required this.onAddVehicle, required this.onOpenVehicle});

  final VoidCallback onAddVehicle;
  final ValueChanged<Vehicle> onOpenVehicle;

  @override
  Widget build(BuildContext context) {
    final store = GarageScope.of(context);
    final vehicles = store.vehicles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(
          title: 'Garage',
          subtitle:
              '${vehicles.length} vehicule${vehicles.length > 1 ? 's' : ''}',
          action: FilledButton.icon(
            onPressed: onAddVehicle,
            icon: const Icon(Icons.add),
            label: const Text('Vehicule'),
          ),
        ),
        const SizedBox(height: 16),
        if (vehicles.isEmpty)
          _EmptyGarage(onAddVehicle: onAddVehicle)
        else
          ...vehicles.map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VehicleCard(
                vehicle: vehicle,
                onTap: () => onOpenVehicle(vehicle),
              ),
            ),
          ),
      ],
    );
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab({required this.onOpenVehicle});

  final ValueChanged<Vehicle> onOpenVehicle;

  @override
  Widget build(BuildContext context) {
    final store = GarageScope.of(context);
    final entries = [
      for (final vehicle in store.vehicles)
        for (final status in MaintenanceSchedule.statusesFor(vehicle))
          if (status.isDue || status.isSoon || vehicle.mileagePromptDue)
            (vehicle: vehicle, status: status),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(
          title: 'Rappels',
          subtitle: entries.isEmpty
              ? 'Aucun rappel actif'
              : '${entries.length} a suivre',
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Tout est calme pour le moment.'),
            ),
          )
        else
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  onTap: () => onOpenVehicle(entry.vehicle),
                  leading: Icon(
                    entry.status.isDue
                        ? Icons.priority_high
                        : Icons.schedule_outlined,
                  ),
                  title: Text(entry.status.rule.title),
                  subtitle: Text(
                    '${entry.vehicle.displayName} - ${entry.status.reason}',
                  ),
                  trailing: StatusPill(
                    label: entry.status.isDue ? 'A faire' : 'Bientot',
                    color: entry.status.isDue
                        ? const Color(0xFFB3261E)
                        : const Color(0xFF9A6500),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        _Header(title: 'Profil', subtitle: 'Mode local'),
        SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Compte invite'),
            subtitle: Text('Firebase Auth sera branche ici.'),
          ),
        ),
        SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: Icon(Icons.cloud_sync_outlined),
            title: Text('Synchronisation'),
            subtitle: Text('Firestore remplacera les donnees locales.'),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.action});

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerAction = action;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ?headerAction,
      ],
    );
  }
}

class _EmptyGarage extends StatelessWidget {
  const _EmptyGarage({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.garage_outlined, size: 36),
            const SizedBox(height: 12),
            Text(
              'Ajoute le premier vehicule',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Ablette preparera les entretiens de base.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Vehicule'),
            ),
          ],
        ),
      ),
    );
  }
}
