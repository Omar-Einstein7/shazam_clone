import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_state.dart';
import 'package:flutter_complete_project/src/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_complete_project/src/features/home/presentation/screens/song_details_screen.dart';
import 'package:flutter_complete_project/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_complete_project/src/imports/core_imports.dart';
import 'package:go_router/go_router.dart';

// import 'package:flutter_complete_project/src/features/auth/presentation/screens/login_screen.dart';
// import 'package:flutter_complete_project/src/features/auth/presentation/screens/signup_screen.dart';
// import 'package:flutter_complete_project/src/features/auth/presentation/screens/forgot_password_screen.dart';
// import 'package:flutter_complete_project/src/features/home/presentation/screens/home_page.dart';
// import 'package:flutter_complete_project/src/features/onboarding/presentation/screens/onboarding_page.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  // redirect: (context, state) {
  //   if (state.uri.path == '/') return AppRoutes.onboarding;
  //   return null;
  // },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(key: state.pageKey, child: const SplashScreen()),
    ),
    // GoRoute(
    //   path: AppRoutes.login,
    //   name: 'login',
    //   builder: (context, state) => const LoginScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.signup,
    //   name: 'signup',
    //   builder: (context, state) => const SignupScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.forgotPassword,
    //   name: 'forgotPassword',
    //   builder: (context, state) => const ForgotPasswordScreen(),
    // ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(key: state.pageKey, child: const HomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.songDetails,
      name: 'songDetails',
      builder: (context, state) =>
          SongDetailsScreen(result: state.extra! as ShazamResult),
    ),
  ],
);

CustomTransitionPage<void> _fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Keep outgoing page opaque to prevent dark flashes during crossfade.
      final isPopping = animation.status == AnimationStatus.reverse;

      return FadeTransition(
        opacity: isPopping
            ? const AlwaysStoppedAnimation(1.0)
            : CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
