import 'package:go_router/go_router.dart';

import 'models/booking.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/booking/booking_success_screen.dart';
import 'screens/bookings/booking_detail_screen.dart';
import 'screens/home/home_shell.dart';
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
    GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    GoRoute(path: '/promotions', builder: (context, state) => const PromotionsScreen()),
    GoRoute(
      path: '/venues/:id',
      builder: (context, state) => VenueDetailScreen(venueId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/venues/:id/book',
      builder: (context, state) => BookingScreen(venueId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/booking-success',
      builder: (context, state) => BookingSuccessScreen(booking: state.extra as Booking),
    ),
    GoRoute(
      path: '/bookings/:id',
      builder: (context, state) => BookingDetailScreen(bookingId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
