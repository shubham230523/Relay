import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

class AutomationDetailsPage extends StatelessWidget {
  final String id;
  const AutomationDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Details'),
      ),
      body: PageContainer(
        child: Center(
          child: Text('Details for Automation ID: $id'),
        ),
      ),
    );
  }
}
