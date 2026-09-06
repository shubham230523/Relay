# Fix Compilation Errors in Google Sign-In Integration

The goal is to fix the compilation errors caused by incorrect parameters in `GoogleSignIn.instance.initialize` and missing imports.

## Proposed Changes

### Core Services

#### [MODIFY] [integration_service.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/core/services/integration_service.dart)
- Remove the `scopes` parameter from the `initialize` call as it is not supported in the current version of the plugin.

### Features

#### [MODIFY] [real_integration_repository.dart](file:///C:/Users/shubham/Documents/Flutter1/relay/lib/features/integrations/data/repositories/real_integration_repository.dart)
- Add `import 'package:flutter/foundation.dart';` to resolve the `debugPrint` error.
- Remove the `scopes` parameter from the `initialize` call.
- Pass `ApiConstants.googleScopes` as `scopeHint` to the `authenticate` method to ensure the required permissions are requested.

## Verification Plan

### Manual Verification
- Run `flutter run -d chrome`.
- Verify the app compiles and launches successfully.
- Go to **Integrations** and click **Connect**.
- Confirm that the Google Sign-In prompt appears and correctly requests access to Gmail and Sheets.
