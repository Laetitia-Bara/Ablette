import 'package:flutter/material.dart';

import '../../../app.dart';
import '../models/vehicle.dart';
import '../services/maintenance_catalog.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _engineController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _monthlyMileageController = TextEditingController(text: '500');
  String _fuel = 'Essence';
  VehicleTemplate? _selectedTemplate;

  @override
  void dispose() {
    _searchController.dispose();
    _nicknameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _engineController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _monthlyMileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = MaintenanceCatalog.search(_searchController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un vehicule')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Recherche marque, modele, moteur',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: templates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    final selected = template == _selectedTemplate;
                    return SizedBox(
                      width: 250,
                      child: Card(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.white,
                        child: InkWell(
                          onTap: () => _applyTemplate(template),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const Spacer(),
                                Text(
                                  '${template.fuel} - ${template.referenceCode}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Identite',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.label_outline),
                  labelText: 'Nom dans le garage',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.factory_outlined),
                  labelText: 'Marque',
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.directions_car_outlined),
                  labelText: 'Modele',
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        labelText: 'Annee',
                      ),
                      validator: _yearValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _fuel,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.local_gas_station_outlined),
                        labelText: 'Energie',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Essence',
                          child: Text('Essence'),
                        ),
                        DropdownMenuItem(
                          value: 'Diesel',
                          child: Text('Diesel'),
                        ),
                        DropdownMenuItem(
                          value: 'Hybride',
                          child: Text('Hybride'),
                        ),
                        DropdownMenuItem(
                          value: 'Electrique',
                          child: Text('Electrique'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _fuel = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _engineController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.build_outlined),
                  labelText: 'Motorisation',
                ),
                validator: _required,
              ),
              const SizedBox(height: 20),
              Text(
                'Kilometrage',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.speed),
                  labelText: 'Kilometrage actuel',
                  suffixText: 'km',
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _monthlyMileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.trending_up),
                  labelText: 'Kilometrage moyen mensuel',
                  suffixText: 'km/mois',
                ),
                validator: _positiveNumber,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Ajouter au garage'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyTemplate(VehicleTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _brandController.text = template.brand;
      _modelController.text = template.model;
      _engineController.text = template.engine;
      _yearController.text = template.yearTo.toString();
      _fuel = template.fuel;
      if (_nicknameController.text.trim().isEmpty) {
        _nicknameController.text = template.model;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    GarageScope.of(context).addVehicle(
      nickname: _nicknameController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      fuel: _fuel,
      engine: _engineController.text.trim(),
      mileage: int.parse(_mileageController.text.trim()),
      monthlyMileageEstimate: int.parse(_monthlyMileageController.text.trim()),
      referenceCode: _selectedTemplate?.referenceCode,
      rules: _selectedTemplate?.rules,
    );

    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Champ requis';
    }
    return null;
  }

  String? _positiveNumber(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 0) {
      return 'Nombre attendu';
    }
    return null;
  }

  String? _yearValidator(String? value) {
    final year = int.tryParse(value?.trim() ?? '');
    if (year == null || year < 1950 || year > DateTime.now().year + 1) {
      return 'Annee invalide';
    }
    return null;
  }
}
