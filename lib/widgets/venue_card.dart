import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/venue.dart';
import 'eight_ball_icon.dart';

/// Horizontal venue list item: photo, rating, distance, address and price -
/// used for the "Rekomendasi untuk kamu" list, Jelajah results and Favorit.
class VenueCard extends StatelessWidget {
  const VenueCard({super.key, required this.venue, required this.onTap, this.onFavoriteToggle});

  final Venue venue;
  final VoidCallback onTap;

  /// Null hides the heart button entirely (e.g. inside a context where
  /// toggling doesn't make sense).
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 90,
                height: 90,
                child: venue.photoUrl != null
                    ? Image.network(
                        venue.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const _PhotoFallback(loading: true);
                        },
                      )
                    : const _PhotoFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        InkWell(
                          onTap: onFavoriteToggle,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              venue.isFavorited ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: venue.isFavorited ? AppColors.danger : AppColors.textFaint,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (venue.rating != null) ...[
                        const Icon(Icons.star_rounded, size: 15, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          venue.rating!.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(' (${venue.reviewsCount})', style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
                      ] else
                        const Text('Belum ada rating', style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
                      if (venue.distanceKm != null) ...[
                        const Text(' · ', style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
                        Icon(Icons.location_on, size: 13, color: AppColors.textFaint),
                        Text(
                          ' ${venue.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue.address ?? venue.city ?? '-',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (venue.priceFrom != null)
                    Text(
                      '${formatCurrency(venue.priceFrom!)} / jam',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primarySoft, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          : const EightBallIcon(size: 36),
    );
  }
}
