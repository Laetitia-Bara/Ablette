import 'package:flutter/foundation.dart';

import '../models/maintenance.dart';
import '../models/vehicle.dart';
import 'maintenance_catalog.dart';

class GarageStore extends ChangeNotifier {
  GarageStore({List<Vehicle>? vehicles}) : _vehicles = vehicles ?? [];

  factory GarageStore.seeded() {
    final now = DateTime.now();
    final template = MaintenanceCatalog.templates.first;
    final secondTemplate = MaintenanceCatalog.templates[1];

    return GarageStore(
      vehicles: [
        Vehicle(
          id: 'vehicle-1',
          nickname: 'Clio de papa',
          brand: template.brand,
          model: template.model,
          year: 2005,
          fuel: template.fuel,
          engine: template.engine,
          currentMileage: 162400,
          monthlyMileageEstimate: 650,
          addedAt: now.subtract(const Duration(days: 90)),
          lastMileagePromptAt: now.subtract(const Duration(days: 37)),
          referenceCode: template.referenceCode,
          maintenanceRules: template.rules,
          maintenanceRecords: {
            'oil': MaintenanceRecord(
              ruleId: 'oil',
              doneAt: now.subtract(const Duration(days: 370)),
              mileage: 148000,
            ),
            'technical_inspection': MaintenanceRecord(
              ruleId: 'technical_inspection',
              doneAt: now.subtract(const Duration(days: 680)),
              mileage: 151000,
            ),
          },
        ),
        Vehicle(
          id: 'vehicle-2',
          nickname: '206',
          brand: secondTemplate.brand,
          model: secondTemplate.model,
          year: 2007,
          fuel: secondTemplate.fuel,
          engine: secondTemplate.engine,
          currentMileage: 224100,
          monthlyMileageEstimate: 400,
          addedAt: now.subtract(const Duration(days: 25)),
          lastMileagePromptAt: now.subtract(const Duration(days: 10)),
          referenceCode: secondTemplate.referenceCode,
          maintenanceRules: secondTemplate.rules,
          maintenanceRecords: const {},
        ),
      ],
    );
  }

  final List<Vehicle> _vehicles;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  Vehicle vehicleById(String id) {
    return _vehicles.firstWhere((vehicle) => vehicle.id == id);
  }

  void addVehicle({
    required String nickname,
    required String brand,
    required String model,
    required int year,
    required String fuel,
    required String engine,
    required int mileage,
    required int monthlyMileageEstimate,
    String? referenceCode,
    List<MaintenanceRule>? rules,
  }) {
    final now = DateTime.now();
    final vehicle = Vehicle(
      id: 'vehicle-${now.microsecondsSinceEpoch}',
      nickname: nickname,
      brand: brand,
      model: model,
      year: year,
      fuel: fuel,
      engine: engine,
      currentMileage: mileage,
      monthlyMileageEstimate: monthlyMileageEstimate,
      addedAt: now,
      lastMileagePromptAt: now,
      referenceCode: referenceCode,
      maintenanceRules: rules ?? MaintenanceCatalog.rulesFor(fuel: fuel),
      maintenanceRecords: const {},
    );

    _vehicles.insert(0, vehicle);
    notifyListeners();
  }

  void updateMileage(String vehicleId, int mileage) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
    if (index == -1) {
      return;
    }

    final current = _vehicles[index];
    _vehicles[index] = current.copyWith(
      currentMileage: mileage,
      lastMileagePromptAt: DateTime.now(),
    );
    notifyListeners();
  }

  void markDone(String vehicleId, String ruleId) {
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == vehicleId);
    if (index == -1) {
      return;
    }

    final current = _vehicles[index];
    final records = Map<String, MaintenanceRecord>.from(
      current.maintenanceRecords,
    );
    records[ruleId] = MaintenanceRecord(
      ruleId: ruleId,
      doneAt: DateTime.now(),
      mileage: current.currentMileage,
    );

    _vehicles[index] = current.copyWith(maintenanceRecords: records);
    notifyListeners();
  }
}
