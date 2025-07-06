// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      id: json['id'] as String,
      name: json['name'] as String,
      iban: json['iban'] as String,
      bic: json['bic'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iban': instance.iban,
      'bic': instance.bic,
      'balance': instance.balance,
      'currency': instance.currency,
      'type': instance.type,
    };
