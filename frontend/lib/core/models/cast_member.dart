import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

@immutable
class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  String get profileUrl => profilePath != null
      ? '${AppConstants.profileW185}$profilePath'
      : AppConstants.placeholderUrl;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      character: (json['character'] as String?) ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  @override
  bool operator ==(Object other) => other is CastMember && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
