import 'package:flutter/material.dart';
import 'package:relay/core/theme/theme.dart';
import 'app_router.dart';

class RelayApp extends StatelessWidget {
  const RelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Relay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
