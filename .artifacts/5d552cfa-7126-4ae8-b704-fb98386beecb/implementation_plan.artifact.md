# Fix Layout Assertion and Import Consistency

The goal is to fix the `Trailing widget consumes the entire tile width` assertion error occurring on the Integrations page and ensure layout robustness across the app.

## User Review Required

> [!IMPORTANT]
> I will be modifying the global `AppTheme` to change how buttons are sized by default. This might affect other screens where buttons were relying on `Size.fromHeight(48)` to expand. I will ensure they are wrapped appropriately if needed.

## Proposed Changes

### Core & Theme

#### [MODIFY] [page_container.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/core/widgets/page_container.dart)
- Revert `SizedBox` to `ConstrainedBox` for `maxWidth`. Using `SizedBox` with a fixed width forces the child to be that wide even if the screen is smaller, which leads to layout issues.

#### [MODIFY] [app_theme.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/core/theme/app_theme.dart)
- Update `elevatedButtonTheme` and `outlinedButtonTheme` to use `minimumSize: const Size(0, 48)` instead of `Size.fromHeight(48)`. While `Size.fromHeight(48)` should mean `Size(0, 48)`, explicitly setting it avoids any ambiguity in Material 3's complex layout logic.

### Features

#### [MODIFY] [integrations_page.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/features/integrations/presentation/pages/integrations_page.dart)
- Wrap `ListTile` trailing widgets in a `SizedBox` or `Row(mainAxisSize: min)` to ensure they don't try to occupy more space than they should.

#### [MODIFY] [mock_automation_repository.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/features/automations/data/repositories/mock_automation_repository.dart)
- Fix any remaining relative imports and ensure unique IDs for mock data.

## Verification Plan

### Automated Tests
- N/A (Manual UI verification required for layout issues)

### Manual Verification
- Run `flutter run -d chrome`.
- Go to the **Integrations** page.
- Check for errors in the console.
- Resize the browser window to see if the layout adapts without assertions.
