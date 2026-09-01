import 'package:flutter/foundation.dart';

enum IntegrationServiceType {
  google,
  slack,
}

@immutable
class IntegrationAccount {
  final String id;
  final String email;
  final String displayName;
  final IntegrationServiceType serviceType;
  final bool isConnected;
  final DateTime connectedAt;

  const IntegrationAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.serviceType,
    this.isConnected = true,
    required this.connectedAt,
  });

  IntegrationAccount copyWith({
    bool? isConnected,
  }) {
    return IntegrationAccount(
      id: id,
      email: email,
      displayName: displayName,
      serviceType: serviceType,
      isConnected: isConnected ?? this.isConnected,
      connectedAt: connectedAt,
    );
  }
}
