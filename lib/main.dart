import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'models/planet.dart';
import 'screens/intro_screen.dart';
import 'widgets/space_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const SpaceApp());
}

class SpaceApp extends StatelessWidget {
  const SpaceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Space',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Roboto',
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: spaceRed,
        brightness: Brightness.dark,
      ).copyWith(primary: spaceRed, onPrimary: Colors.white),
      scaffoldBackgroundColor: spaceBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: spaceBackground,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: spaceRed,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55),
      ),
    ),
    home: const _SpaceLoader(),
  );
}

class _SpaceLoader extends StatefulWidget {
  const _SpaceLoader();

  @override
  State<_SpaceLoader> createState() => _SpaceLoaderState();
}

class _SpaceLoaderState extends State<_SpaceLoader> {
  late Future<List<Planet>> _planets = loadPlanets();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Planet>>(
    future: _planets,
    builder: (context, snapshot) {
      if (snapshot.hasData) return IntroScreen(planets: snapshot.data!);
      return Scaffold(
        body: Center(
          child: snapshot.hasError
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('The solar system could not be loaded.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() => _planets = loadPlanets()),
                      child: const Text('Try again'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    },
  );
}
