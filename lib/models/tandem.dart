import 'package:json_annotation/json_annotation.dart';

part 'tandem.g.dart';

@JsonSerializable()
class Tandem {
  final String id;
  final String name;
  final String code;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Tandem({
    required this.id,
    required this.name,
    required this.code,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory Tandem.fromJson(Map<String, dynamic> json) => _$TandemFromJson(json);
  Map<String, dynamic> toJson() => _$TandemToJson(this);
}

@JsonSerializable()
class TandemMember {
  final String id;
  @JsonKey(name: 'tandem_id')
  final String tandemId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String role;
  final String? email;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  TandemMember({
    required this.id,
    required this.tandemId,
    required this.userId,
    required this.role,
    this.email,
    required this.joinedAt,
  });

  factory TandemMember.fromJson(Map<String, dynamic> json) => _$TandemMemberFromJson(json);
  Map<String, dynamic> toJson() => _$TandemMemberToJson(this);
}