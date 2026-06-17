import '../models/maintenance.dart';
import '../models/vehicle.dart';

class MaintenanceSchedule {
  const MaintenanceSchedule._();

  static List<MaintenanceStatus> statusesFor(Vehicle vehicle) {
    final now = DateTime.now();
    final statuses = vehicle.maintenanceRules.map((rule) {
      final record = vehicle.maintenanceRecords[rule.id];
      final baseDate = record?.doneAt ?? vehicle.addedAt;
      final baseMileage = record?.mileage ?? vehicle.currentMileage;

      final dueByDate = rule.intervalMonths == null
          ? null
          : DateTime(
              baseDate.year,
              baseDate.month + rule.intervalMonths!,
              baseDate.day,
            );
      final dueByMileage = rule.intervalKm == null
          ? null
          : baseMileage + rule.intervalKm!;

      final monthsSoon =
          dueByDate != null && dueByDate.difference(now).inDays <= 30;
      final kmSoon =
          dueByMileage != null &&
          dueByMileage - vehicle.currentMileage <=
              (vehicle.monthlyMileageEstimate * 2).clamp(500, 3000);

      final isDue =
          (dueByDate != null && !dueByDate.isAfter(now)) ||
          (dueByMileage != null && dueByMileage <= vehicle.currentMileage);
      final isSoon = !isDue && (monthsSoon || kmSoon);

      final reason = _reason(
        now: now,
        dueByDate: dueByDate,
        dueByMileage: dueByMileage,
        currentMileage: vehicle.currentMileage,
      );

      return MaintenanceStatus(
        rule: rule,
        isDue: isDue,
        isSoon: isSoon,
        reason: reason,
        sortDate: dueByDate ?? now.add(const Duration(days: 3650)),
      );
    }).toList();

    statuses.sort((a, b) {
      final priority = _priority(b).compareTo(_priority(a));
      if (priority != 0) {
        return priority;
      }
      return a.sortDate.compareTo(b.sortDate);
    });
    return statuses;
  }

  static MaintenanceStatus? nextFor(Vehicle vehicle) {
    final statuses = statusesFor(vehicle);
    for (final status in statuses) {
      if (status.isDue || status.isSoon) {
        return status;
      }
    }
    return statuses.isEmpty ? null : statuses.first;
  }

  static int _priority(MaintenanceStatus status) {
    if (status.isDue) {
      return 2;
    }
    if (status.isSoon) {
      return 1;
    }
    return 0;
  }

  static String _reason({
    required DateTime now,
    required DateTime? dueByDate,
    required int? dueByMileage,
    required int currentMileage,
  }) {
    final parts = <String>[];

    if (dueByDate != null) {
      final days = dueByDate.difference(now).inDays;
      if (days < 0) {
        parts.add('depuis ${-days} j');
      } else if (days == 0) {
        parts.add('aujourd hui');
      } else {
        parts.add('dans $days j');
      }
    }

    if (dueByMileage != null) {
      final remaining = dueByMileage - currentMileage;
      if (remaining <= 0) {
        parts.add('${_formatKm(-remaining)} km depasses');
      } else {
        parts.add('dans ${_formatKm(remaining)} km');
      }
    }

    return parts.isEmpty ? 'a planifier' : parts.join(' ou ');
  }

  static String _formatKm(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }
}
