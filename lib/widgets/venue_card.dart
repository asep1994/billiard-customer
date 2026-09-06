import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/venue.dart';
import 'eight_ball_icon.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({super.key, required this.venue, required this.onTap});

  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primarySoft, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: EightBallIcon(size: 48)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textFaint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.city ?? 'Lokasi tidak diketahui',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textFaint),
                      const SizedBox(width: 4),
                      Text(venue.hoursLabel, style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
                    ],
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
