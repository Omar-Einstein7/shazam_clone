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
      builder: (context, state) => const SplashScreen(),
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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.songDetails,
      name: 'songDetails',
      builder: (context, state) => SongDetailsScreen(
        result: state.extra! as ShazamResult,
      ),
    ),
  ],
);
