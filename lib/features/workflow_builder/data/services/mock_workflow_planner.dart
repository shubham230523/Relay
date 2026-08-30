import 'package:flutter/painting.dart';
import '../../domain/models/models.dart';
import '../../domain/services/workflow_planner.dart';

class MockWorkflowPlanner implements WorkflowPlanner {
  @override
  Future<Workflow> generateWorkflow(String userPrompt) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    final normalizedPrompt = userPrompt.toLowerCase().trim();

    if (normalizedPrompt.contains('invoice') && normalizedPrompt.contains('email')) {
      return _generateInvoiceWorkflow();
    }

    return _generateGenericWorkflow(userPrompt);
  }

  Workflow _generateInvoiceWorkflow() {
    final now = DateTime.now();
    return Workflow(
      id: 'wf_invoice_${now.millisecondsSinceEpoch}',
      name: 'Invoice Processing Workflow',
      description: 'Automatically processes received invoices from email.',
      createdAt: now,
      updatedAt: now,
      nodes: [
        const WorkflowNode(
          id: 'node_1',
          type: WorkflowNodeType.trigger,
          title: 'New Email',
          description: 'Triggers when a new email with an invoice is received.',
          position: Offset(100, 100),
          configuration: {'filter': 'subject:invoice'},
        ),
        const WorkflowNode(
          id: 'node_2',
          type: WorkflowNodeType.ai,
          title: 'Analyze Invoice',
          description: 'Uses AI to extract details like amount, vendor, and date.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'node_3',
          type: WorkflowNodeType.action,
          title: 'Save to Google Sheets',
          description: 'Appends invoice details to a spreadsheet.',
          position: Offset(100, 400),
          configuration: {'spreadsheetId': 'invoices_2026'},
        ),
        const WorkflowNode(
          id: 'node_4',
          type: WorkflowNodeType.logic,
          title: 'Amount > \$50,000',
          description: 'Checks if the extracted amount exceeds the threshold.',
          position: Offset(100, 550),
          configuration: {'condition': 'amount > 50000'},
        ),
        const WorkflowNode(
          id: 'node_5',
          type: WorkflowNodeType.action,
          title: 'Notify User',
          description: 'Sends a high-priority notification for large invoices.',
          position: Offset(100, 700),
          configuration: {'channel': 'slack', 'priority': 'high'},
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'edge_1', sourceNodeId: 'node_1', targetNodeId: 'node_2'),
        WorkflowEdge(id: 'edge_2', sourceNodeId: 'node_2', targetNodeId: 'node_3'),
        WorkflowEdge(id: 'edge_3', sourceNodeId: 'node_3', targetNodeId: 'node_4'),
        WorkflowEdge(
          id: 'edge_4',
          sourceNodeId: 'node_4',
          targetNodeId: 'node_5',
          label: 'If True',
        ),
      ],
    );
  }

  Workflow _generateGenericWorkflow(String prompt) {
    final now = DateTime.now();
    return Workflow(
      id: 'wf_generic_${now.millisecondsSinceEpoch}',
      name: 'Custom Workflow',
      description: 'Generated based on: "$prompt"',
      createdAt: now,
      updatedAt: now,
      nodes: [
        const WorkflowNode(
          id: 'node_1',
          type: WorkflowNodeType.trigger,
          title: 'Initial Trigger',
          description: 'Starting point of your automation.',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'node_2',
          type: WorkflowNodeType.action,
          title: 'Generic Action',
          description: 'An action based on your prompt.',
          position: Offset(100, 300),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'edge_1', sourceNodeId: 'node_1', targetNodeId: 'node_2'),
      ],
    );
  }
}
