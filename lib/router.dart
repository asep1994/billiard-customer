import 'package:go_router/go_router.dart';

import 'models/billiard_table.dart';
import 'models/venue.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/booking/pilih_meja_screen.dart';
import 'screens/booking/pilih_tanggal_jam_screen.dart';
import 'screens/booking/ringkasan_booking_screen.dart';
import 'screens/bookings/booking_detail_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/promotions/promotions_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/venue/venue_detail_screen.dart';

/// Navigation is driven imperatively (each screen calls context.go(...) once
/// it knows where to send the user next - e.g. splash after bootstrap, login
/// after a successful sign-in) rather than through go_router's redirect
/// hooks, which keeps the auth-state-to-route mapping in one obvious place
/// per screen instead of a central redirect function every route has to
/// satisfy.
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordScreen(phone: state.extra as String),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    GoRoute(path: '/promotions', builder: (context, state) => const PromotionsScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    GoRoute(
      path: '/venues/:id',
      builder: (context, state) => VenueDetailScreen(venueId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/venues/:id/book',
      builder: (context, state) => PilihMejaScreen(venueId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/venues/:id/book/schedule',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return PilihTanggalJamScreen(
          venue: extra['venue'] as Venue,
          table: extra['table'] as BilliardTable,
          date: extra['date'] as DateTime,
        );
      },
    ),
    GoRoute(
      path: '/venues/:id/book/summary',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RingkasanBookingScreen(
          venue: extra['venue'] as Venue,
          table: extra['table'] as BilliardTable,
          date: extra['date'] as DateTime,
          startHour: extra['startHour'] as int,
          duration: extra['duration'] as int,
          price: extra['price'] as double,
        );
      },
    ),
    GoRoute(
      path: '/bookings/:id',
      builder: (context, state) => BookingDetailScreen(bookingId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
