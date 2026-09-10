import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/location_service.dart';
import '../../core/theme.dart';
import '../../models/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/state_views.dart';
import '../../widgets/venue_card.dart';

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

  @override
  void initState() {
    super.initState();
    _future = _load();
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
                    children: const [
                      EmptyView(
                        message: 'Tidak ada venue ditemukan.',
                        icon: Icons.search_off,
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: venues.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final venue = venues[index];
                    return VenueCard(
                      venue: venue,
                      onTap: () => context.push('/venues/${venue.id}'),
                      onFavoriteToggle: () => _toggleFavorite(venue),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
