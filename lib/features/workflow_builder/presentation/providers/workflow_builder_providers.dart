import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../automations/domain/models/models.dart';
import '../../../automations/presentation/providers/automation_providers.dart';
import '../../data/repositories/mock_workflow_repository.dart';
import '../../data/services/mock_workflow_planner.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/workflow_repository.dart';
import '../../domain/services/workflow_planner.dart';

final workflowPlannerProvider = Provider<WorkflowPlanner>((ref) {
  return MockWorkflowPlanner();
});

final workflowRepositoryProvider = Provider<WorkflowRepository>((ref) {
  return MockWorkflowRepository();
});

class WorkflowGenerationState {
  final bool isLoading;
  final bool isSaving;
  final Workflow? workflow;
  final Automation? savedAutomation;
  final String? originalPrompt;
  final String? error;

  const WorkflowGenerationState({
    this.isLoading = false,
    this.isSaving = false,
    this.workflow,
    this.savedAutomation,
    this.originalPrompt,
    this.error,
  });

  WorkflowGenerationState copyWith({
    bool? isLoading,
    bool? isSaving,
    Workflow? workflow,
    Automation? savedAutomation,
    String? originalPrompt,
    String? error,
  }) {
    return WorkflowGenerationState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      workflow: workflow ?? this.workflow,
      savedAutomation: savedAutomation ?? this.savedAutomation,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      error: error ?? this.error,
    );
  }
}

class WorkflowGenerationNotifier extends StateNotifier<WorkflowGenerationState> {
  final WorkflowPlanner _planner;
  final WorkflowRepository _workflowRepository;
  final Ref _ref;

  WorkflowGenerationNotifier(this._planner, this._workflowRepository, this._ref)
      : super(const WorkflowGenerationState());

  Future<void> generateWorkflow(String prompt) async {
    state = state.copyWith(isLoading: true, error: null, originalPrompt: prompt);
    try {
      final workflow = await _planner.generateWorkflow(prompt);
      state = state.copyWith(isLoading: false, workflow: workflow);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void generateFromTemplate(Workflow workflow, String prompt) {
    state = state.copyWith(
      workflow: workflow,
      originalPrompt: prompt,
      isLoading: false,
      error: null,
    );
  }

  Future<void> approveWorkflow() async {
    final workflow = state.workflow;
    if (workflow == null) return;

    state = state.copyWith(isSaving: true, error: null);
    try {
      // 1. Save workflow
      await _workflowRepository.saveWorkflow(workflow);

      // 2. Create Automation
      final automation = Automation(
        id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
        name: workflow.name,
        description: workflow.description,
        status: AutomationStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        workflowId: workflow.id,
      );

      final autoRepo = _ref.read(automationRepositoryProvider);
      await autoRepo.createAutomation(automation);

      // Invalidate automations list to trigger refresh
      _ref.invalidate(automationsListProvider);

      state = state.copyWith(isSaving: false, savedAutomation: automation);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void reset() {
    state = const WorkflowGenerationState();
  }
}

final workflowGenerationProvider =
    StateNotifierProvider<WorkflowGenerationNotifier, WorkflowGenerationState>((ref) {
  final planner = ref.watch(workflowPlannerProvider);
  final repo = ref.watch(workflowRepositoryProvider);
  return WorkflowGenerationNotifier(planner, repo, ref);
});
