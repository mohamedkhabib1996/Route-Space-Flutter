import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_app/main.dart';
import 'package:space_app/models/planet.dart';
import 'package:space_app/screens/explore_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'The catalog includes the Sun and all eight planets with local assets',
    () async {
      final planets = await loadPlanets();
      expect(planets.map((planet) => planet.name), [
        'Sun',
        'Mercury',
        'Venus',
        'Earth',
        'Mars',
        'Jupiter',
        'Saturn',
        'Uranus',
        'Neptune',
      ]);
      for (final planet in planets) {
        expect(
          (await rootBundle.load(planet.image)).lengthInBytes,
          greaterThan(0),
        );
        final glb = await rootBundle.load(planet.model);
        expect(utf8.decode(glb.buffer.asUint8List(0, 4)), 'glTF');
        expect(planet.facts.length, 7);
      }
      expect(planets[1].about, contains('Mercury'));
      expect(planets[1].about, isNot(planets.first.about));
      expect(planets[5].facts.last.value, contains('10^10'));
    },
  );

  testWidgets('Explore, change planet, open details, and return to selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await tester.pumpWidget(const SpaceApp());
      await loadPlanets();
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Earth'), findsOneWidget);

    await tester.tap(find.byTooltip('Next planet'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Mars'), findsOneWidget);
    await tester.tap(find.text('Explore Mars'));
    await tester.pumpAndSettle();
    expect(find.text('Mars: The Red Planet'), findsOneWidget);
    expect(find.text('3D model'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Explore Mars'), findsOneWidget);
  });

  testWidgets('Carousel wraps from Sun to Neptune on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final planets = (await tester.runAsync(loadPlanets))!;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ExploreScreen(planets: planets),
      ),
    );
    await tester.pumpAndSettle();
    for (var step = 0; step < 3; step++) {
      await tester.tap(find.byTooltip('Previous planet'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Explore Sun'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous planet'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Neptune'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
