import 'package:cloud_firestore/cloud_firestore.dart';

/// App configuration — `/config/app`
class AppConfig {
  final bool maintenanceMode;
  final String minAppVersion;
  final List<String> supportedCities;
  final String? razorpayKeyId;
  final String? mapboxPublicToken;
  final FeatureFlags featureFlags;

  const AppConfig({
    this.maintenanceMode = false,
    this.minAppVersion = '1.0.0',
    this.supportedCities = const [],
    this.razorpayKeyId,
    this.mapboxPublicToken,
    this.featureFlags = const FeatureFlags(),
  });

  factory AppConfig.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppConfig(
      maintenanceMode: d['maintenanceMode'] as bool? ?? false,
      minAppVersion: d['minAppVersion'] as String? ?? '1.0.0',
      supportedCities: (d['supportedCities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      razorpayKeyId: d['razorpayKeyId'] as String?,
      mapboxPublicToken: d['mapboxPublicToken'] as String?,
      featureFlags: d['featureFlags'] is Map<String, dynamic>
          ? FeatureFlags.fromMap(d['featureFlags'] as Map<String, dynamic>)
          : const FeatureFlags(),
    );
  }
}

class FeatureFlags {
  final bool chatEnabled;
  final bool paymentsEnabled;
  final bool liveLocationEnabled;

  const FeatureFlags({
    this.chatEnabled = true,
    this.paymentsEnabled = false,
    this.liveLocationEnabled = false,
  });

  factory FeatureFlags.fromMap(Map<String, dynamic> m) => FeatureFlags(
        chatEnabled: m['chatEnabled'] as bool? ?? true,
        paymentsEnabled: m['paymentsEnabled'] as bool? ?? false,
        liveLocationEnabled: m['liveLocationEnabled'] as bool? ?? false,
      );
}
