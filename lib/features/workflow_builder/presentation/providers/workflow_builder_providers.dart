import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_workflow_planner.dart';
import '../../domain/models/models.dart';
import '../../domain/services/workflow_planner.dart';

final workflowPlannerProvider = Provider<WorkflowPlanner>((ref) {
  return MockWorkflowPlanner();
});

class WorkflowGenerationState {
  final bool isLoading;
  final Workflow? workflow;
  final String? error;

  const WorkflowGenerationState({
    this.isLoading = false,
    this.workflow,
    this.error,
  });

  WorkflowGenerationState copyWith({
    bool? isLoading,
    Workflow? workflow,
    String? error,
  }) {
    return WorkflowGenerationState(
      isLoading: isLoading ?? this.isLoading,
      workflow: workflow ?? this.workflow,
      error: error ?? this.error,
    );
  }
}

class WorkflowGenerationNotifier extends StateNotifier<WorkflowGenerationState> {
  final WorkflowPlanner _planner;

  WorkflowGenerationNotifier(this._planner) : super(const WorkflowGenerationState());

  Future<void> generateWorkflow(String prompt) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final workflow = await _planner.generateWorkflow(prompt);
      state = state.copyWith(isLoading: false, workflow: workflow);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const WorkflowGenerationState();
  }
}

final workflowGenerationProvider =
    StateNotifierProvider<WorkflowGenerationNotifier, WorkflowGenerationState>((ref) {
  final planner = ref.watch(workflowPlannerProvider);
  return WorkflowGenerationNotifier(planner);
});
