import 'package:material_ui/material_ui.dart';

const spaceRed = Color(0xFFEE403D);
const spaceBackground = Color(0xFF0B0B0B);

class SpaceBody extends StatelessWidget {
  const SpaceBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: child,
      ),
    ),
  );
}

class ExploreButton extends StatelessWidget {
  const ExploreButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    ),
  );
}

class PlanetImage extends StatelessWidget {
  const PlanetImage({required this.path, required this.name, super.key});

  final String path;
  final String name;

  @override
  Widget build(BuildContext context) => Image.asset(
    path,
    fit: BoxFit.contain,
    cacheWidth: 1200,
    semanticLabel: name,
    errorBuilder: (context, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
  );
}
