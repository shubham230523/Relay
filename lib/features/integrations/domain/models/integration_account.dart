import 'package:flutter/foundation.dart';

enum IntegrationServiceType {
  google,
  slack,
  make,
}

@immutable
class IntegrationAccount {
  final String id;
  final String email;
  final String displayName;
  final IntegrationServiceType serviceType;
  final bool isConnected;
  final DateTime connectedAt;
  final String? accessToken;
  final String? clientId;
  final String? clientSecret;

  const IntegrationAccount({
    required this.id,
    required this.email,
    required this.displayName,
    required this.serviceType,
    this.isConnected = true,
    required this.connectedAt,
    this.accessToken,
    this.clientId,
    this.clientSecret,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'serviceType': serviceType.name,
      'isConnected': isConnected,
      'connectedAt': connectedAt.toIso8601String(),
      'accessToken': accessToken,
      'clientId': clientId,
      'clientSecret': clientSecret,
    };
  }

  factory IntegrationAccount.fromJson(Map<String, dynamic> json) {
    return IntegrationAccount(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      serviceType: IntegrationServiceType.values.byName(json['serviceType']),
      isConnected: json['isConnected'],
      connectedAt: DateTime.parse(json['connectedAt']),
      accessToken: json['accessToken'],
      clientId: json['clientId'],
      clientSecret: json['clientSecret'],
    );
  }

  IntegrationAccount copyWith({
    bool? isConnected,
    String? accessToken,
    String? clientId,
    String? clientSecret,
  }) {
    return IntegrationAccount(
      id: id,
      email: email,
      displayName: displayName,
      serviceType: serviceType,
      isConnected: isConnected ?? this.isConnected,
      connectedAt: connectedAt,
      accessToken: accessToken ?? this.accessToken,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }
}
