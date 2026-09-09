import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/location_service.dart';
import '../../core/theme.dart';
import '../../models/app_banner.dart';
import '../../models/venue.dart';
import '../../repositories/banner_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/eight_ball_icon.dart';
import '../../widgets/state_views.dart';
import '../../widgets/venue_card.dart';
import '../explore/explore_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onQuickFilter});

  /// Switches HomeShell to the Jelajah tab and applies the given filter -
  /// owned by HomeShell since it holds the GlobalKey to ExploreTab's state.
  final void Function(ExploreQuickFilter filter) onQuickFilter;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _repository = VenueRepository();
  final _locationService = LocationService();

  late Future<List<Venue>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRecommendations();
  }

  Future<List<Venue>> _loadRecommendations() async {
    final position = await _locationService.getCurrentPosition();
    final venues = await _repository.browse(lat: position?.latitude, lng: position?.longitude);
    return venues.take(6).toList();
  }

  void _reload() => setState(() {
        _future = _loadRecommendations();
      });

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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _reload();
          await _future;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            _Header(onSearchTap: () => widget.onQuickFilter(ExploreQuickFilter.none)),
            const SizedBox(height: 16),
            const _BannerCarousel(),
            const SizedBox(height: 20),
            _QuickActions(onQuickFilter: widget.onQuickFilter),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rekomendasi untuk kamu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                TextButton(
                  onPressed: () => widget.onQuickFilter(ExploreQuickFilter.none),
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Venue>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: LoadingView(),
                  );
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Gagal memuat venue.';
                  return ErrorView(message: message, onRetry: _reload);
                }

                final venues = snapshot.data ?? [];
                if (venues.isEmpty) {
                  return const EmptyView(message: 'Belum ada venue di sekitarmu.', icon: Icons.search_off);
                }

                return Column(
                  children: [
                    for (final venue in venues) ...[
                      VenueCard(
                        venue: venue,
                        onTap: () => context.push('/venues/${venue.id}'),
                        onFavoriteToggle: () => _toggleFavorite(venue),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Bandung, Jawa Barat', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textFaint),
                    ],
                  ),
                  Text('Lokasi Anda', style: TextStyle(color: AppColors.textFaint, fontSize: 11)),
                ],
              ),
            ),
            const _NotificationBell(),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onSearchTap,
          child: AbsorbPointer(
            child: TextField(
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'Cari tempat billiard...',
                prefixIcon: Icon(Icons.search, color: AppColors.textFaint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final _repository = NotificationRepository();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final page = await _repository.list();
      if (mounted) setState(() => _unreadCount = page.unreadCount);
    } catch (_) {
      // best-effort - a stale/missing badge isn't worth surfacing an error for
    }
  }

  Future<void> _open() async {
    await context.push('/notifications');
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_outlined, size: 18, color: AppColors.textMuted),
          ),
          if (_unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Auto-scrolling carousel of admin-uploaded banners, fetched from
/// `/customer/banners`. Falls back to the static [_HeroBanner] while
/// loading, on error, or when no banners have been uploaded yet, so the
/// homepage never looks empty or broken.
class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _repository = BannerRepository();
  final _pageController = PageController();

  Timer? _timer;
  int _index = 0;
  List<AppBanner> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final banners = await _repository.list();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _isLoading = false;
      });
      _startAutoScroll();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoScroll() {
    if (_banners.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      _index = (_index + 1) % _banners.length;
      _pageController.animateToPage(
        _index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _banners.isEmpty) {
      return const _HeroBanner();
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, i) {
                final banner = _banners[i];
                return banner.imageUrl != null
                    ? Image.network(
                        banner.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const _HeroBanner(),
                      )
                    : const _HeroBanner();
              },
            ),
          ),
        ),
        if (_banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 16 : 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Main Billiard Lebih\nMudah Bersama Unity',
                  style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold, height: 1.25),
                ),
                SizedBox(height: 8),
                Text('Temukan, Pesan, Main!', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const EightBallIcon(size: 64),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onQuickFilter});

  final void Function(ExploreQuickFilter filter) onQuickFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickActionButton(
          icon: Icons.location_on,
          label: 'Venue\nTerdekat',
          highlighted: true,
          onTap: () => onQuickFilter(ExploreQuickFilter.nearest),
        ),
        _QuickActionButton(
          icon: Icons.local_offer_outlined,
          label: 'Promo\nSpesial',
          onTap: () => context.push('/promotions'),
        ),
        _QuickActionButton(
          icon: Icons.star_border_rounded,
          label: 'Rating\nTertinggi',
          onTap: () => onQuickFilter(ExploreQuickFilter.topRated),
        ),
        _QuickActionButton(
          icon: Icons.access_time,
          label: 'Buka\nSekarang',
          onTap: () => onQuickFilter(ExploreQuickFilter.openNow),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.label, required this.onTap, this.highlighted = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: highlighted ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: highlighted ? null : Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: highlighted ? Colors.black : AppColors.textMuted, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
