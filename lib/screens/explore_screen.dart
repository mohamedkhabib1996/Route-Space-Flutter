import 'package:material_ui/material_ui.dart';

import '../models/planet.dart';
import '../widgets/space_widgets.dart';
import 'planet_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({required this.planets, super.key});

  final List<Planet> planets;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late int _index;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final earth = widget.planets.indexWhere((planet) => planet.name == 'Earth');
    _index = earth < 0 ? 0 : earth;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final next = (_index + delta) % widget.planets.length;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(next);
    } else {
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final planet = widget.planets[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: SpaceBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Which planet would you\nlike to explore?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.planets.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final item = widget.planets[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Hero(
                      tag: '${item.name}-image',
                      child: PlanetImage(path: item.image, name: item.name),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () => _move(-1),
                    tooltip: 'Previous planet',
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        planet.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _move(1),
                    tooltip: 'Next planet',
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ExploreButton(
                label: 'Explore ${planet.name}',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlanetDetailsScreen(planet: planet),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
