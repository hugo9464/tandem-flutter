// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tandemId: json['tandem_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      paidBy: json['paid_by'] as String,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'tandem_id': instance.tandemId,
      'amount': instance.amount,
      'description': instance.description,
      'paid_by': instance.paidBy,
      'date': instance.date.toIso8601String(),
    };
