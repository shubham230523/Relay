import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/template_providers.dart';
import '../widgets/template_card.dart';
import '../widgets/template_filters.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(filteredTemplatesProvider);
    final theme = Theme.of(context);

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Templates',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppLayout.spaceXS),
          Text(
            'Start fast with pre-built automation workflows.',
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppLayout.spaceL),
          const TemplateSearchBar(),
          const SizedBox(height: AppLayout.spaceM),
          const TemplateCategoryFilter(),
          const SizedBox(height: AppLayout.spaceL),
          if (templates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppLayout.spaceXL),
                child: Text('No templates found matching your criteria.'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000 
                    ? 3 
                    : constraints.maxWidth > 600 
                        ? 2 
                        : 1;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppLayout.spaceM,
                    mainAxisSpacing: AppLayout.spaceM,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return TemplateCard(
                      template: template,
                      onTap: () {
                        context.push(AppRoutes.templateDetails.replaceFirst(':id', template.id));
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
