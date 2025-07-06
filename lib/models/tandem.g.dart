// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tandem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tandem _$TandemFromJson(Map<String, dynamic> json) => Tandem(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TandemToJson(Tandem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

TandemMember _$TandemMemberFromJson(Map<String, dynamic> json) => TandemMember(
      id: json['id'] as String,
      tandemId: json['tandem_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      email: json['email'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$TandemMemberToJson(TandemMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tandem_id': instance.tandemId,
      'user_id': instance.userId,
      'role': instance.role,
      'email': instance.email,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
