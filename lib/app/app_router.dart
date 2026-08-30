import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';
import '../features/automations/presentation/pages/automations_page.dart';
import '../features/automations/presentation/pages/automation_details_page.dart';
import '../features/workflow_builder/presentation/pages/create_automation_page.dart';
import '../features/workflow_builder/presentation/pages/workflow_preview_page.dart';
import '../features/executions/presentation/pages/execution_details_page.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.createAutomation,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateAutomationPage(),
    ),
    GoRoute(
      path: AppRoutes.workflowDetails,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WorkflowPreviewPage(),
    ),
    GoRoute(
      path: AppRoutes.automationDetails,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AutomationDetailsPage(id: id);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Dashboard')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.automations,
              builder: (context, state) => const AutomationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.executions,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Executions')),
              ),
            ),
            GoRoute(
              path: AppRoutes.executionDetails,
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return ExecutionDetailsPage(id: id);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.templates,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Templates')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.integrations,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Integrations')),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Settings')),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
