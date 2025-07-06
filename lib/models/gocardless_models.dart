import 'package:json_annotation/json_annotation.dart';

part 'gocardless_models.g.dart';

@JsonSerializable()
class BankInstitution {
  final String id;
  final String name;
  final String bic;
  final String logo;
  final List<String> countries;
  
  @JsonKey(name: 'transaction_total_days')
  final String transactionTotalDays;
  
  @JsonKey(name: 'max_access_valid_for_days')
  final String? maxAccessValidForDays;
  
  @JsonKey(name: 'supported_features')
  final List<String>? supportedFeatures;

  BankInstitution({
    required this.id,
    required this.name,
    required this.bic,
    required this.logo,
    required this.countries,
    required this.transactionTotalDays,
    this.maxAccessValidForDays,
    this.supportedFeatures,
  });
  
  // Helper getters pour convertir les strings en int
  int get transactionTotalDaysInt => int.tryParse(transactionTotalDays) ?? 90;
  int? get maxAccessValidForDaysInt => maxAccessValidForDays != null ? int.tryParse(maxAccessValidForDays!) : null;

  factory BankInstitution.fromJson(Map<String, dynamic> json) =>
      _$BankInstitutionFromJson(json);
  Map<String, dynamic> toJson() => _$BankInstitutionToJson(this);
}

@JsonSerializable()
class BankAccount {
  final String id;
  final String? iban;
  final String? name;
  final String? currency;
  final String? ownerName;
  final String? product;
  final String? accountType;
  final String? cashAccountType;
  final String? resourceId;
  final String? bic;
  final String? msisdn;
  final AccountBalance? balances;

  BankAccount({
    required this.id,
    this.iban,
    this.name,
    this.currency,
    this.ownerName,
    this.product,
    this.accountType,
    this.cashAccountType,
    this.resourceId,
    this.bic,
    this.msisdn,
    this.balances,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) =>
      _$BankAccountFromJson(json);
  Map<String, dynamic> toJson() => _$BankAccountToJson(this);
}

@JsonSerializable()
class AccountBalance {
  final List<BalanceAmount>? balances;

  AccountBalance({this.balances});

  factory AccountBalance.fromJson(Map<String, dynamic> json) =>
      _$AccountBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$AccountBalanceToJson(this);
}

@JsonSerializable()
class BalanceAmount {
  final BalanceValue balanceAmount;
  final String balanceType;
  final String? lastChangeDateTime;
  final String? referenceDate;

  BalanceAmount({
    required this.balanceAmount,
    required this.balanceType,
    this.lastChangeDateTime,
    this.referenceDate,
  });

  factory BalanceAmount.fromJson(Map<String, dynamic> json) =>
      _$BalanceAmountFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceAmountToJson(this);
}

@JsonSerializable()
class BalanceValue {
  final String amount;
  final String currency;

  BalanceValue({
    required this.amount,
    required this.currency,
  });

  factory BalanceValue.fromJson(Map<String, dynamic> json) =>
      _$BalanceValueFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceValueToJson(this);
}

@JsonSerializable()
class GoCardlessTransaction {
  final String? transactionId;
  final String? bookingDate;
  final String? valueDate;
  final TransactionAmount transactionAmount;
  final String? debtorName;
  final DebtorAccount? debtorAccount;
  final String? creditorName;
  final CreditorAccount? creditorAccount;
  final String? remittanceInformationUnstructured;
  final List<String>? remittanceInformationUnstructuredArray;
  final String? bankTransactionCode;
  final String? proprietaryBankTransactionCode;
  final String? internalTransactionId;

  GoCardlessTransaction({
    this.transactionId,
    this.bookingDate,
    this.valueDate,
    required this.transactionAmount,
    this.debtorName,
    this.debtorAccount,
    this.creditorName,
    this.creditorAccount,
    this.remittanceInformationUnstructured,
    this.remittanceInformationUnstructuredArray,
    this.bankTransactionCode,
    this.proprietaryBankTransactionCode,
    this.internalTransactionId,
  });

  // Helper pour obtenir la description de la transaction
  String? get description {
    if (remittanceInformationUnstructured != null) {
      return remittanceInformationUnstructured;
    }
    if (remittanceInformationUnstructuredArray != null && remittanceInformationUnstructuredArray!.isNotEmpty) {
      return remittanceInformationUnstructuredArray!.join(' - ');
    }
    return null;
  }

  factory GoCardlessTransaction.fromJson(Map<String, dynamic> json) =>
      _$GoCardlessTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$GoCardlessTransactionToJson(this);
}

@JsonSerializable()
class TransactionAmount {
  final String amount;
  final String currency;

  TransactionAmount({
    required this.amount,
    required this.currency,
  });

  factory TransactionAmount.fromJson(Map<String, dynamic> json) =>
      _$TransactionAmountFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionAmountToJson(this);
}

@JsonSerializable()
class DebtorAccount {
  final String? iban;

  DebtorAccount({this.iban});

  factory DebtorAccount.fromJson(Map<String, dynamic> json) =>
      _$DebtorAccountFromJson(json);
  Map<String, dynamic> toJson() => _$DebtorAccountToJson(this);
}

@JsonSerializable()
class CreditorAccount {
  final String? iban;

  CreditorAccount({this.iban});

  factory CreditorAccount.fromJson(Map<String, dynamic> json) =>
      _$CreditorAccountFromJson(json);
  Map<String, dynamic> toJson() => _$CreditorAccountToJson(this);
}

@JsonSerializable()
class GoCardlessRequisition {
  final String id;
  final String status;
  final String institutionId;
  final String link;
  final List<String> accounts;
  final String? reference;
  final String userLanguage;
  final String created;

  GoCardlessRequisition({
    required this.id,
    required this.status,
    required this.institutionId,
    required this.link,
    required this.accounts,
    this.reference,
    required this.userLanguage,
    required this.created,
  });

  factory GoCardlessRequisition.fromJson(Map<String, dynamic> json) =>
      _$GoCardlessRequisitionFromJson(json);
  Map<String, dynamic> toJson() => _$GoCardlessRequisitionToJson(this);
}

@JsonSerializable()
class GoCardlessTransactionResponse {
  final List<GoCardlessTransaction> booked;
  final List<GoCardlessTransaction> pending;

  GoCardlessTransactionResponse({
    required this.booked,
    required this.pending,
  });

  factory GoCardlessTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$GoCardlessTransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GoCardlessTransactionResponseToJson(this);
}