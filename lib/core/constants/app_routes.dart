class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  
  static const String automations = '/automations';
  static const String createAutomation = '/automations/create';
  static const String workflowDetails = '/automations/details';
  static const String automationDetails = '/automations/:id';
  
  static const String executions = '/executions';
  static const String executionDetails = '/executions/:id';
  
  static const String templates = '/templates';
  static const String integrations = '/integrations';
  static const String settings = '/settings';
}
