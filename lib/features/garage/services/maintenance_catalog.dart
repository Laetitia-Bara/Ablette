import '../models/maintenance.dart';
import '../models/vehicle.dart';

class MaintenanceCatalog {
  const MaintenanceCatalog._();

  static List<MaintenanceRule> rulesFor({
    required String fuel,
    bool timingBelt = true,
  }) {
    final diesel = fuel.toLowerCase().contains('diesel');

    return [
      const MaintenanceRule(
        id: 'oil',
        title: 'Vidange moteur',
        description: 'Huile moteur et filtre a huile',
        kind: MaintenanceKind.engine,
        intervalKm: 15000,
        intervalMonths: 12,
      ),
      const MaintenanceRule(
        id: 'air_filter',
        title: 'Filtre a air',
        description: 'Controle ou remplacement du filtre a air',
        kind: MaintenanceKind.engine,
        intervalKm: 30000,
        intervalMonths: 24,
      ),
      MaintenanceRule(
        id: 'fuel_filter',
        title: diesel ? 'Filtre a gazole' : 'Filtre a carburant',
        description: diesel
            ? 'Remplacement du filtre a gazole'
            : 'Controle du filtre a carburant',
        kind: MaintenanceKind.engine,
        intervalKm: diesel ? 30000 : 60000,
        intervalMonths: diesel ? 24 : 48,
      ),
      const MaintenanceRule(
        id: 'brakes',
        title: 'Freins',
        description: 'Plaquettes, disques et niveau de liquide',
        kind: MaintenanceKind.safety,
        intervalKm: 20000,
        intervalMonths: 12,
      ),
      const MaintenanceRule(
        id: 'tires',
        title: 'Pneus',
        description: 'Usure, pression et permutation si besoin',
        kind: MaintenanceKind.safety,
        intervalKm: 10000,
        intervalMonths: 6,
      ),
      const MaintenanceRule(
        id: 'wipers',
        title: 'Essuie-glaces',
        description: 'Balais avant et arriere',
        kind: MaintenanceKind.wear,
        intervalMonths: 12,
      ),
      const MaintenanceRule(
        id: 'battery',
        title: 'Batterie',
        description: 'Controle de charge et cosses',
        kind: MaintenanceKind.wear,
        intervalMonths: 36,
      ),
      if (timingBelt)
        const MaintenanceRule(
          id: 'timing_belt',
          title: 'Courroie de distribution',
          description: 'Distribution et pompe a eau selon preconisation',
          kind: MaintenanceKind.engine,
          intervalKm: 120000,
          intervalMonths: 72,
        ),
      const MaintenanceRule(
        id: 'technical_inspection',
        title: 'Controle technique',
        description: 'Controle reglementaire',
        kind: MaintenanceKind.admin,
        intervalMonths: 24,
      ),
    ];
  }

  static final templates = <VehicleTemplate>[
    VehicleTemplate(
      brand: 'Renault',
      model: 'Clio II',
      yearFrom: 1998,
      yearTo: 2012,
      fuel: 'Essence',
      engine: '1.2 16V',
      referenceCode: 'ADEME-ready',
      rules: rulesFor(fuel: 'Essence'),
    ),
    VehicleTemplate(
      brand: 'Peugeot',
      model: '206',
      yearFrom: 1998,
      yearTo: 2012,
      fuel: 'Diesel',
      engine: '1.4 HDi',
      referenceCode: 'ADEME-ready',
      rules: rulesFor(fuel: 'Diesel'),
    ),
    VehicleTemplate(
      brand: 'Citroen',
      model: 'C3 I',
      yearFrom: 2002,
      yearTo: 2010,
      fuel: 'Essence',
      engine: '1.4i',
      referenceCode: 'ADEME-ready',
      rules: rulesFor(fuel: 'Essence'),
    ),
    VehicleTemplate(
      brand: 'Toyota',
      model: 'Yaris I',
      yearFrom: 1999,
      yearTo: 2005,
      fuel: 'Essence',
      engine: '1.0 VVT-i',
      referenceCode: 'ADEME-ready',
      rules: rulesFor(fuel: 'Essence', timingBelt: false),
    ),
    VehicleTemplate(
      brand: 'Volkswagen',
      model: 'Golf IV',
      yearFrom: 1997,
      yearTo: 2006,
      fuel: 'Diesel',
      engine: '1.9 TDI',
      referenceCode: 'ADEME-ready',
      rules: rulesFor(fuel: 'Diesel'),
    ),
  ];

  static List<VehicleTemplate> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return templates;
    }

    return templates.where((template) {
      final haystack = [
        template.brand,
        template.model,
        template.engine,
        template.fuel,
      ].join(' ').toLowerCase();
      return haystack.contains(normalized);
    }).toList();
  }
}
