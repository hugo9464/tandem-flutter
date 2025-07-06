import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String id;
  final String name;
  final String iban;
  final String bic;
  final double balance;
  final String currency;
  final String type;

  Account({
    required this.id,
    required this.name,
    required this.iban,
    required this.bic,
    required this.balance,
    required this.currency,
    required this.type,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}