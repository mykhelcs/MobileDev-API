import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

@immutable
class WatchProvider {
  const WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
  });

  final int providerId;
  final String providerName;
  final String? logoPath;

  String get logoUrl => logoPath != null
      ? '${AppConstants.tmdbImageBaseUrl}/w92$logoPath'
      : AppConstants.placeholderUrl;

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: (json['provider_id'] as num).toInt(),
      providerName: (json['provider_name'] as String?) ?? '',
      logoPath: json['logo_path'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WatchProvider && other.providerId == providerId;

  @override
  int get hashCode => providerId.hashCode;
}
