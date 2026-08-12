/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.onboarding)` instead of `context.go('/')`.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String songDetails = '/song-details';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
}

/// Shared Hero tags so the splash orb can morph into the same-shaped buttons.
abstract final class AppHeroes {
  AppHeroes._();

  /// The white neumorphic disc on Splash → the listening button on Home.
  static const String listenerOrb = 'listenerOrb';
}
