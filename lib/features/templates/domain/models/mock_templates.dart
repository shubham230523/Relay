import 'package:flutter/material.dart';
import '../../../workflow_builder/domain/models/models.dart';
import 'automation_template.dart';

class MockTemplates {
  MockTemplates._();

  static final List<AutomationTemplate> all = [
    _dailyEmailSummary,
    _invoiceToSpreadsheet,
    _meetingToTasks,
    _dailyAiBriefing,
    _importantEmailAlerts,
    _leadProcessing,
    _documentSummarization,
    _weeklyBusinessReport,
  ];

  static final _now = DateTime.now();

  static final _dailyEmailSummary = AutomationTemplate(
    id: 'tpl_1',
    name: 'Email Daily Summary',
    description: 'Summarize all important emails from the last 24 hours into a single briefing.',
    category: AutomationTemplateCategory.email,
    icon: Icons.summarize_outlined,
    workflow: Workflow(
      id: 'wf_tpl_1',
      name: 'Daily Email Summary',
      description: 'AI-powered email summarization',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Schedule',
          description: 'Runs every morning at 8:00 AM.',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.action,
          title: 'Fetch Emails',
          description: 'Gets emails from the last 24 hours.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.ai,
          title: 'Summarize',
          description: 'AI generates a concise summary of key points.',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Send Notification',
          description: 'Sends the summary via mobile push.',
          position: Offset(100, 550),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _invoiceToSpreadsheet = AutomationTemplate(
    id: 'tpl_2',
    name: 'Invoice to Spreadsheet',
    description: 'Extract data from email invoices and save them directly to Google Sheets.',
    category: AutomationTemplateCategory.finance,
    icon: Icons.receipt_long_outlined,
    workflow: Workflow(
      id: 'wf_tpl_2',
      name: 'Invoice Processing',
      description: 'Automated invoice tracking',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'New Email',
          description: 'Triggers on emails with "Invoice" in subject.',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.ai,
          title: 'Extract Details',
          description: 'Extracts amount, vendor, and due date.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.action,
          title: 'Add Row',
          description: 'Appends data to the Finance spreadsheet.',
          position: Offset(100, 400),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _meetingToTasks = AutomationTemplate(
    id: 'tpl_3',
    name: 'Meeting to Tasks',
    description: 'Convert action items from meeting transcripts into tasks in your favorite tool.',
    category: AutomationTemplateCategory.productivity,
    icon: Icons.task_outlined,
    workflow: Workflow(
      id: 'wf_tpl_3',
      name: 'Meeting Action Items',
      description: 'Meeting notes automation',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Meeting Ended',
          description: 'Triggers when a calendar meeting finishes.',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.action,
          title: 'Get Transcript',
          description: 'Fetches the recorded transcript.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.ai,
          title: 'Identify Tasks',
          description: 'AI finds action items and owners.',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Create Tasks',
          description: 'Creates tasks in the project board.',
          position: Offset(100, 550),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _dailyAiBriefing = AutomationTemplate(
    id: 'tpl_4',
    name: 'Daily AI Briefing',
    description: 'Get a personalized briefing on top news and trends in your industry.',
    category: AutomationTemplateCategory.ai,
    icon: Icons.auto_awesome_outlined,
    workflow: Workflow(
      id: 'wf_tpl_4',
      name: 'AI Industry Briefing',
      description: 'Intelligent news aggregation',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Daily at 7:00 AM',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.action,
          title: 'Search Trends',
          description: 'Searches for key industry keywords.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.ai,
          title: 'Analyze & Filter',
          description: 'Filters for relevance and summarizes.',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Format Email',
          position: Offset(100, 550),
        ),
        const WorkflowNode(
          id: 'n5',
          type: WorkflowNodeType.action,
          title: 'Send Briefing',
          position: Offset(100, 700),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4'),
        WorkflowEdge(id: 'e4', sourceNodeId: 'n4', targetNodeId: 'n5'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _importantEmailAlerts = AutomationTemplate(
    id: 'tpl_5',
    name: 'Important Email Alerts',
    description: 'Never miss a critical email from VIP clients or urgent topics.',
    category: AutomationTemplateCategory.email,
    icon: Icons.notification_important_outlined,
    workflow: Workflow(
      id: 'wf_tpl_5',
      name: 'VIP Email Alerts',
      description: 'Urgent priority notification',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Any Email',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.ai,
          title: 'Check Urgency',
          description: 'Analyzes intent and sender priority.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.logic,
          title: 'Is Urgent?',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Urgent Call',
          description: 'Triggers an automated phone alert.',
          position: Offset(100, 550),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4', label: 'Yes'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _leadProcessing = AutomationTemplate(
    id: 'tpl_6',
    name: 'Lead Processing',
    description: 'Automatically qualify and route new business leads from your website.',
    category: AutomationTemplateCategory.business,
    icon: Icons.person_add_outlined,
    workflow: Workflow(
      id: 'wf_tpl_6',
      name: 'Lead Qualification',
      description: 'Sales pipeline automation',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Form Submission',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.ai,
          title: 'Score Lead',
          description: 'AI evaluates lead quality and budget.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.action,
          title: 'Add to CRM',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Notify Sales',
          position: Offset(100, 550),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _documentSummarization = AutomationTemplate(
    id: 'tpl_7',
    name: 'Document Summarization',
    description: 'Upload a document and get an AI summary sent to Slack automatically.',
    category: AutomationTemplateCategory.ai,
    icon: Icons.description_outlined,
    workflow: Workflow(
      id: 'wf_tpl_7',
      name: 'Auto-Summarizer',
      description: 'Document processing flow',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'New File',
          description: 'Triggers when a file is added to the folder.',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.ai,
          title: 'Analyze File',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.action,
          title: 'Post to Slack',
          position: Offset(100, 400),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );

  static final _weeklyBusinessReport = AutomationTemplate(
    id: 'tpl_8',
    name: 'Weekly Business Report',
    description: 'Consolidate metrics from multiple sources into a weekly PDF report.',
    category: AutomationTemplateCategory.business,
    icon: Icons.analytics_outlined,
    workflow: Workflow(
      id: 'wf_tpl_8',
      name: 'Weekly Insight Report',
      description: 'Executive reporting flow',
      nodes: [
        const WorkflowNode(
          id: 'n1',
          type: WorkflowNodeType.trigger,
          title: 'Friday at 5:00 PM',
          position: Offset(100, 100),
        ),
        const WorkflowNode(
          id: 'n2',
          type: WorkflowNodeType.action,
          title: 'Fetch Metrics',
          description: 'Pulls data from Stripe and Google Analytics.',
          position: Offset(100, 250),
        ),
        const WorkflowNode(
          id: 'n3',
          type: WorkflowNodeType.ai,
          title: 'Generate Insights',
          description: 'Identifies growth and risk areas.',
          position: Offset(100, 400),
        ),
        const WorkflowNode(
          id: 'n4',
          type: WorkflowNodeType.action,
          title: 'Generate PDF',
          position: Offset(100, 550),
        ),
        const WorkflowNode(
          id: 'n5',
          type: WorkflowNodeType.action,
          title: 'Email Stakeholders',
          position: Offset(100, 700),
        ),
      ],
      edges: const [
        WorkflowEdge(id: 'e1', sourceNodeId: 'n1', targetNodeId: 'n2'),
        WorkflowEdge(id: 'e2', sourceNodeId: 'n2', targetNodeId: 'n3'),
        WorkflowEdge(id: 'e3', sourceNodeId: 'n3', targetNodeId: 'n4'),
        WorkflowEdge(id: 'e4', sourceNodeId: 'n4', targetNodeId: 'n5'),
      ],
      createdAt: _now,
      updatedAt: _now,
    ),
  );
}
