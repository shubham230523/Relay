import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/widgets.dart';

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          AutomationsHeader(),
          SizedBox(height: AppLayout.spaceL),
          AutomationSearchBar(),
          SizedBox(height: AppLayout.spaceS),
          AutomationStatusFilter(),
          SizedBox(height: AppLayout.spaceM),
          AutomationsList(),
        ],
      ),
    );
  }
}
