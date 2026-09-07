import 'package:flutter/material.dart';

import '../bookings/my_bookings_tab.dart';
import '../explore/explore_tab.dart';
import '../favorites/favorites_tab.dart';
import '../profile/profile_tab.dart';
import 'home_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _exploreKey = GlobalKey<ExploreTabState>();
  final _bookingsKey = GlobalKey<MyBookingsTabState>();
  final _favoritesKey = GlobalKey<FavoritesTabState>();

  void _goToExplore(ExploreQuickFilter filter) {
    _exploreKey.currentState?.applyFilter(filter);
    setState(() => _index = 1);
  }

  late final _tabs = [
    HomeTab(onQuickFilter: _goToExplore),
    ExploreTab(key: _exploreKey),
    MyBookingsTab(key: _bookingsKey),
    FavoritesTab(key: _favoritesKey),
    const ProfileTab(),
  ];

  void _onTabTap(int value) {
    setState(() => _index = value);
    if (value == 2) _bookingsKey.currentState?.reload();
    if (value == 3) _favoritesKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTabTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Jelajah'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
