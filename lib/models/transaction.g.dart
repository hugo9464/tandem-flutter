// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      reference: json['reference'] as String?,
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'reference': instance.reference,
      'category': instance.category,
      'metadata': instance.metadata,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.debit: 'DEBIT',
  TransactionType.credit: 'CREDIT',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'PENDING',
  TransactionStatus.completed: 'COMPLETED',
  TransactionStatus.failed: 'FAILED',
  TransactionStatus.cancelled: 'CANCELLED',
};

TransactionFilters _$TransactionFiltersFromJson(Map<String, dynamic> json) =>
    TransactionFilters(
      dateFrom: json['dateFrom'] == null
          ? null
          : DateTime.parse(json['dateFrom'] as String),
      dateTo: json['dateTo'] == null
          ? null
          : DateTime.parse(json['dateTo'] as String),
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']),
      search: json['search'] as String?,
      accountId: json['accountId'] as String?,
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TransactionFiltersToJson(TransactionFilters instance) =>
    <String, dynamic>{
      'dateFrom': instance.dateFrom?.toIso8601String(),
      'dateTo': instance.dateTo?.toIso8601String(),
      'type': _$TransactionTypeEnumMap[instance.type],
      'status': _$TransactionStatusEnumMap[instance.status],
      'search': instance.search,
      'accountId': instance.accountId,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
    };

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionResponseToJson(
        TransactionResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
