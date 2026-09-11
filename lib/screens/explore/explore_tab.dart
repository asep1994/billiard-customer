import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/location_service.dart';
import '../../core/theme.dart';
import '../../models/nearby_place.dart';
import '../../models/venue.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/nearby_place_repository.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/state_views.dart';
import '../../widgets/venue_card.dart';
import '../../widgets/venue_placeholder_image.dart';

enum ExploreQuickFilter { none, nearest, topRated, openNow }

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => ExploreTabState();
}

class ExploreTabState extends State<ExploreTab> {
  final _repository = VenueRepository();
  final _locationService = LocationService();
  final _searchController = TextEditingController();

  double? _lat;
  double? _lng;
  ExploreQuickFilter _filter = ExploreQuickFilter.none;
  late Future<List<Venue>> _future;
  late Future<List<NearbyPlace>> _nearbyPlacesFuture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _nearbyPlacesFuture = _loadNearbyPlaces();
  }

  /// Billiard venues found via Google Places that aren't partnered with
  /// Unity Billiard yet - feeds the "Ajak Gabung" lead-gen section below the
  /// main venue list. Silently empty when location isn't available, since
  /// this section is a nice-to-have, not core to browsing.
  Future<List<NearbyPlace>> _loadNearbyPlaces() async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) return [];

    try {
      return await NearbyPlaceRepository().nearby(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Called from Beranda's quick-action tiles via a GlobalKey - applies a
  /// filter and reloads without losing the tab's place in the nav stack.
  void applyFilter(ExploreQuickFilter filter) {
    setState(() {
      _filter = filter;
      _future = _load();
    });
  }

  Future<List<Venue>> _load() async {
    final search = _searchController.text.trim();

    if (_filter == ExploreQuickFilter.nearest) {
      final position = await _locationService.getCurrentPosition();
      _lat = position?.latitude;
      _lng = position?.longitude;
    }

    return _repository.browse(
      search: search,
      lat: _lat,
      lng: _lng,
      sort: _filter == ExploreQuickFilter.topRated ? 'rating' : null,
      openNow: _filter == ExploreQuickFilter.openNow,
    );
  }

  void _reload() => setState(() {
    _future = _load();
  });

  String? get _filterLabel {
    switch (_filter) {
      case ExploreQuickFilter.nearest:
        return 'Venue terdekat';
      case ExploreQuickFilter.topRated:
        return 'Rating tertinggi';
      case ExploreQuickFilter.openNow:
        return 'Buka sekarang';
      case ExploreQuickFilter.none:
        return null;
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.bg],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jelajah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.text),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama venue atau kota...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textFaint,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _reload,
                    ),
                  ),
                ),
                if (_filterLabel != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(_filterLabel!),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      onDeleted: () => applyFilter(ExploreQuickFilter.none),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: FutureBuilder<List<Venue>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Gagal memuat venue.';
                  return ListView(
                    children: [ErrorView(message: message, onRetry: _reload)],
                  );
                }

                final venues = snapshot.data ?? [];
                if (venues.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    children: [
                      const EmptyView(
                        message: 'Tidak ada venue ditemukan.',
                        icon: Icons.search_off,
                      ),
                      _NearbyPlacesSection(future: _nearbyPlacesFuture),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    for (final venue in venues) ...[
                      VenueCard(
                        venue: venue,
                        onTap: () => context.push('/venues/${venue.id}'),
                        onFavoriteToggle: () => _toggleFavorite(venue),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _NearbyPlacesSection(future: _nearbyPlacesFuture),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// "Found nearby, not on Unity yet" - billiard venues sourced from Google
/// Places that haven't signed up as a partner, each with an "Ajak Gabung"
/// button that submits a lead for the business-dev team to follow up on.
/// Renders nothing while loading, on error, or when there's nothing to show,
/// so it never distracts from the main (bookable) venue list above it.
class _NearbyPlacesSection extends StatefulWidget {
  const _NearbyPlacesSection({required this.future});

  final Future<List<NearbyPlace>> future;

  @override
  State<_NearbyPlacesSection> createState() => _NearbyPlacesSectionState();
}

class _NearbyPlacesSectionState extends State<_NearbyPlacesSection> {
  final _repository = NearbyPlaceRepository();
  final _submittedIds = <String>{};

  Future<void> _ajakGabung(NearbyPlace place) async {
    final customer = context.read<AuthProvider>().customer;
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Masuk dulu buat ajak venue ini gabung ya.'),
          action: SnackBarAction(
            label: 'Masuk',
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      return;
    }

    try {
      await _repository.submitLead(place);
      if (!mounted) return;
      setState(() => _submittedIds.add(place.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Makasih! Tim kami bakal hubungi venue ini.'),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NearbyPlace>>(
      future: widget.future,
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];
        if (snapshot.connectionState != ConnectionState.done ||
            places.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ditemukan di sekitar, belum gabung Unity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kenal salah satu tempat ini? Ajak gabung jadi mitra!',
                style: TextStyle(color: AppColors.textFaint, fontSize: 12),
              ),
              const SizedBox(height: 12),
              for (final place in places) ...[
                _NearbyPlaceCard(
                  place: place,
                  isSubmitted: _submittedIds.contains(place.id),
                  onAjakGabung: () => _ajakGabung(place),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NearbyPlaceCard extends StatelessWidget {
  const _NearbyPlaceCard({
    required this.place,
    required this.isSubmitted,
    required this.onAjakGabung,
  });

  final NearbyPlace place;
  final bool isSubmitted;
  final VoidCallback onAjakGabung;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: VenuePlaceholderImage(seed: place.name),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (place.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    place.address!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (place.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${place.rating} (${place.ratingCount ?? 0})',
                        style: const TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isSubmitted ? null : onAjakGabung,
                    icon: Icon(
                      isSubmitted
                          ? Icons.check_circle_outline
                          : Icons.campaign_outlined,
                      size: 16,
                    ),
                    label: Text(isSubmitted ? 'Sudah Diajak' : 'Ajak Gabung'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isSubmitted
                          ? AppColors.textFaint
                          : AppColors.primary,
                      side: BorderSide(
                        color: isSubmitted
                            ? AppColors.border
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
