enum MaintenanceKind { engine, safety, wear, admin }

class MaintenanceRule {
  const MaintenanceRule({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    this.intervalKm,
    this.intervalMonths,
  });

  final String id;
  final String title;
  final String description;
  final MaintenanceKind kind;
  final int? intervalKm;
  final int? intervalMonths;
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.ruleId,
    required this.doneAt,
    required this.mileage,
  });

  final String ruleId;
  final DateTime doneAt;
  final int mileage;

  MaintenanceRecord copyWith({String? ruleId, DateTime? doneAt, int? mileage}) {
    return MaintenanceRecord(
      ruleId: ruleId ?? this.ruleId,
      doneAt: doneAt ?? this.doneAt,
      mileage: mileage ?? this.mileage,
    );
  }
}

class MaintenanceStatus {
  const MaintenanceStatus({
    required this.rule,
    required this.isDue,
    required this.isSoon,
    required this.reason,
    required this.sortDate,
  });

  final MaintenanceRule rule;
  final bool isDue;
  final bool isSoon;
  final String reason;
  final DateTime sortDate;
}
