import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Home (/)'),
        ),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Dashboard'),
        ),
      ),
    ),
  ],
);
