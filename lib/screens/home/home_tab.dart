import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/theme.dart';
import '../../models/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/state_views.dart';
import '../../widgets/venue_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _repository = VenueRepository();
  final _searchController = TextEditingController();

  late Future<List<Venue>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.browse();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() => _future = _repository.browse(search: _searchController.text.trim()));
  }

  Future<void> _refresh() async {
    setState(() => _future = _repository.browse(search: _searchController.text.trim()));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cari venue billiard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 4),
                const Text('Temukan tempat main terdekat dari kamu', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.text),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama venue atau kota...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textFaint),
                    suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
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
                    return ListView(children: [ErrorView(message: message, onRetry: _search)]);
                  }

                  final venues = snapshot.data ?? [];
                  if (venues.isEmpty) {
                    return ListView(
                      children: const [EmptyView(message: 'Tidak ada venue ditemukan.', icon: Icons.search_off)],
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: venues.length,
                    itemBuilder: (context, index) {
                      final venue = venues[index];
                      return VenueCard(venue: venue, onTap: () => context.push('/venues/${venue.id}'));
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
