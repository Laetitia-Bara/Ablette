import 'maintenance.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.nickname,
    required this.brand,
    required this.model,
    required this.year,
    required this.fuel,
    required this.engine,
    required this.currentMileage,
    required this.monthlyMileageEstimate,
    required this.addedAt,
    required this.lastMileagePromptAt,
    required this.maintenanceRules,
    required this.maintenanceRecords,
    this.referenceCode,
  });

  final String id;
  final String nickname;
  final String brand;
  final String model;
  final int year;
  final String fuel;
  final String engine;
  final int currentMileage;
  final int monthlyMileageEstimate;
  final DateTime addedAt;
  final DateTime lastMileagePromptAt;
  final String? referenceCode;
  final List<MaintenanceRule> maintenanceRules;
  final Map<String, MaintenanceRecord> maintenanceRecords;

  String get displayName =>
      nickname.trim().isEmpty ? '$brand $model' : nickname;

  String get identity => '$brand $model $engine';

  bool get mileagePromptDue {
    return DateTime.now().difference(lastMileagePromptAt).inDays >= 30;
  }

  Vehicle copyWith({
    String? id,
    String? nickname,
    String? brand,
    String? model,
    int? year,
    String? fuel,
    String? engine,
    int? currentMileage,
    int? monthlyMileageEstimate,
    DateTime? addedAt,
    DateTime? lastMileagePromptAt,
    String? referenceCode,
    List<MaintenanceRule>? maintenanceRules,
    Map<String, MaintenanceRecord>? maintenanceRecords,
  }) {
    return Vehicle(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      fuel: fuel ?? this.fuel,
      engine: engine ?? this.engine,
      currentMileage: currentMileage ?? this.currentMileage,
      monthlyMileageEstimate:
          monthlyMileageEstimate ?? this.monthlyMileageEstimate,
      addedAt: addedAt ?? this.addedAt,
      lastMileagePromptAt: lastMileagePromptAt ?? this.lastMileagePromptAt,
      referenceCode: referenceCode ?? this.referenceCode,
      maintenanceRules: maintenanceRules ?? this.maintenanceRules,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
    );
  }
}

class VehicleTemplate {
  const VehicleTemplate({
    required this.brand,
    required this.model,
    required this.yearFrom,
    required this.yearTo,
    required this.fuel,
    required this.engine,
    required this.referenceCode,
    required this.rules,
  });

  final String brand;
  final String model;
  final int yearFrom;
  final int yearTo;
  final String fuel;
  final String engine;
  final String referenceCode;
  final List<MaintenanceRule> rules;

  String get label => '$brand $model $engine ($yearFrom-$yearTo)';
}
