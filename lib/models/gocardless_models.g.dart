// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gocardless_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankInstitution _$BankInstitutionFromJson(Map<String, dynamic> json) =>
    BankInstitution(
      id: json['id'] as String,
      name: json['name'] as String,
      bic: json['bic'] as String,
      logo: json['logo'] as String,
      countries:
          (json['countries'] as List<dynamic>).map((e) => e as String).toList(),
      transactionTotalDays: json['transaction_total_days'] as String,
      maxAccessValidForDays: json['max_access_valid_for_days'] as String?,
      supportedFeatures: (json['supported_features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BankInstitutionToJson(BankInstitution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bic': instance.bic,
      'logo': instance.logo,
      'countries': instance.countries,
      'transaction_total_days': instance.transactionTotalDays,
      'max_access_valid_for_days': instance.maxAccessValidForDays,
      'supported_features': instance.supportedFeatures,
    };

BankAccount _$BankAccountFromJson(Map<String, dynamic> json) => BankAccount(
      id: json['id'] as String,
      iban: json['iban'] as String?,
      name: json['name'] as String?,
      currency: json['currency'] as String?,
      ownerName: json['ownerName'] as String?,
      product: json['product'] as String?,
      accountType: json['accountType'] as String?,
      cashAccountType: json['cashAccountType'] as String?,
      resourceId: json['resourceId'] as String?,
      bic: json['bic'] as String?,
      msisdn: json['msisdn'] as String?,
      balances: json['balances'] == null
          ? null
          : AccountBalance.fromJson(json['balances'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BankAccountToJson(BankAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iban': instance.iban,
      'name': instance.name,
      'currency': instance.currency,
      'ownerName': instance.ownerName,
      'product': instance.product,
      'accountType': instance.accountType,
      'cashAccountType': instance.cashAccountType,
      'resourceId': instance.resourceId,
      'bic': instance.bic,
      'msisdn': instance.msisdn,
      'balances': instance.balances,
    };

AccountBalance _$AccountBalanceFromJson(Map<String, dynamic> json) =>
    AccountBalance(
      balances: (json['balances'] as List<dynamic>?)
          ?.map((e) => BalanceAmount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountBalanceToJson(AccountBalance instance) =>
    <String, dynamic>{
      'balances': instance.balances,
    };

BalanceAmount _$BalanceAmountFromJson(Map<String, dynamic> json) =>
    BalanceAmount(
      balanceAmount:
          BalanceValue.fromJson(json['balanceAmount'] as Map<String, dynamic>),
      balanceType: json['balanceType'] as String,
      lastChangeDateTime: json['lastChangeDateTime'] as String?,
      referenceDate: json['referenceDate'] as String?,
    );

Map<String, dynamic> _$BalanceAmountToJson(BalanceAmount instance) =>
    <String, dynamic>{
      'balanceAmount': instance.balanceAmount,
      'balanceType': instance.balanceType,
      'lastChangeDateTime': instance.lastChangeDateTime,
      'referenceDate': instance.referenceDate,
    };

BalanceValue _$BalanceValueFromJson(Map<String, dynamic> json) => BalanceValue(
      amount: json['amount'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$BalanceValueToJson(BalanceValue instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
    };

GoCardlessTransaction _$GoCardlessTransactionFromJson(
        Map<String, dynamic> json) =>
    GoCardlessTransaction(
      transactionId: json['transactionId'] as String?,
      bookingDate: json['bookingDate'] as String?,
      valueDate: json['valueDate'] as String?,
      transactionAmount: TransactionAmount.fromJson(
          json['transactionAmount'] as Map<String, dynamic>),
      debtorName: json['debtorName'] as String?,
      debtorAccount: json['debtorAccount'] == null
          ? null
          : DebtorAccount.fromJson(
              json['debtorAccount'] as Map<String, dynamic>),
      creditorName: json['creditorName'] as String?,
      creditorAccount: json['creditorAccount'] == null
          ? null
          : CreditorAccount.fromJson(
              json['creditorAccount'] as Map<String, dynamic>),
      remittanceInformationUnstructured:
          json['remittanceInformationUnstructured'] as String?,
      remittanceInformationUnstructuredArray:
          (json['remittanceInformationUnstructuredArray'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      bankTransactionCode: json['bankTransactionCode'] as String?,
      proprietaryBankTransactionCode:
          json['proprietaryBankTransactionCode'] as String?,
      internalTransactionId: json['internalTransactionId'] as String?,
    );

Map<String, dynamic> _$GoCardlessTransactionToJson(
        GoCardlessTransaction instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'bookingDate': instance.bookingDate,
      'valueDate': instance.valueDate,
      'transactionAmount': instance.transactionAmount,
      'debtorName': instance.debtorName,
      'debtorAccount': instance.debtorAccount,
      'creditorName': instance.creditorName,
      'creditorAccount': instance.creditorAccount,
      'remittanceInformationUnstructured':
          instance.remittanceInformationUnstructured,
      'remittanceInformationUnstructuredArray':
          instance.remittanceInformationUnstructuredArray,
      'bankTransactionCode': instance.bankTransactionCode,
      'proprietaryBankTransactionCode': instance.proprietaryBankTransactionCode,
      'internalTransactionId': instance.internalTransactionId,
    };

TransactionAmount _$TransactionAmountFromJson(Map<String, dynamic> json) =>
    TransactionAmount(
      amount: json['amount'] as String,
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$TransactionAmountToJson(TransactionAmount instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
    };

DebtorAccount _$DebtorAccountFromJson(Map<String, dynamic> json) =>
    DebtorAccount(
      iban: json['iban'] as String?,
    );

Map<String, dynamic> _$DebtorAccountToJson(DebtorAccount instance) =>
    <String, dynamic>{
      'iban': instance.iban,
    };

CreditorAccount _$CreditorAccountFromJson(Map<String, dynamic> json) =>
    CreditorAccount(
      iban: json['iban'] as String?,
    );

Map<String, dynamic> _$CreditorAccountToJson(CreditorAccount instance) =>
    <String, dynamic>{
      'iban': instance.iban,
    };

GoCardlessRequisition _$GoCardlessRequisitionFromJson(
        Map<String, dynamic> json) =>
    GoCardlessRequisition(
      id: json['id'] as String,
      status: json['status'] as String,
      institutionId: json['institutionId'] as String,
      link: json['link'] as String,
      accounts:
          (json['accounts'] as List<dynamic>).map((e) => e as String).toList(),
      reference: json['reference'] as String?,
      userLanguage: json['userLanguage'] as String,
      created: json['created'] as String,
    );

Map<String, dynamic> _$GoCardlessRequisitionToJson(
        GoCardlessRequisition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'institutionId': instance.institutionId,
      'link': instance.link,
      'accounts': instance.accounts,
      'reference': instance.reference,
      'userLanguage': instance.userLanguage,
      'created': instance.created,
    };

GoCardlessTransactionResponse _$GoCardlessTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    GoCardlessTransactionResponse(
      booked: (json['booked'] as List<dynamic>)
          .map((e) => GoCardlessTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      pending: (json['pending'] as List<dynamic>)
          .map((e) => GoCardlessTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GoCardlessTransactionResponseToJson(
        GoCardlessTransactionResponse instance) =>
    <String, dynamic>{
      'booked': instance.booked,
      'pending': instance.pending,
    };
