import 'package:flutter_test/flutter_test.dart';

import 'package:ablette/app.dart';

void main() {
  testWidgets('shows the garage home', (WidgetTester tester) async {
    await tester.pumpWidget(const AbletteApp());

    expect(find.text('Ablette'), findsOneWidget);
    expect(find.text('Garage'), findsWidgets);
    expect(find.text('Clio de papa'), findsOneWidget);
  });

  testWidgets('opens add vehicle page', (WidgetTester tester) async {
    await tester.pumpWidget(const AbletteApp());

    await tester.tap(find.byTooltip('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter un vehicule'), findsOneWidget);
    expect(find.text('Recherche marque, modele, moteur'), findsOneWidget);
  });
}
