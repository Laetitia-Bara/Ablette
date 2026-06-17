import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/maintenance_schedule.dart';
import 'status_pill.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({required this.vehicle, required this.onTap, super.key});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = MaintenanceSchedule.nextFor(vehicle);
    final statusColor = next == null
        ? theme.colorScheme.primary
        : next.isDue
        ? const Color(0xFFB3261E)
        : next.isSoon
        ? const Color(0xFF9A6500)
        : const Color(0xFF2F6F5E);
    final statusLabel = next == null
        ? 'A jour'
        : next.isDue
        ? 'A faire'
        : next.isSoon
        ? 'Bientot'
        : 'Planifie';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
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
                          vehicle.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${vehicle.identity} - ${vehicle.year}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(label: statusLabel, color: statusColor),
                  if (vehicle.mileagePromptDue)
                    const StatusPill(
                      label: 'Km a saisir',
                      color: Color(0xFF4B5EAA),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.speed, size: 18),
                  const SizedBox(width: 6),
                  Text('${_km(vehicle.currentMileage)} km'),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      next?.rule.title ?? 'Aucun entretien',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (next != null) ...[
                const SizedBox(height: 5),
                Text(
                  next.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
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
