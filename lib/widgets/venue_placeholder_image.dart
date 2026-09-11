import 'package:flutter/material.dart';

/// Deterministically picks one of a small set of bundled billiard-venue
/// photos as a stand-in wherever a venue or place has no real photo -
/// the same [seed] (e.g. a venue's name) always renders the same image, so
/// a given card doesn't flicker between different placeholders on rebuild.
class VenuePlaceholderImage extends StatelessWidget {
  const VenuePlaceholderImage({
    super.key,
    required this.seed,
    this.fit = BoxFit.cover,
  });

  final String seed;
  final BoxFit fit;

  static const _assetCount = 4;

  @override
  Widget build(BuildContext context) {
    final sum = seed.codeUnits.fold<int>(0, (total, unit) => total + unit);
    final index = seed.isEmpty ? 0 : sum % _assetCount;

    return Image.asset(
      'assets/images/venue_placeholders/venue_placeholder_${index + 1}.jpg',
      fit: fit,
    );
  }
}
