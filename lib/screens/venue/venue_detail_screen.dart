import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_exception.dart';
import '../../core/facilities.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/review.dart';
import '../../models/venue.dart';
import '../../repositories/review_repository.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/eight_ball_icon.dart';
import '../../widgets/state_views.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final int venueId;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final _repository = VenueRepository();
  late Future<Venue> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.show(widget.venueId);
  }

  Future<void> _toggleFavorite(Venue venue) async {
    setState(() => venue.isFavorited = !venue.isFavorited);
    try {
      if (venue.isFavorited) {
        await _repository.addFavorite(venue.id);
      } else {
        await _repository.removeFavorite(venue.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => venue.isFavorited = !venue.isFavorited);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<Venue>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            final message =
                snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Gagal memuat venue.';
            return ErrorView(
              message: message,
              onRetry: () => setState(() {
                _future = _repository.show(widget.venueId);
              }),
            );
          }

          final venue = snapshot.data!;

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverToBoxAdapter(child: _CoverHeader(venue: venue, onFavoriteToggle: () => _toggleFavorite(venue))),
                      SliverToBoxAdapter(child: _VenueInfo(venue: venue)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(
                          const TabBar(
                            isScrollable: true,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textFaint,
                            indicatorColor: AppColors.primary,
                            tabAlignment: TabAlignment.start,
                            tabs: [
                              Tab(text: 'Tentang'),
                              Tab(text: 'Fasilitas'),
                              Tab(text: 'Ulasan'),
                              Tab(text: 'Lokasi'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        _TentangTab(venue: venue),
                        _FasilitasTab(venue: venue),
                        _UlasanTab(venueId: venue.id),
                        _LokasiTab(venue: venue),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/venues/${venue.id}/book'),
                        child: const Text('Pilih Meja'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  const _CoverHeader({required this.venue, required this.onFavoriteToggle});

  final Venue venue;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          venue.photoUrl != null
              ? Image.network(
                  venue.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const _CoverFallback(),
                )
              : const _CoverFallback(),
          Positioned(
            top: topPadding + 12,
            left: 16,
            child: _CircleButton(icon: Icons.arrow_back, onTap: () => context.pop()),
          ),
          Positioned(
            top: topPadding + 12,
            right: 16,
            child: Row(
              children: [
                _CircleButton(
                  icon: venue.isFavorited ? Icons.favorite : Icons.favorite_border,
                  iconColor: venue.isFavorited ? AppColors.danger : Colors.white,
                  onTap: onFavoriteToggle,
                ),
                const SizedBox(width: 10),
                _CircleButton(
                  icon: Icons.share_outlined,
                  onTap: () => Share.share('${venue.name} - ${venue.address ?? venue.city ?? ''}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

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
      child: const EightBallIcon(size: 72),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.iconColor = Colors.white});

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}

class _VenueInfo extends StatelessWidget {
  const _VenueInfo({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(venue.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 6),
          Row(
            children: [
              if (venue.rating != null) ...[
                const Icon(Icons.star_rounded, size: 17, color: AppColors.warning),
                const SizedBox(width: 3),
                Text(
                  venue.rating!.toStringAsFixed(1),
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(' (${venue.reviewsCount} ulasan)', style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
              ] else
                const Text('Belum ada rating', style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
              if (venue.distanceKm != null) ...[
                const Text(' · ', style: TextStyle(color: AppColors.textFaint)),
                const Icon(Icons.location_on, size: 13, color: AppColors.textFaint),
                Text(' ${venue.distanceKm!.toStringAsFixed(1)} km', style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(venue.address ?? venue.city ?? '-', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          if (venue.priceFrom != null) ...[
            const SizedBox(height: 8),
            Text(
              '${formatCurrency(venue.priceFrom!)} / jam',
              style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: AppColors.bg, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _TentangTab extends StatelessWidget {
  const _TentangTab({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (venue.photoUrl != null) ...[
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(venue.photoUrl!, width: 120, height: 90, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          venue.description ?? 'Belum ada deskripsi untuk venue ini.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        const Text('Jam Operasional', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: AppColors.textFaint),
            const SizedBox(width: 8),
            Text(venue.hoursLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
        if (venue.phone != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textFaint),
              const SizedBox(width: 8),
              Text(venue.phone!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ],
      ],
    );
  }
}

class _FasilitasTab extends StatelessWidget {
  const _FasilitasTab({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    if (venue.facilities.isEmpty) {
      return const Center(
        child: Text('Belum ada info fasilitas.', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: venue.facilities.length,
      itemBuilder: (context, index) {
        final info = facilityInfo[venue.facilities[index]];
        if (info == null) return const SizedBox.shrink();
        return Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
              alignment: Alignment.center,
              child: Icon(info.icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              info.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}

class _UlasanTab extends StatefulWidget {
  const _UlasanTab({required this.venueId});

  final int venueId;

  @override
  State<_UlasanTab> createState() => _UlasanTabState();
}

class _UlasanTabState extends State<_UlasanTab> {
  final _repository = ReviewRepository();
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.forVenue(widget.venueId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat ulasan.', style: TextStyle(color: AppColors.danger)));
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Center(child: Text('Belum ada ulasan.', style: TextStyle(color: AppColors.textMuted)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(height: 28),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.customerName ?? 'Pengguna',
                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Text(formatShortDate(review.createdAt), style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 15,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(review.comment!, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _LokasiTab extends StatelessWidget {
  const _LokasiTab({required this.venue});

  final Venue venue;

  Future<void> _openMaps() async {
    final query = venue.latitude != null && venue.longitude != null
        ? '${venue.latitude},${venue.longitude}'
        : Uri.encodeComponent(venue.address ?? venue.name);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.map_outlined, size: 40, color: AppColors.textFaint),
        ),
        const SizedBox(height: 16),
        Text(venue.address ?? '-', style: const TextStyle(color: AppColors.text, fontSize: 14)),
        const SizedBox(height: 2),
        Text(venue.city ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: venue.latitude != null || venue.address != null ? _openMaps : null,
          icon: const Icon(Icons.directions_outlined, size: 18),
          label: const Text('Buka di Google Maps'),
        ),
      ],
    );
  }
}
