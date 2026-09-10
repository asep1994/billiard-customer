import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../models/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/state_views.dart';
import '../../widgets/venue_card.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => FavoritesTabState();
}

class FavoritesTabState extends State<FavoritesTab> {
  final _repository = VenueRepository();
  late Future<List<Venue>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.favorites();
  }

  /// Called by HomeShell whenever this tab is selected - HomeShell's
  /// IndexedStack keeps every tab alive after its first build, so without
  /// this a favorite added/removed elsewhere would never show up here.
  void reload() => _reload();

  void _reload() => setState(() {
    _future = _repository.favorites();
  });

  Future<void> _removeFavorite(Venue venue) async {
    try {
      await _repository.removeFavorite(venue.id);
      _reload();
    } catch (_) {
      // Leave the list as-is; the user can pull to refresh or retry the tap.
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
          child: const SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Favorit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
                      : 'Gagal memuat favorit.';
                  return ListView(
                    children: [ErrorView(message: message, onRetry: _reload)],
                  );
                }

                final venues = snapshot.data ?? [];
                if (venues.isEmpty) {
                  return ListView(
                    children: const [
                      EmptyView(
                        message: 'Belum ada venue favorit.',
                        icon: Icons.favorite_border,
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
                      onFavoriteToggle: () => _removeFavorite(venue),
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
