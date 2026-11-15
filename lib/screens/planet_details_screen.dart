import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/planet.dart';
import '../widgets/space_widgets.dart';

class PlanetDetailsScreen extends StatefulWidget {
  const PlanetDetailsScreen({required this.planet, super.key});

  final Planet planet;

  @override
  State<PlanetDetailsScreen> createState() => _PlanetDetailsScreenState();
}

class _PlanetDetailsScreenState extends State<PlanetDetailsScreen> {
  bool _showModel = false;

  @override
  Widget build(BuildContext context) {
    final planet = widget.planet;
    return Scaffold(
      appBar: AppBar(title: Text(planet.name)),
      body: SpaceBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text(
              planet.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.image_outlined),
                    label: Text('Image'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.view_in_ar_outlined),
                    label: Text('3D model'),
                  ),
                ],
                selected: {_showModel},
                onSelectionChanged: (value) =>
                    setState(() => _showModel = value.single),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 330,
              child: _showModel
                  ? _PlanetModel(planet: planet)
                  : Hero(
                      tag: '${planet.name}-image',
                      child: PlanetImage(path: planet.image, name: planet.name),
                    ),
            ),
            const SizedBox(height: 16),
            Text('About', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(planet.about, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 28),
            for (final fact in planet.facts) _FactRow(fact: fact),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final PlanetFact fact;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFF282828))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fact.label, style: const TextStyle(color: Color(0xFFABABAB))),
        const SizedBox(height: 5),
        Text(
          fact.value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _PlanetModel extends StatelessWidget {
  const _PlanetModel({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) => ModelViewer(
    key: ValueKey(planet.model),
    src: kIsWeb ? 'assets/${planet.model}' : planet.model,
    alt: 'Interactive 3D model of ${planet.name}',
    ar: false,
    cameraControls: true,
    disablePan: true,
    touchAction: TouchAction.panY,
    autoRotate: !MediaQuery.disableAnimationsOf(context),
    autoRotateDelay: 0,
    interactionPrompt: InteractionPrompt.none,
    loading: Loading.eager,
    debugLogging: false,
    backgroundColor: spaceBackground,
    relatedCss: '''
      .model-error { padding: 24px; color: #fff; font: 16px sans-serif;
        background: #0b0b0b; text-align: center; }
    ''',
    innerModelViewerHtml: '''
      <div id="model-error" class="model-error" slot="poster" role="status" hidden>
        3D preview is unavailable on this device. Select Image to continue.
      </div>
    ''',
    relatedJs: '''
      const viewer = document.querySelector('model-viewer');
      const message = document.getElementById('model-error');
      viewer.addEventListener('error', () => { message.hidden = false; });
      viewer.addEventListener('load', () => { message.hidden = true; });
    ''',
  );
}
