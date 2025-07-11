import 'package:assistrend/features/home/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'assistrend_opening.dart';
import 'assistrend_forgotpass.dart';
import 'features/auth/presentation/assistrend_login.dart';
import 'features/auth/presentation/assistrend_signup.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/profile/models/profile_model.dart';
import 'features/profile/presentation/profile.dart';
import 'features/profile/presentation/more_post.dart';
import 'features/profile/presentation/edit_profile.dart';
import 'features/upload/presentation/upload.dart';
import 'features/search/presentation/search_page.dart';
import 'features/home/presentation/comments_test_page.dart';
import 'debug_logout.dart';
import 'simple_logout_test.dart';

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
        builder: (context, state) => const AssistrendForgotpass(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPScreen(email: email);
        },
      ),
      
      // Profile completion screen (shown after login if profile is incomplete)

      
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
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/upload',
            name: 'upload',
            builder: (context, state) => const UploadPage(),
          ),
        ],
      ),
      
      // Routes without bottom navigation
      GoRoute(
        path: '/comments-test',
        name: 'commentsTest',
        builder: (context, state) => const CommentsTestPage(),
      ),
      GoRoute(
        path: '/debug-logout',
        name: 'debugLogout',
        builder: (context, state) => const DebugLogout(),
      ),
      GoRoute(
        path: '/simple-logout-test',
        name: 'simpleLogoutTest',
        builder: (context, state) => const SimpleLogoutTest(),
      ),
      GoRoute(
        path: '/more-posts',
        name: 'morePosts',
        builder: (context, state) => const SeeMorePostsPage(),
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
      final token = prefs.getString('access_token');
      final userId = prefs.getInt('user_id');
      final isLoggedIn = token != null && userId != null;
      
      final currentPath = state.matchedLocation;
      final isOnAuthPage = currentPath == '/login' || 
                          currentPath == '/signup' || 
                          currentPath == '/forgot-password' ||
                          currentPath == '/otp-verification';
      final isOnOpeningPage = currentPath == '/';
      
      // Debug logging
      print('Router redirect - Path: $currentPath, IsLoggedIn: $isLoggedIn');
      
      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !isOnAuthPage && !isOnOpeningPage) {
        print('Redirecting to login from: $currentPath');
        return '/login';
      }
      
      // If logged in and trying to access auth pages
      if (isLoggedIn && isOnAuthPage) {
        print('Redirecting to home from: $currentPath');
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