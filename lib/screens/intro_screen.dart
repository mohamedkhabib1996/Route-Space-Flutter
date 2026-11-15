import 'package:material_ui/material_ui.dart';

import '../models/planet.dart';
import '../widgets/space_widgets.dart';
import 'explore_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({required this.planets, super.key});

  final List<Planet> planets;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SpaceBody(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -constraints.maxWidth * 0.62,
              top: constraints.maxHeight * 0.08,
              width: constraints.maxWidth * 1.55,
              height: constraints.maxHeight * 0.84,
              child: const PlanetImage(
                path: 'assets/images/earth.png',
                name: 'Earth',
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x220B0B0B), Color(0xBB0B0B0B)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SPACE',
                      style: TextStyle(
                        letterSpacing: 7,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Explore\nThe\nUniverse',
                          style: TextStyle(
                            fontSize: constraints.maxHeight < 540 ? 40 : 50,
                            height: 1.13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.4,
                          ),
                        ),
                      ),
                    ),
                    ExploreButton(
                      label: 'Explore',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ExploreScreen(planets: planets),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
