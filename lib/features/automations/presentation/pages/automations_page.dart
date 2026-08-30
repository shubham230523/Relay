import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/automations_header.dart';

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutomationsHeader(),
          SizedBox(height: AppLayout.spaceL),
          // Automation list will go here
        ],
      ),
    );
  }
}
