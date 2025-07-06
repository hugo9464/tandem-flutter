import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

enum TransactionType {
  @JsonValue('DEBIT')
  debit,
  @JsonValue('CREDIT')
  credit,
}

enum TransactionStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class Transaction {
  final String id;
  final String accountId;
  final double amount;
  final String currency;
  final DateTime date;
  final String description;
  final TransactionType type;
  final TransactionStatus status;
  final String? reference;
  final String? category;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.description,
    required this.type,
    required this.status,
    this.reference,
    this.category,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class TransactionFilters {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final TransactionType? type;
  final TransactionStatus? status;
  final String? search;
  final String? accountId;
  final double? minAmount;
  final double? maxAmount;

  TransactionFilters({
    this.dateFrom,
    this.dateTo,
    this.type,
    this.status,
    this.search,
    this.accountId,
    this.minAmount,
    this.maxAmount,
  });

  factory TransactionFilters.fromJson(Map<String, dynamic> json) => 
      _$TransactionFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionFiltersToJson(this);
}

@JsonSerializable()
class TransactionResponse {
  final List<Transaction> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  TransactionResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) => 
      _$TransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionResponseToJson(this);
}