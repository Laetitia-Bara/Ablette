import 'package:flutter/material.dart';

import 'features/garage/pages/garage_page.dart';
import 'features/garage/services/garage_store.dart';

class AbletteApp extends StatefulWidget {
  const AbletteApp({super.key});

  @override
  State<AbletteApp> createState() => _AbletteAppState();
}

class _AbletteAppState extends State<AbletteApp> {
  late final GarageStore _garageStore;

  @override
  void initState() {
    super.initState();
    _garageStore = GarageStore.seeded();
  }

  @override
  void dispose() {
    _garageStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F6F5E);

    return GarageScope(
      store: _garageStore,
      child: MaterialApp(
        title: 'Ablette',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
            surface: const Color(0xFFF8F6F0),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F6F0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8F6F0),
            foregroundColor: Color(0xFF18211D),
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE4DED1)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        home: const GaragePage(),
      ),
    );
  }
}

class GarageScope extends InheritedNotifier<GarageStore> {
  const GarageScope({
    required GarageStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static GarageStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GarageScope>();
    assert(scope != null, 'GarageScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
