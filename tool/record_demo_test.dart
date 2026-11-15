import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:space_app/main.dart';
import 'package:space_app/models/planet.dart';

const _framesPerSecond = 12;
const _frameStep = Duration(microseconds: 83333);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final roboto = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium', 'Bold', 'Black']) {
      roboto.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
    }
    await roboto.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets('record the Space 2D user journey from the Flutter engine', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();
    final recording = _EngineRecording(tester, boundaryKey);

    await tester.runAsync(() async {
      await recording.directory.create(recursive: true);
      await tester.pumpWidget(
        RepaintBoundary(key: boundaryKey, child: const SpaceApp()),
      );
      for (final planet in await loadPlanets()) {
        await precacheImage(
          ResizeImage(AssetImage(planet.image), width: 1200),
          boundaryKey.currentContext!,
        );
      }
    });
    await tester.pumpAndSettle();

    recording.mark('Introduction');
    await recording.frames(36);
    await tester.tap(find.text('Explore'));
    recording.mark('Open solar-system carousel');
    await recording.frames(48);
    expect(find.text('Explore Earth'), findsOneWidget);

    await tester.tap(find.text('Explore Earth'));
    recording.mark('Earth details - original local image');
    await recording.frames(60);
    expect(find.text('Earth: Our Blue Marble'), findsOneWidget);
    recording.mark('Scroll Earth facts');
    await recording.swipe(const Offset(194, 710), const Offset(0, -565), 15);
    await recording.frames(57);

    await tester.pageBack();
    recording.mark('Return to Earth selection');
    await recording.frames(36);
    expect(find.text('Explore Earth'), findsOneWidget);
    await tester.tap(find.byTooltip('Next planet'));
    recording.mark('Next planet - Mars');
    await recording.frames(48);
    expect(find.text('Explore Mars'), findsOneWidget);

    await tester.tap(find.text('Explore Mars'));
    recording.mark('Mars details');
    await recording.frames(60);
    expect(find.text('Mars: The Red Planet'), findsOneWidget);
    recording.mark('Scroll Mars facts');
    await recording.swipe(const Offset(194, 710), const Offset(0, -565), 15);
    await recording.frames(57);

    await tester.pageBack();
    recording.mark('Return to carousel');
    await recording.frames(24);
    await tester.tap(find.byTooltip('Next planet'));
    recording.mark('Next planet - Jupiter');
    await recording.frames(84);
    expect(find.text('Explore Jupiter'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await recording.finish();
  }, timeout: const Timeout(Duration(minutes: 15)));
}

class _EngineRecording {
  _EngineRecording(this.tester, this.boundaryKey);

  final WidgetTester tester;
  final GlobalKey boundaryKey;
  final Directory directory = Directory('tmp/demo_frames');
  final List<Map<String, Object>> events = [];
  int frameCount = 0;

  void mark(String action) {
    events.add({'seconds': frameCount / _framesPerSecond, 'action': action});
    stdout.writeln('Recording: $action (${frameCount / _framesPerSecond}s)');
  }

  Future<void> frames(int count) async {
    for (var frame = 0; frame < count; frame++) {
      await tester.pump(_frameStep);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final index = frameCount.toString().padLeft(5, '0');
        await File('${directory.path}/frame_$index.png')
            .writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
      frameCount++;
    }
  }

  Future<void> swipe(Offset start, Offset delta, int count) async {
    final gesture = await tester.startGesture(start);
    for (var index = 1; index <= count; index++) {
      await gesture.moveTo(
        start + delta * (index / count),
        timeStamp: _frameStep * index,
      );
      await frames(1);
    }
    await gesture.up(timeStamp: _frameStep * (count + 1));
  }

  Future<void> finish() async {
    final evidence = {
      'capture': 'Actual Flutter engine frames during an automated widget test',
      'fps': _framesPerSecond,
      'frames': frameCount,
      'duration_seconds': frameCount / _framesPerSecond,
      'width': 786,
      'height': 1704,
      'three_dimensional_rendering_tested': false,
      'events': events,
    };
    await tester.runAsync(() async {
      await File('tmp/demo_recording.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(evidence));
    });
    stdout.writeln('Captured $frameCount real Flutter frames.');
  }
}
