import 'package:assistrend/features/home/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the ScaffoldWithBottomNav from main.dart
import 'main.dart';
// Import ProfileModel for edit profile page
import 'features/profile/models/profile_model.dart';

// Screens
import 'assistrend_opening.dart';
import 'assistrend_forgotpass.dart';
import 'features/profile/presentation/profile.dart';
import 'features/profile/presentation/more_post.dart';
import 'features/profile/presentation/edit_profile.dart';
import 'features/auth/presentation/assistrend_login.dart';
import 'features/auth/presentation/assistrend_signup.dart';
import 'features/auth/presentation/otp_screen.dart';

/// The router configuration for the app using GoRouter
class AppRouter {
  // Private constructor
  AppRouter._();

  // Create a key for the navigator
  static final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
  
  /// The go router configuration used for routing
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Opening splash screen
      GoRoute(
        path: '/',
        name: 'opening',
        builder: (context, state) => AssistrendOpening(),
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => AssistrendLogin(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => AssistrendSignUp(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => AssistrendForgotpass(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPScreen(email: email);
        },
      ),
      
      // Main app routes (protected, with bottom navigation)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => ProfilePage(),
          ),
        ],
      ),
      
      // Routes without bottom navigation
      GoRoute(
        path: '/more-posts',
        name: 'morePosts',
        builder: (context, state) => SeeMorePostsPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) {
          final profile = state.extra as ProfileModel;
          return EditProfilePage(profile: profile);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );

  /// Handles authentication redirects
  static Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
    try {
      // Get current auth status
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getString('access_token') != null;
      final isOnAuthPage = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/signup' || 
                          state.matchedLocation == '/forgot-password' ||
                          state.matchedLocation == '/otp-verification';
      final isOnOpeningPage = state.matchedLocation == '/';
      
      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !isOnAuthPage && !isOnOpeningPage) {
        return '/login';
      }
      
      // If logged in and trying to access auth pages
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }
      
      // No redirect needed
      return null;
    } catch (e) {
      print('Error in redirect: $e');
      return null;
    }
  }
}