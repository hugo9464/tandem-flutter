import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'tandem_id')
  final String tandemId;
  final double amount;
  final String description;
  @JsonKey(name: 'paid_by')
  final String paidBy;
  final DateTime date;

  Expense({
    required this.id,
    required this.userId,
    required this.tandemId,
    required this.amount,
    required this.description,
    required this.paidBy,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}