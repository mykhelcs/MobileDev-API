import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// ============================================================================
/// DATA MODEL: CastMember
/// ============================================================================
/// Represents an actor / cast member returned by TMDB `/movie/{id}/credits`.
@immutable
class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  /// Unique TMDB person identifier
  final int id;

  /// Actor's real name (e.g., "Leonardo DiCaprio")
  final String name;

  /// Character played in the film (e.g., "Dom Cobb")
  final String character;

  /// Relative path to actor profile image on TMDB
  final String? profilePath;

  /// Billing order in cast listing
  final int order;

  // ── Helper Getters ──────────────────────────────────────────────────────────

  /// Full URL for displaying the actor's portrait image
  String get profileUrl => profilePath != null
      ? '${AppConstants.profileW185}$profilePath'
      : AppConstants.placeholderUrl;

  // ── JSON Deserialization ────────────────────────────────────────────────────

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? 'Unknown Actor',
      character: (json['character'] as String?) ?? '',
      profilePath: json['profile_path'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  // ── JSON Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'character': character,
        'profile_path': profilePath,
        'order': order,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CastMember && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CastMember(id: $id, name: $name, character: $character)';
}
