// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kgwebo_database.dart';

// ignore_for_file: type=lint
class $CachedBusinessesTable extends CachedBusinesses
    with TableInfo<$CachedBusinessesTable, CachedBusinessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBusinessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessTypeMeta = const VerificationMeta(
    'businessType',
  );
  @override
  late final GeneratedColumn<String> businessType = GeneratedColumn<String>(
    'business_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMinorMeta =
      const VerificationMeta('openingBalanceMinor');
  @override
  late final GeneratedColumn<int> openingBalanceMinor = GeneratedColumn<int>(
    'opening_balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedOnMeta = const VerificationMeta(
    'startedOn',
  );
  @override
  late final GeneratedColumn<String> startedOn = GeneratedColumn<String>(
    'started_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPhoneMeta = const VerificationMeta(
    'contactPhone',
  );
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
    'contact_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    name,
    businessType,
    countryCode,
    currencyCode,
    openingBalanceMinor,
    description,
    startedOn,
    contactPhone,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_businesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBusinessesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('business_type')) {
      context.handle(
        _businessTypeMeta,
        businessType.isAcceptableOrUnknown(
          data['business_type']!,
          _businessTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessTypeMeta);
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryCodeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('opening_balance_minor')) {
      context.handle(
        _openingBalanceMinorMeta,
        openingBalanceMinor.isAcceptableOrUnknown(
          data['opening_balance_minor']!,
          _openingBalanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceMinorMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('started_on')) {
      context.handle(
        _startedOnMeta,
        startedOn.isAcceptableOrUnknown(data['started_on']!, _startedOnMeta),
      );
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
        _contactPhoneMeta,
        contactPhone.isAcceptableOrUnknown(
          data['contact_phone']!,
          _contactPhoneMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  CachedBusinessesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBusinessesData(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      businessType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_type'],
          )!,
      countryCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}country_code'],
          )!,
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      openingBalanceMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}opening_balance_minor'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_on'],
      ),
      contactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_phone'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedBusinessesTable createAlias(String alias) {
    return $CachedBusinessesTable(attachedDatabase, alias);
  }
}

class CachedBusinessesData extends DataClass
    implements Insertable<CachedBusinessesData> {
  final String remoteId;
  final String ownerId;
  final String name;
  final String businessType;
  final String countryCode;
  final String currencyCode;
  final int openingBalanceMinor;
  final String? description;
  final String? startedOn;
  final String? contactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedBusinessesData({
    required this.remoteId,
    required this.ownerId,
    required this.name,
    required this.businessType,
    required this.countryCode,
    required this.currencyCode,
    required this.openingBalanceMinor,
    this.description,
    this.startedOn,
    this.contactPhone,
    this.createdAt,
    this.updatedAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['business_type'] = Variable<String>(businessType);
    map['country_code'] = Variable<String>(countryCode);
    map['currency_code'] = Variable<String>(currencyCode);
    map['opening_balance_minor'] = Variable<int>(openingBalanceMinor);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || startedOn != null) {
      map['started_on'] = Variable<String>(startedOn);
    }
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedBusinessesCompanion toCompanion(bool nullToAbsent) {
    return CachedBusinessesCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      name: Value(name),
      businessType: Value(businessType),
      countryCode: Value(countryCode),
      currencyCode: Value(currencyCode),
      openingBalanceMinor: Value(openingBalanceMinor),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      startedOn:
          startedOn == null && nullToAbsent
              ? const Value.absent()
              : Value(startedOn),
      contactPhone:
          contactPhone == null && nullToAbsent
              ? const Value.absent()
              : Value(contactPhone),
      createdAt:
          createdAt == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedBusinessesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBusinessesData(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      businessType: serializer.fromJson<String>(json['businessType']),
      countryCode: serializer.fromJson<String>(json['countryCode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      openingBalanceMinor: serializer.fromJson<int>(
        json['openingBalanceMinor'],
      ),
      description: serializer.fromJson<String?>(json['description']),
      startedOn: serializer.fromJson<String?>(json['startedOn']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'businessType': serializer.toJson<String>(businessType),
      'countryCode': serializer.toJson<String>(countryCode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'openingBalanceMinor': serializer.toJson<int>(openingBalanceMinor),
      'description': serializer.toJson<String?>(description),
      'startedOn': serializer.toJson<String?>(startedOn),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedBusinessesData copyWith({
    String? remoteId,
    String? ownerId,
    String? name,
    String? businessType,
    String? countryCode,
    String? currencyCode,
    int? openingBalanceMinor,
    Value<String?> description = const Value.absent(),
    Value<String?> startedOn = const Value.absent(),
    Value<String?> contactPhone = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedBusinessesData(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    businessType: businessType ?? this.businessType,
    countryCode: countryCode ?? this.countryCode,
    currencyCode: currencyCode ?? this.currencyCode,
    openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
    description: description.present ? description.value : this.description,
    startedOn: startedOn.present ? startedOn.value : this.startedOn,
    contactPhone: contactPhone.present ? contactPhone.value : this.contactPhone,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedBusinessesData copyWithCompanion(CachedBusinessesCompanion data) {
    return CachedBusinessesData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      businessType:
          data.businessType.present
              ? data.businessType.value
              : this.businessType,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      openingBalanceMinor:
          data.openingBalanceMinor.present
              ? data.openingBalanceMinor.value
              : this.openingBalanceMinor,
      description:
          data.description.present ? data.description.value : this.description,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      contactPhone:
          data.contactPhone.present
              ? data.contactPhone.value
              : this.contactPhone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBusinessesData(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('businessType: $businessType, ')
          ..write('countryCode: $countryCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('description: $description, ')
          ..write('startedOn: $startedOn, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    name,
    businessType,
    countryCode,
    currencyCode,
    openingBalanceMinor,
    description,
    startedOn,
    contactPhone,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBusinessesData &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.businessType == this.businessType &&
          other.countryCode == this.countryCode &&
          other.currencyCode == this.currencyCode &&
          other.openingBalanceMinor == this.openingBalanceMinor &&
          other.description == this.description &&
          other.startedOn == this.startedOn &&
          other.contactPhone == this.contactPhone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedBusinessesCompanion extends UpdateCompanion<CachedBusinessesData> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> businessType;
  final Value<String> countryCode;
  final Value<String> currencyCode;
  final Value<int> openingBalanceMinor;
  final Value<String?> description;
  final Value<String?> startedOn;
  final Value<String?> contactPhone;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedBusinessesCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.businessType = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    this.description = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBusinessesCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String name,
    required String businessType,
    required String countryCode,
    required String currencyCode,
    required int openingBalanceMinor,
    this.description = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       name = Value(name),
       businessType = Value(businessType),
       countryCode = Value(countryCode),
       currencyCode = Value(currencyCode),
       openingBalanceMinor = Value(openingBalanceMinor),
       cachedAt = Value(cachedAt);
  static Insertable<CachedBusinessesData> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? businessType,
    Expression<String>? countryCode,
    Expression<String>? currencyCode,
    Expression<int>? openingBalanceMinor,
    Expression<String>? description,
    Expression<String>? startedOn,
    Expression<String>? contactPhone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (businessType != null) 'business_type': businessType,
      if (countryCode != null) 'country_code': countryCode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (openingBalanceMinor != null)
        'opening_balance_minor': openingBalanceMinor,
      if (description != null) 'description': description,
      if (startedOn != null) 'started_on': startedOn,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBusinessesCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String>? businessType,
    Value<String>? countryCode,
    Value<String>? currencyCode,
    Value<int>? openingBalanceMinor,
    Value<String?>? description,
    Value<String?>? startedOn,
    Value<String?>? contactPhone,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedBusinessesCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      description: description ?? this.description,
      startedOn: startedOn ?? this.startedOn,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<String>(businessType.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (openingBalanceMinor.present) {
      map['opening_balance_minor'] = Variable<int>(openingBalanceMinor.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(startedOn.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBusinessesCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('businessType: $businessType, ')
          ..write('countryCode: $countryCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('description: $description, ')
          ..write('startedOn: $startedOn, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTransactionsTable extends CachedTransactions
    with TableInfo<$CachedTransactionsTable, CachedTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    businessId,
    createdBy,
    idempotencyKey,
    type,
    amountMinor,
    currencyCode,
    category,
    description,
    occurredAt,
    paymentMethod,
    paymentStatus,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, businessId, idempotencyKey},
  ];
  @override
  CachedTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTransaction(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      businessId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_id'],
          )!,
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      idempotencyKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}idempotency_key'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      amountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_minor'],
          )!,
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      occurredAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}occurred_at'],
          )!,
      paymentMethod:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_method'],
          )!,
      paymentStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payment_status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedTransactionsTable createAlias(String alias) {
    return $CachedTransactionsTable(attachedDatabase, alias);
  }
}

class CachedTransaction extends DataClass
    implements Insertable<CachedTransaction> {
  final String remoteId;
  final String ownerId;
  final String businessId;
  final String createdBy;
  final String idempotencyKey;
  final String type;
  final int amountMinor;
  final String currencyCode;
  final String category;
  final String? description;
  final DateTime occurredAt;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedTransaction({
    required this.remoteId,
    required this.ownerId,
    required this.businessId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.category,
    this.description,
    required this.occurredAt,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['business_id'] = Variable<String>(businessId);
    map['created_by'] = Variable<String>(createdBy);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CachedTransactionsCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      businessId: Value(businessId),
      createdBy: Value(createdBy),
      idempotencyKey: Value(idempotencyKey),
      type: Value(type),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      category: Value(category),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      occurredAt: Value(occurredAt),
      paymentMethod: Value(paymentMethod),
      paymentStatus: Value(paymentStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTransaction(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'businessId': serializer.toJson<String>(businessId),
      'createdBy': serializer.toJson<String>(createdBy),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedTransaction copyWith({
    String? remoteId,
    String? ownerId,
    String? businessId,
    String? createdBy,
    String? idempotencyKey,
    String? type,
    int? amountMinor,
    String? currencyCode,
    String? category,
    Value<String?> description = const Value.absent(),
    DateTime? occurredAt,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedTransaction(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    businessId: businessId ?? this.businessId,
    createdBy: createdBy ?? this.createdBy,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    type: type ?? this.type,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    category: category ?? this.category,
    description: description.present ? description.value : this.description,
    occurredAt: occurredAt ?? this.occurredAt,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedTransaction copyWithCompanion(CachedTransactionsCompanion data) {
    return CachedTransaction(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      idempotencyKey:
          data.idempotencyKey.present
              ? data.idempotencyKey.value
              : this.idempotencyKey,
      type: data.type.present ? data.type.value : this.type,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      paymentStatus:
          data.paymentStatus.present
              ? data.paymentStatus.value
              : this.paymentStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTransaction(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    businessId,
    createdBy,
    idempotencyKey,
    type,
    amountMinor,
    currencyCode,
    category,
    description,
    occurredAt,
    paymentMethod,
    paymentStatus,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTransaction &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.businessId == this.businessId &&
          other.createdBy == this.createdBy &&
          other.idempotencyKey == this.idempotencyKey &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.category == this.category &&
          other.description == this.description &&
          other.occurredAt == this.occurredAt &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentStatus == this.paymentStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedTransactionsCompanion extends UpdateCompanion<CachedTransaction> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> businessId;
  final Value<String> createdBy;
  final Value<String> idempotencyKey;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> category;
  final Value<String?> description;
  final Value<DateTime> occurredAt;
  final Value<String> paymentMethod;
  final Value<String> paymentStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedTransactionsCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTransactionsCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String businessId,
    required String createdBy,
    required String idempotencyKey,
    required String type,
    required int amountMinor,
    required String currencyCode,
    required String category,
    this.description = const Value.absent(),
    required DateTime occurredAt,
    required String paymentMethod,
    required String paymentStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       businessId = Value(businessId),
       createdBy = Value(createdBy),
       idempotencyKey = Value(idempotencyKey),
       type = Value(type),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       category = Value(category),
       occurredAt = Value(occurredAt),
       paymentMethod = Value(paymentMethod),
       paymentStatus = Value(paymentStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedTransaction> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? businessId,
    Expression<String>? createdBy,
    Expression<String>? idempotencyKey,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? category,
    Expression<String>? description,
    Expression<DateTime>? occurredAt,
    Expression<String>? paymentMethod,
    Expression<String>? paymentStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (businessId != null) 'business_id': businessId,
      if (createdBy != null) 'created_by': createdBy,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTransactionsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? businessId,
    Value<String>? createdBy,
    Value<String>? idempotencyKey,
    Value<String>? type,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? category,
    Value<String?>? description,
    Value<DateTime>? occurredAt,
    Value<String>? paymentMethod,
    Value<String>? paymentStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedTransactionsCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      businessId: businessId ?? this.businessId,
      createdBy: createdBy ?? this.createdBy,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTransactionsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedObligationsTable extends CachedObligations
    with TableInfo<$CachedObligationsTable, CachedObligation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedObligationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<DateTime> dueOn = GeneratedColumn<DateTime>(
    'due_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedTransactionIdMeta =
      const VerificationMeta('recordedTransactionId');
  @override
  late final GeneratedColumn<String> recordedTransactionId =
      GeneratedColumn<String>(
        'recorded_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    businessId,
    createdBy,
    idempotencyKey,
    title,
    amountMinor,
    currencyCode,
    dueOn,
    status,
    category,
    notes,
    recordedTransactionId,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_obligations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedObligation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    } else if (isInserting) {
      context.missing(_dueOnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('recorded_transaction_id')) {
      context.handle(
        _recordedTransactionIdMeta,
        recordedTransactionId.isAcceptableOrUnknown(
          data['recorded_transaction_id']!,
          _recordedTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, businessId, idempotencyKey},
  ];
  @override
  CachedObligation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedObligation(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      businessId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_id'],
          )!,
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      idempotencyKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}idempotency_key'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      amountMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount_minor'],
          )!,
      currencyCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}currency_code'],
          )!,
      dueOn:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}due_on'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      recordedTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_transaction_id'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedObligationsTable createAlias(String alias) {
    return $CachedObligationsTable(attachedDatabase, alias);
  }
}

class CachedObligation extends DataClass
    implements Insertable<CachedObligation> {
  final String remoteId;
  final String ownerId;
  final String businessId;
  final String createdBy;
  final String idempotencyKey;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final DateTime dueOn;
  final String status;
  final String category;
  final String? notes;
  final String? recordedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedObligation({
    required this.remoteId,
    required this.ownerId,
    required this.businessId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.dueOn,
    required this.status,
    required this.category,
    this.notes,
    this.recordedTransactionId,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['business_id'] = Variable<String>(businessId);
    map['created_by'] = Variable<String>(createdBy);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['title'] = Variable<String>(title);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['due_on'] = Variable<DateTime>(dueOn);
    map['status'] = Variable<String>(status);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || recordedTransactionId != null) {
      map['recorded_transaction_id'] = Variable<String>(recordedTransactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedObligationsCompanion toCompanion(bool nullToAbsent) {
    return CachedObligationsCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      businessId: Value(businessId),
      createdBy: Value(createdBy),
      idempotencyKey: Value(idempotencyKey),
      title: Value(title),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      dueOn: Value(dueOn),
      status: Value(status),
      category: Value(category),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recordedTransactionId:
          recordedTransactionId == null && nullToAbsent
              ? const Value.absent()
              : Value(recordedTransactionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedObligation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedObligation(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      title: serializer.fromJson<String>(json['title']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      dueOn: serializer.fromJson<DateTime>(json['dueOn']),
      status: serializer.fromJson<String>(json['status']),
      category: serializer.fromJson<String>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      recordedTransactionId: serializer.fromJson<String?>(
        json['recordedTransactionId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'businessId': serializer.toJson<String>(businessId),
      'createdBy': serializer.toJson<String>(createdBy),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'title': serializer.toJson<String>(title),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'dueOn': serializer.toJson<DateTime>(dueOn),
      'status': serializer.toJson<String>(status),
      'category': serializer.toJson<String>(category),
      'notes': serializer.toJson<String?>(notes),
      'recordedTransactionId': serializer.toJson<String?>(
        recordedTransactionId,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedObligation copyWith({
    String? remoteId,
    String? ownerId,
    String? businessId,
    String? createdBy,
    String? idempotencyKey,
    String? title,
    int? amountMinor,
    String? currencyCode,
    DateTime? dueOn,
    String? status,
    String? category,
    Value<String?> notes = const Value.absent(),
    Value<String?> recordedTransactionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedObligation(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    businessId: businessId ?? this.businessId,
    createdBy: createdBy ?? this.createdBy,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    title: title ?? this.title,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    dueOn: dueOn ?? this.dueOn,
    status: status ?? this.status,
    category: category ?? this.category,
    notes: notes.present ? notes.value : this.notes,
    recordedTransactionId:
        recordedTransactionId.present
            ? recordedTransactionId.value
            : this.recordedTransactionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedObligation copyWithCompanion(CachedObligationsCompanion data) {
    return CachedObligation(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      idempotencyKey:
          data.idempotencyKey.present
              ? data.idempotencyKey.value
              : this.idempotencyKey,
      title: data.title.present ? data.title.value : this.title,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currencyCode:
          data.currencyCode.present
              ? data.currencyCode.value
              : this.currencyCode,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      recordedTransactionId:
          data.recordedTransactionId.present
              ? data.recordedTransactionId.value
              : this.recordedTransactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedObligation(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('recordedTransactionId: $recordedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    businessId,
    createdBy,
    idempotencyKey,
    title,
    amountMinor,
    currencyCode,
    dueOn,
    status,
    category,
    notes,
    recordedTransactionId,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedObligation &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.businessId == this.businessId &&
          other.createdBy == this.createdBy &&
          other.idempotencyKey == this.idempotencyKey &&
          other.title == this.title &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.dueOn == this.dueOn &&
          other.status == this.status &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.recordedTransactionId == this.recordedTransactionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedObligationsCompanion extends UpdateCompanion<CachedObligation> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> businessId;
  final Value<String> createdBy;
  final Value<String> idempotencyKey;
  final Value<String> title;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<DateTime> dueOn;
  final Value<String> status;
  final Value<String> category;
  final Value<String?> notes;
  final Value<String?> recordedTransactionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedObligationsCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.title = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordedTransactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedObligationsCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String businessId,
    required String createdBy,
    required String idempotencyKey,
    required String title,
    required int amountMinor,
    required String currencyCode,
    required DateTime dueOn,
    required String status,
    required String category,
    this.notes = const Value.absent(),
    this.recordedTransactionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       businessId = Value(businessId),
       createdBy = Value(createdBy),
       idempotencyKey = Value(idempotencyKey),
       title = Value(title),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       dueOn = Value(dueOn),
       status = Value(status),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedObligation> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? businessId,
    Expression<String>? createdBy,
    Expression<String>? idempotencyKey,
    Expression<String>? title,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? dueOn,
    Expression<String>? status,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<String>? recordedTransactionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (businessId != null) 'business_id': businessId,
      if (createdBy != null) 'created_by': createdBy,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (title != null) 'title': title,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (dueOn != null) 'due_on': dueOn,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (recordedTransactionId != null)
        'recorded_transaction_id': recordedTransactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedObligationsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? businessId,
    Value<String>? createdBy,
    Value<String>? idempotencyKey,
    Value<String>? title,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<DateTime>? dueOn,
    Value<String>? status,
    Value<String>? category,
    Value<String?>? notes,
    Value<String?>? recordedTransactionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedObligationsCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      businessId: businessId ?? this.businessId,
      createdBy: createdBy ?? this.createdBy,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      title: title ?? this.title,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      dueOn: dueOn ?? this.dueOn,
      status: status ?? this.status,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      recordedTransactionId:
          recordedTransactionId ?? this.recordedTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<DateTime>(dueOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recordedTransactionId.present) {
      map['recorded_transaction_id'] = Variable<String>(
        recordedTransactionId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedObligationsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('title: $title, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('recordedTransactionId: $recordedTransactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedProductsTable extends CachedProducts
    with TableInfo<$CachedProductsTable, CachedProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellingPriceMinorMeta = const VerificationMeta(
    'sellingPriceMinor',
  );
  @override
  late final GeneratedColumn<int> sellingPriceMinor = GeneratedColumn<int>(
    'selling_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta(
    'unitCostMinor',
  );
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockQuantityMilliMeta =
      const VerificationMeta('stockQuantityMilli');
  @override
  late final GeneratedColumn<int> stockQuantityMilli = GeneratedColumn<int>(
    'stock_quantity_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowStockThresholdMilliMeta =
      const VerificationMeta('lowStockThresholdMilli');
  @override
  late final GeneratedColumn<int> lowStockThresholdMilli = GeneratedColumn<int>(
    'low_stock_threshold_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitOfMeasureMeta = const VerificationMeta(
    'unitOfMeasure',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasure = GeneratedColumn<String>(
    'unit_of_measure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    businessId,
    createdBy,
    name,
    sku,
    description,
    sellingPriceMinor,
    unitCostMinor,
    stockQuantityMilli,
    lowStockThresholdMilli,
    unitOfMeasure,
    isActive,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('selling_price_minor')) {
      context.handle(
        _sellingPriceMinorMeta,
        sellingPriceMinor.isAcceptableOrUnknown(
          data['selling_price_minor']!,
          _sellingPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMinorMeta);
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(
          data['unit_cost_minor']!,
          _unitCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('stock_quantity_milli')) {
      context.handle(
        _stockQuantityMilliMeta,
        stockQuantityMilli.isAcceptableOrUnknown(
          data['stock_quantity_milli']!,
          _stockQuantityMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockQuantityMilliMeta);
    }
    if (data.containsKey('low_stock_threshold_milli')) {
      context.handle(
        _lowStockThresholdMilliMeta,
        lowStockThresholdMilli.isAcceptableOrUnknown(
          data['low_stock_threshold_milli']!,
          _lowStockThresholdMilliMeta,
        ),
      );
    }
    if (data.containsKey('unit_of_measure')) {
      context.handle(
        _unitOfMeasureMeta,
        unitOfMeasure.isAcceptableOrUnknown(
          data['unit_of_measure']!,
          _unitOfMeasureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitOfMeasureMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  CachedProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProduct(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      businessId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_id'],
          )!,
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sellingPriceMinor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}selling_price_minor'],
          )!,
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      ),
      stockQuantityMilli:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}stock_quantity_milli'],
          )!,
      lowStockThresholdMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold_milli'],
      ),
      unitOfMeasure:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}unit_of_measure'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedProductsTable createAlias(String alias) {
    return $CachedProductsTable(attachedDatabase, alias);
  }
}

class CachedProduct extends DataClass implements Insertable<CachedProduct> {
  final String remoteId;
  final String ownerId;
  final String businessId;
  final String createdBy;
  final String name;
  final String? sku;
  final String? description;
  final int sellingPriceMinor;
  final int? unitCostMinor;
  final int stockQuantityMilli;
  final int? lowStockThresholdMilli;
  final String unitOfMeasure;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedProduct({
    required this.remoteId,
    required this.ownerId,
    required this.businessId,
    required this.createdBy,
    required this.name,
    this.sku,
    this.description,
    required this.sellingPriceMinor,
    this.unitCostMinor,
    required this.stockQuantityMilli,
    this.lowStockThresholdMilli,
    required this.unitOfMeasure,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['business_id'] = Variable<String>(businessId);
    map['created_by'] = Variable<String>(createdBy);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['selling_price_minor'] = Variable<int>(sellingPriceMinor);
    if (!nullToAbsent || unitCostMinor != null) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    }
    map['stock_quantity_milli'] = Variable<int>(stockQuantityMilli);
    if (!nullToAbsent || lowStockThresholdMilli != null) {
      map['low_stock_threshold_milli'] = Variable<int>(lowStockThresholdMilli);
    }
    map['unit_of_measure'] = Variable<String>(unitOfMeasure);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedProductsCompanion toCompanion(bool nullToAbsent) {
    return CachedProductsCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      businessId: Value(businessId),
      createdBy: Value(createdBy),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      sellingPriceMinor: Value(sellingPriceMinor),
      unitCostMinor:
          unitCostMinor == null && nullToAbsent
              ? const Value.absent()
              : Value(unitCostMinor),
      stockQuantityMilli: Value(stockQuantityMilli),
      lowStockThresholdMilli:
          lowStockThresholdMilli == null && nullToAbsent
              ? const Value.absent()
              : Value(lowStockThresholdMilli),
      unitOfMeasure: Value(unitOfMeasure),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProduct(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      description: serializer.fromJson<String?>(json['description']),
      sellingPriceMinor: serializer.fromJson<int>(json['sellingPriceMinor']),
      unitCostMinor: serializer.fromJson<int?>(json['unitCostMinor']),
      stockQuantityMilli: serializer.fromJson<int>(json['stockQuantityMilli']),
      lowStockThresholdMilli: serializer.fromJson<int?>(
        json['lowStockThresholdMilli'],
      ),
      unitOfMeasure: serializer.fromJson<String>(json['unitOfMeasure']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'businessId': serializer.toJson<String>(businessId),
      'createdBy': serializer.toJson<String>(createdBy),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'description': serializer.toJson<String?>(description),
      'sellingPriceMinor': serializer.toJson<int>(sellingPriceMinor),
      'unitCostMinor': serializer.toJson<int?>(unitCostMinor),
      'stockQuantityMilli': serializer.toJson<int>(stockQuantityMilli),
      'lowStockThresholdMilli': serializer.toJson<int?>(lowStockThresholdMilli),
      'unitOfMeasure': serializer.toJson<String>(unitOfMeasure),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedProduct copyWith({
    String? remoteId,
    String? ownerId,
    String? businessId,
    String? createdBy,
    String? name,
    Value<String?> sku = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? sellingPriceMinor,
    Value<int?> unitCostMinor = const Value.absent(),
    int? stockQuantityMilli,
    Value<int?> lowStockThresholdMilli = const Value.absent(),
    String? unitOfMeasure,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedProduct(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    businessId: businessId ?? this.businessId,
    createdBy: createdBy ?? this.createdBy,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    description: description.present ? description.value : this.description,
    sellingPriceMinor: sellingPriceMinor ?? this.sellingPriceMinor,
    unitCostMinor:
        unitCostMinor.present ? unitCostMinor.value : this.unitCostMinor,
    stockQuantityMilli: stockQuantityMilli ?? this.stockQuantityMilli,
    lowStockThresholdMilli:
        lowStockThresholdMilli.present
            ? lowStockThresholdMilli.value
            : this.lowStockThresholdMilli,
    unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedProduct copyWithCompanion(CachedProductsCompanion data) {
    return CachedProduct(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      description:
          data.description.present ? data.description.value : this.description,
      sellingPriceMinor:
          data.sellingPriceMinor.present
              ? data.sellingPriceMinor.value
              : this.sellingPriceMinor,
      unitCostMinor:
          data.unitCostMinor.present
              ? data.unitCostMinor.value
              : this.unitCostMinor,
      stockQuantityMilli:
          data.stockQuantityMilli.present
              ? data.stockQuantityMilli.value
              : this.stockQuantityMilli,
      lowStockThresholdMilli:
          data.lowStockThresholdMilli.present
              ? data.lowStockThresholdMilli.value
              : this.lowStockThresholdMilli,
      unitOfMeasure:
          data.unitOfMeasure.present
              ? data.unitOfMeasure.value
              : this.unitOfMeasure,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProduct(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('sellingPriceMinor: $sellingPriceMinor, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('stockQuantityMilli: $stockQuantityMilli, ')
          ..write('lowStockThresholdMilli: $lowStockThresholdMilli, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    businessId,
    createdBy,
    name,
    sku,
    description,
    sellingPriceMinor,
    unitCostMinor,
    stockQuantityMilli,
    lowStockThresholdMilli,
    unitOfMeasure,
    isActive,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProduct &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.businessId == this.businessId &&
          other.createdBy == this.createdBy &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.description == this.description &&
          other.sellingPriceMinor == this.sellingPriceMinor &&
          other.unitCostMinor == this.unitCostMinor &&
          other.stockQuantityMilli == this.stockQuantityMilli &&
          other.lowStockThresholdMilli == this.lowStockThresholdMilli &&
          other.unitOfMeasure == this.unitOfMeasure &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedProductsCompanion extends UpdateCompanion<CachedProduct> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> businessId;
  final Value<String> createdBy;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> description;
  final Value<int> sellingPriceMinor;
  final Value<int?> unitCostMinor;
  final Value<int> stockQuantityMilli;
  final Value<int?> lowStockThresholdMilli;
  final Value<String> unitOfMeasure;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedProductsCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.description = const Value.absent(),
    this.sellingPriceMinor = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.stockQuantityMilli = const Value.absent(),
    this.lowStockThresholdMilli = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProductsCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String businessId,
    required String createdBy,
    required String name,
    this.sku = const Value.absent(),
    this.description = const Value.absent(),
    required int sellingPriceMinor,
    this.unitCostMinor = const Value.absent(),
    required int stockQuantityMilli,
    this.lowStockThresholdMilli = const Value.absent(),
    required String unitOfMeasure,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       businessId = Value(businessId),
       createdBy = Value(createdBy),
       name = Value(name),
       sellingPriceMinor = Value(sellingPriceMinor),
       stockQuantityMilli = Value(stockQuantityMilli),
       unitOfMeasure = Value(unitOfMeasure),
       isActive = Value(isActive),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedProduct> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? businessId,
    Expression<String>? createdBy,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? description,
    Expression<int>? sellingPriceMinor,
    Expression<int>? unitCostMinor,
    Expression<int>? stockQuantityMilli,
    Expression<int>? lowStockThresholdMilli,
    Expression<String>? unitOfMeasure,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (businessId != null) 'business_id': businessId,
      if (createdBy != null) 'created_by': createdBy,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (description != null) 'description': description,
      if (sellingPriceMinor != null) 'selling_price_minor': sellingPriceMinor,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (stockQuantityMilli != null)
        'stock_quantity_milli': stockQuantityMilli,
      if (lowStockThresholdMilli != null)
        'low_stock_threshold_milli': lowStockThresholdMilli,
      if (unitOfMeasure != null) 'unit_of_measure': unitOfMeasure,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProductsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? businessId,
    Value<String>? createdBy,
    Value<String>? name,
    Value<String?>? sku,
    Value<String?>? description,
    Value<int>? sellingPriceMinor,
    Value<int?>? unitCostMinor,
    Value<int>? stockQuantityMilli,
    Value<int?>? lowStockThresholdMilli,
    Value<String>? unitOfMeasure,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedProductsCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      businessId: businessId ?? this.businessId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      sellingPriceMinor: sellingPriceMinor ?? this.sellingPriceMinor,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      stockQuantityMilli: stockQuantityMilli ?? this.stockQuantityMilli,
      lowStockThresholdMilli:
          lowStockThresholdMilli ?? this.lowStockThresholdMilli,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sellingPriceMinor.present) {
      map['selling_price_minor'] = Variable<int>(sellingPriceMinor.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (stockQuantityMilli.present) {
      map['stock_quantity_milli'] = Variable<int>(stockQuantityMilli.value);
    }
    if (lowStockThresholdMilli.present) {
      map['low_stock_threshold_milli'] = Variable<int>(
        lowStockThresholdMilli.value,
      );
    }
    if (unitOfMeasure.present) {
      map['unit_of_measure'] = Variable<String>(unitOfMeasure.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProductsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('description: $description, ')
          ..write('sellingPriceMinor: $sellingPriceMinor, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('stockQuantityMilli: $stockQuantityMilli, ')
          ..write('lowStockThresholdMilli: $lowStockThresholdMilli, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedStockMovementsTable extends CachedStockMovements
    with TableInfo<$CachedStockMovementsTable, CachedStockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMilliMeta = const VerificationMeta(
    'quantityMilli',
  );
  @override
  late final GeneratedColumn<int> quantityMilli = GeneratedColumn<int>(
    'quantity_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityDeltaMilliMeta =
      const VerificationMeta('quantityDeltaMilli');
  @override
  late final GeneratedColumn<int> quantityDeltaMilli = GeneratedColumn<int>(
    'quantity_delta_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultingQuantityMilliMeta =
      const VerificationMeta('resultingQuantityMilli');
  @override
  late final GeneratedColumn<int> resultingQuantityMilli = GeneratedColumn<int>(
    'resulting_quantity_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorMeta = const VerificationMeta(
    'unitCostMinor',
  );
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
    'unit_cost_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesMovementIdMeta =
      const VerificationMeta('reversesMovementId');
  @override
  late final GeneratedColumn<String> reversesMovementId =
      GeneratedColumn<String>(
        'reverses_movement_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    businessId,
    productId,
    createdBy,
    idempotencyKey,
    movementType,
    quantityMilli,
    quantityDeltaMilli,
    resultingQuantityMilli,
    unitCostMinor,
    reason,
    notes,
    reference,
    transactionId,
    reversesMovementId,
    createdAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedStockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity_milli')) {
      context.handle(
        _quantityMilliMeta,
        quantityMilli.isAcceptableOrUnknown(
          data['quantity_milli']!,
          _quantityMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliMeta);
    }
    if (data.containsKey('quantity_delta_milli')) {
      context.handle(
        _quantityDeltaMilliMeta,
        quantityDeltaMilli.isAcceptableOrUnknown(
          data['quantity_delta_milli']!,
          _quantityDeltaMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityDeltaMilliMeta);
    }
    if (data.containsKey('resulting_quantity_milli')) {
      context.handle(
        _resultingQuantityMilliMeta,
        resultingQuantityMilli.isAcceptableOrUnknown(
          data['resulting_quantity_milli']!,
          _resultingQuantityMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resultingQuantityMilliMeta);
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
        _unitCostMinorMeta,
        unitCostMinor.isAcceptableOrUnknown(
          data['unit_cost_minor']!,
          _unitCostMinorMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('reverses_movement_id')) {
      context.handle(
        _reversesMovementIdMeta,
        reversesMovementId.isAcceptableOrUnknown(
          data['reverses_movement_id']!,
          _reversesMovementIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, businessId, idempotencyKey},
  ];
  @override
  CachedStockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedStockMovement(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      businessId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_id'],
          )!,
      productId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}product_id'],
          )!,
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      idempotencyKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}idempotency_key'],
          )!,
      movementType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}movement_type'],
          )!,
      quantityMilli:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}quantity_milli'],
          )!,
      quantityDeltaMilli:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}quantity_delta_milli'],
          )!,
      resultingQuantityMilli:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}resulting_quantity_milli'],
          )!,
      unitCostMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      reversesMovementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_movement_id'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedStockMovementsTable createAlias(String alias) {
    return $CachedStockMovementsTable(attachedDatabase, alias);
  }
}

class CachedStockMovement extends DataClass
    implements Insertable<CachedStockMovement> {
  final String remoteId;
  final String ownerId;
  final String businessId;
  final String productId;
  final String createdBy;
  final String idempotencyKey;
  final String movementType;
  final int quantityMilli;
  final int quantityDeltaMilli;
  final int resultingQuantityMilli;
  final int? unitCostMinor;
  final String? reason;
  final String? notes;
  final String? reference;
  final String? transactionId;
  final String? reversesMovementId;
  final DateTime createdAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedStockMovement({
    required this.remoteId,
    required this.ownerId,
    required this.businessId,
    required this.productId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.movementType,
    required this.quantityMilli,
    required this.quantityDeltaMilli,
    required this.resultingQuantityMilli,
    this.unitCostMinor,
    this.reason,
    this.notes,
    this.reference,
    this.transactionId,
    this.reversesMovementId,
    required this.createdAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['business_id'] = Variable<String>(businessId);
    map['product_id'] = Variable<String>(productId);
    map['created_by'] = Variable<String>(createdBy);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity_milli'] = Variable<int>(quantityMilli);
    map['quantity_delta_milli'] = Variable<int>(quantityDeltaMilli);
    map['resulting_quantity_milli'] = Variable<int>(resultingQuantityMilli);
    if (!nullToAbsent || unitCostMinor != null) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || reversesMovementId != null) {
      map['reverses_movement_id'] = Variable<String>(reversesMovementId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return CachedStockMovementsCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      businessId: Value(businessId),
      productId: Value(productId),
      createdBy: Value(createdBy),
      idempotencyKey: Value(idempotencyKey),
      movementType: Value(movementType),
      quantityMilli: Value(quantityMilli),
      quantityDeltaMilli: Value(quantityDeltaMilli),
      resultingQuantityMilli: Value(resultingQuantityMilli),
      unitCostMinor:
          unitCostMinor == null && nullToAbsent
              ? const Value.absent()
              : Value(unitCostMinor),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      reference:
          reference == null && nullToAbsent
              ? const Value.absent()
              : Value(reference),
      transactionId:
          transactionId == null && nullToAbsent
              ? const Value.absent()
              : Value(transactionId),
      reversesMovementId:
          reversesMovementId == null && nullToAbsent
              ? const Value.absent()
              : Value(reversesMovementId),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedStockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedStockMovement(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      productId: serializer.fromJson<String>(json['productId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantityMilli: serializer.fromJson<int>(json['quantityMilli']),
      quantityDeltaMilli: serializer.fromJson<int>(json['quantityDeltaMilli']),
      resultingQuantityMilli: serializer.fromJson<int>(
        json['resultingQuantityMilli'],
      ),
      unitCostMinor: serializer.fromJson<int?>(json['unitCostMinor']),
      reason: serializer.fromJson<String?>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
      reference: serializer.fromJson<String?>(json['reference']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      reversesMovementId: serializer.fromJson<String?>(
        json['reversesMovementId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'businessId': serializer.toJson<String>(businessId),
      'productId': serializer.toJson<String>(productId),
      'createdBy': serializer.toJson<String>(createdBy),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'movementType': serializer.toJson<String>(movementType),
      'quantityMilli': serializer.toJson<int>(quantityMilli),
      'quantityDeltaMilli': serializer.toJson<int>(quantityDeltaMilli),
      'resultingQuantityMilli': serializer.toJson<int>(resultingQuantityMilli),
      'unitCostMinor': serializer.toJson<int?>(unitCostMinor),
      'reason': serializer.toJson<String?>(reason),
      'notes': serializer.toJson<String?>(notes),
      'reference': serializer.toJson<String?>(reference),
      'transactionId': serializer.toJson<String?>(transactionId),
      'reversesMovementId': serializer.toJson<String?>(reversesMovementId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedStockMovement copyWith({
    String? remoteId,
    String? ownerId,
    String? businessId,
    String? productId,
    String? createdBy,
    String? idempotencyKey,
    String? movementType,
    int? quantityMilli,
    int? quantityDeltaMilli,
    int? resultingQuantityMilli,
    Value<int?> unitCostMinor = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> transactionId = const Value.absent(),
    Value<String?> reversesMovementId = const Value.absent(),
    DateTime? createdAt,
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedStockMovement(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    businessId: businessId ?? this.businessId,
    productId: productId ?? this.productId,
    createdBy: createdBy ?? this.createdBy,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    movementType: movementType ?? this.movementType,
    quantityMilli: quantityMilli ?? this.quantityMilli,
    quantityDeltaMilli: quantityDeltaMilli ?? this.quantityDeltaMilli,
    resultingQuantityMilli:
        resultingQuantityMilli ?? this.resultingQuantityMilli,
    unitCostMinor:
        unitCostMinor.present ? unitCostMinor.value : this.unitCostMinor,
    reason: reason.present ? reason.value : this.reason,
    notes: notes.present ? notes.value : this.notes,
    reference: reference.present ? reference.value : this.reference,
    transactionId:
        transactionId.present ? transactionId.value : this.transactionId,
    reversesMovementId:
        reversesMovementId.present
            ? reversesMovementId.value
            : this.reversesMovementId,
    createdAt: createdAt ?? this.createdAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedStockMovement copyWithCompanion(CachedStockMovementsCompanion data) {
    return CachedStockMovement(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      productId: data.productId.present ? data.productId.value : this.productId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      idempotencyKey:
          data.idempotencyKey.present
              ? data.idempotencyKey.value
              : this.idempotencyKey,
      movementType:
          data.movementType.present
              ? data.movementType.value
              : this.movementType,
      quantityMilli:
          data.quantityMilli.present
              ? data.quantityMilli.value
              : this.quantityMilli,
      quantityDeltaMilli:
          data.quantityDeltaMilli.present
              ? data.quantityDeltaMilli.value
              : this.quantityDeltaMilli,
      resultingQuantityMilli:
          data.resultingQuantityMilli.present
              ? data.resultingQuantityMilli.value
              : this.resultingQuantityMilli,
      unitCostMinor:
          data.unitCostMinor.present
              ? data.unitCostMinor.value
              : this.unitCostMinor,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
      reference: data.reference.present ? data.reference.value : this.reference,
      transactionId:
          data.transactionId.present
              ? data.transactionId.value
              : this.transactionId,
      reversesMovementId:
          data.reversesMovementId.present
              ? data.reversesMovementId.value
              : this.reversesMovementId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedStockMovement(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('movementType: $movementType, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('quantityDeltaMilli: $quantityDeltaMilli, ')
          ..write('resultingQuantityMilli: $resultingQuantityMilli, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('reference: $reference, ')
          ..write('transactionId: $transactionId, ')
          ..write('reversesMovementId: $reversesMovementId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    businessId,
    productId,
    createdBy,
    idempotencyKey,
    movementType,
    quantityMilli,
    quantityDeltaMilli,
    resultingQuantityMilli,
    unitCostMinor,
    reason,
    notes,
    reference,
    transactionId,
    reversesMovementId,
    createdAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedStockMovement &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.businessId == this.businessId &&
          other.productId == this.productId &&
          other.createdBy == this.createdBy &&
          other.idempotencyKey == this.idempotencyKey &&
          other.movementType == this.movementType &&
          other.quantityMilli == this.quantityMilli &&
          other.quantityDeltaMilli == this.quantityDeltaMilli &&
          other.resultingQuantityMilli == this.resultingQuantityMilli &&
          other.unitCostMinor == this.unitCostMinor &&
          other.reason == this.reason &&
          other.notes == this.notes &&
          other.reference == this.reference &&
          other.transactionId == this.transactionId &&
          other.reversesMovementId == this.reversesMovementId &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedStockMovementsCompanion
    extends UpdateCompanion<CachedStockMovement> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> businessId;
  final Value<String> productId;
  final Value<String> createdBy;
  final Value<String> idempotencyKey;
  final Value<String> movementType;
  final Value<int> quantityMilli;
  final Value<int> quantityDeltaMilli;
  final Value<int> resultingQuantityMilli;
  final Value<int?> unitCostMinor;
  final Value<String?> reason;
  final Value<String?> notes;
  final Value<String?> reference;
  final Value<String?> transactionId;
  final Value<String?> reversesMovementId;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedStockMovementsCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.productId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantityMilli = const Value.absent(),
    this.quantityDeltaMilli = const Value.absent(),
    this.resultingQuantityMilli = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.reference = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.reversesMovementId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedStockMovementsCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String businessId,
    required String productId,
    required String createdBy,
    required String idempotencyKey,
    required String movementType,
    required int quantityMilli,
    required int quantityDeltaMilli,
    required int resultingQuantityMilli,
    this.unitCostMinor = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.reference = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.reversesMovementId = const Value.absent(),
    required DateTime createdAt,
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       businessId = Value(businessId),
       productId = Value(productId),
       createdBy = Value(createdBy),
       idempotencyKey = Value(idempotencyKey),
       movementType = Value(movementType),
       quantityMilli = Value(quantityMilli),
       quantityDeltaMilli = Value(quantityDeltaMilli),
       resultingQuantityMilli = Value(resultingQuantityMilli),
       createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedStockMovement> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? businessId,
    Expression<String>? productId,
    Expression<String>? createdBy,
    Expression<String>? idempotencyKey,
    Expression<String>? movementType,
    Expression<int>? quantityMilli,
    Expression<int>? quantityDeltaMilli,
    Expression<int>? resultingQuantityMilli,
    Expression<int>? unitCostMinor,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<String>? reference,
    Expression<String>? transactionId,
    Expression<String>? reversesMovementId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (businessId != null) 'business_id': businessId,
      if (productId != null) 'product_id': productId,
      if (createdBy != null) 'created_by': createdBy,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (movementType != null) 'movement_type': movementType,
      if (quantityMilli != null) 'quantity_milli': quantityMilli,
      if (quantityDeltaMilli != null)
        'quantity_delta_milli': quantityDeltaMilli,
      if (resultingQuantityMilli != null)
        'resulting_quantity_milli': resultingQuantityMilli,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (reference != null) 'reference': reference,
      if (transactionId != null) 'transaction_id': transactionId,
      if (reversesMovementId != null)
        'reverses_movement_id': reversesMovementId,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedStockMovementsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? businessId,
    Value<String>? productId,
    Value<String>? createdBy,
    Value<String>? idempotencyKey,
    Value<String>? movementType,
    Value<int>? quantityMilli,
    Value<int>? quantityDeltaMilli,
    Value<int>? resultingQuantityMilli,
    Value<int?>? unitCostMinor,
    Value<String?>? reason,
    Value<String?>? notes,
    Value<String?>? reference,
    Value<String?>? transactionId,
    Value<String?>? reversesMovementId,
    Value<DateTime>? createdAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedStockMovementsCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      businessId: businessId ?? this.businessId,
      productId: productId ?? this.productId,
      createdBy: createdBy ?? this.createdBy,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      movementType: movementType ?? this.movementType,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      quantityDeltaMilli: quantityDeltaMilli ?? this.quantityDeltaMilli,
      resultingQuantityMilli:
          resultingQuantityMilli ?? this.resultingQuantityMilli,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      transactionId: transactionId ?? this.transactionId,
      reversesMovementId: reversesMovementId ?? this.reversesMovementId,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantityMilli.present) {
      map['quantity_milli'] = Variable<int>(quantityMilli.value);
    }
    if (quantityDeltaMilli.present) {
      map['quantity_delta_milli'] = Variable<int>(quantityDeltaMilli.value);
    }
    if (resultingQuantityMilli.present) {
      map['resulting_quantity_milli'] = Variable<int>(
        resultingQuantityMilli.value,
      );
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (reversesMovementId.present) {
      map['reverses_movement_id'] = Variable<String>(reversesMovementId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedStockMovementsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('createdBy: $createdBy, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('movementType: $movementType, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('quantityDeltaMilli: $quantityDeltaMilli, ')
          ..write('resultingQuantityMilli: $resultingQuantityMilli, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('reference: $reference, ')
          ..write('transactionId: $transactionId, ')
          ..write('reversesMovementId: $reversesMovementId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecommendationsTable extends CachedRecommendations
    with TableInfo<$CachedRecommendationsTable, CachedRecommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleKeyMeta = const VerificationMeta(
    'ruleKey',
  );
  @override
  late final GeneratedColumn<String> ruleKey = GeneratedColumn<String>(
    'rule_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionKeyMeta = const VerificationMeta(
    'conditionKey',
  );
  @override
  late final GeneratedColumn<String> conditionKey = GeneratedColumn<String>(
    'condition_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    ownerId,
    businessId,
    createdBy,
    ruleKey,
    conditionKey,
    status,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recommendations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRecommendation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('rule_key')) {
      context.handle(
        _ruleKeyMeta,
        ruleKey.isAcceptableOrUnknown(data['rule_key']!, _ruleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleKeyMeta);
    }
    if (data.containsKey('condition_key')) {
      context.handle(
        _conditionKeyMeta,
        conditionKey.isAcceptableOrUnknown(
          data['condition_key']!,
          _conditionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {remoteId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, businessId, ruleKey},
  ];
  @override
  CachedRecommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecommendation(
      remoteId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remote_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      businessId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}business_id'],
          )!,
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      ruleKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}rule_key'],
          )!,
      conditionKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}condition_key'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CachedRecommendationsTable createAlias(String alias) {
    return $CachedRecommendationsTable(attachedDatabase, alias);
  }
}

class CachedRecommendation extends DataClass
    implements Insertable<CachedRecommendation> {
  final String remoteId;
  final String ownerId;
  final String businessId;
  final String createdBy;
  final String ruleKey;
  final String conditionKey;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final String syncStatus;
  const CachedRecommendation({
    required this.remoteId,
    required this.ownerId,
    required this.businessId,
    required this.createdBy,
    required this.ruleKey,
    required this.conditionKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.cachedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['remote_id'] = Variable<String>(remoteId);
    map['owner_id'] = Variable<String>(ownerId);
    map['business_id'] = Variable<String>(businessId);
    map['created_by'] = Variable<String>(createdBy);
    map['rule_key'] = Variable<String>(ruleKey);
    map['condition_key'] = Variable<String>(conditionKey);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedRecommendationsCompanion toCompanion(bool nullToAbsent) {
    return CachedRecommendationsCompanion(
      remoteId: Value(remoteId),
      ownerId: Value(ownerId),
      businessId: Value(businessId),
      createdBy: Value(createdBy),
      ruleKey: Value(ruleKey),
      conditionKey: Value(conditionKey),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedRecommendation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecommendation(
      remoteId: serializer.fromJson<String>(json['remoteId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      ruleKey: serializer.fromJson<String>(json['ruleKey']),
      conditionKey: serializer.fromJson<String>(json['conditionKey']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String>(remoteId),
      'ownerId': serializer.toJson<String>(ownerId),
      'businessId': serializer.toJson<String>(businessId),
      'createdBy': serializer.toJson<String>(createdBy),
      'ruleKey': serializer.toJson<String>(ruleKey),
      'conditionKey': serializer.toJson<String>(conditionKey),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedRecommendation copyWith({
    String? remoteId,
    String? ownerId,
    String? businessId,
    String? createdBy,
    String? ruleKey,
    String? conditionKey,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cachedAt,
    String? syncStatus,
  }) => CachedRecommendation(
    remoteId: remoteId ?? this.remoteId,
    ownerId: ownerId ?? this.ownerId,
    businessId: businessId ?? this.businessId,
    createdBy: createdBy ?? this.createdBy,
    ruleKey: ruleKey ?? this.ruleKey,
    conditionKey: conditionKey ?? this.conditionKey,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cachedAt: cachedAt ?? this.cachedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedRecommendation copyWithCompanion(CachedRecommendationsCompanion data) {
    return CachedRecommendation(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      ruleKey: data.ruleKey.present ? data.ruleKey.value : this.ruleKey,
      conditionKey:
          data.conditionKey.present
              ? data.conditionKey.value
              : this.conditionKey,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecommendation(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('conditionKey: $conditionKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    ownerId,
    businessId,
    createdBy,
    ruleKey,
    conditionKey,
    status,
    createdAt,
    updatedAt,
    cachedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecommendation &&
          other.remoteId == this.remoteId &&
          other.ownerId == this.ownerId &&
          other.businessId == this.businessId &&
          other.createdBy == this.createdBy &&
          other.ruleKey == this.ruleKey &&
          other.conditionKey == this.conditionKey &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedRecommendationsCompanion
    extends UpdateCompanion<CachedRecommendation> {
  final Value<String> remoteId;
  final Value<String> ownerId;
  final Value<String> businessId;
  final Value<String> createdBy;
  final Value<String> ruleKey;
  final Value<String> conditionKey;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedRecommendationsCompanion({
    this.remoteId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.ruleKey = const Value.absent(),
    this.conditionKey = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecommendationsCompanion.insert({
    required String remoteId,
    required String ownerId,
    required String businessId,
    required String createdBy,
    required String ruleKey,
    required String conditionKey,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime cachedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : remoteId = Value(remoteId),
       ownerId = Value(ownerId),
       businessId = Value(businessId),
       createdBy = Value(createdBy),
       ruleKey = Value(ruleKey),
       conditionKey = Value(conditionKey),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedRecommendation> custom({
    Expression<String>? remoteId,
    Expression<String>? ownerId,
    Expression<String>? businessId,
    Expression<String>? createdBy,
    Expression<String>? ruleKey,
    Expression<String>? conditionKey,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (ownerId != null) 'owner_id': ownerId,
      if (businessId != null) 'business_id': businessId,
      if (createdBy != null) 'created_by': createdBy,
      if (ruleKey != null) 'rule_key': ruleKey,
      if (conditionKey != null) 'condition_key': conditionKey,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecommendationsCompanion copyWith({
    Value<String>? remoteId,
    Value<String>? ownerId,
    Value<String>? businessId,
    Value<String>? createdBy,
    Value<String>? ruleKey,
    Value<String>? conditionKey,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? cachedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedRecommendationsCompanion(
      remoteId: remoteId ?? this.remoteId,
      ownerId: ownerId ?? this.ownerId,
      businessId: businessId ?? this.businessId,
      createdBy: createdBy ?? this.createdBy,
      ruleKey: ruleKey ?? this.ruleKey,
      conditionKey: conditionKey ?? this.conditionKey,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (ruleKey.present) {
      map['rule_key'] = Variable<String>(ruleKey.value);
    }
    if (conditionKey.present) {
      map['condition_key'] = Variable<String>(conditionKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecommendationsCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('ownerId: $ownerId, ')
          ..write('businessId: $businessId, ')
          ..write('createdBy: $createdBy, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('conditionKey: $conditionKey, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$KgweboDatabase extends GeneratedDatabase {
  _$KgweboDatabase(QueryExecutor e) : super(e);
  $KgweboDatabaseManager get managers => $KgweboDatabaseManager(this);
  late final $CachedBusinessesTable cachedBusinesses = $CachedBusinessesTable(
    this,
  );
  late final $CachedTransactionsTable cachedTransactions =
      $CachedTransactionsTable(this);
  late final $CachedObligationsTable cachedObligations =
      $CachedObligationsTable(this);
  late final $CachedProductsTable cachedProducts = $CachedProductsTable(this);
  late final $CachedStockMovementsTable cachedStockMovements =
      $CachedStockMovementsTable(this);
  late final $CachedRecommendationsTable cachedRecommendations =
      $CachedRecommendationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedBusinesses,
    cachedTransactions,
    cachedObligations,
    cachedProducts,
    cachedStockMovements,
    cachedRecommendations,
  ];
}

typedef $$CachedBusinessesTableCreateCompanionBuilder =
    CachedBusinessesCompanion Function({
      required String remoteId,
      required String ownerId,
      required String name,
      required String businessType,
      required String countryCode,
      required String currencyCode,
      required int openingBalanceMinor,
      Value<String?> description,
      Value<String?> startedOn,
      Value<String?> contactPhone,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedBusinessesTableUpdateCompanionBuilder =
    CachedBusinessesCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> name,
      Value<String> businessType,
      Value<String> countryCode,
      Value<String> currencyCode,
      Value<int> openingBalanceMinor,
      Value<String?> description,
      Value<String?> startedOn,
      Value<String?> contactPhone,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedBusinessesTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedBusinessesTable> {
  $$CachedBusinessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBusinessesTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedBusinessesTable> {
  $$CachedBusinessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBusinessesTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedBusinessesTable> {
  $$CachedBusinessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedBusinessesTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedBusinessesTable,
          CachedBusinessesData,
          $$CachedBusinessesTableFilterComposer,
          $$CachedBusinessesTableOrderingComposer,
          $$CachedBusinessesTableAnnotationComposer,
          $$CachedBusinessesTableCreateCompanionBuilder,
          $$CachedBusinessesTableUpdateCompanionBuilder,
          (
            CachedBusinessesData,
            BaseReferences<
              _$KgweboDatabase,
              $CachedBusinessesTable,
              CachedBusinessesData
            >,
          ),
          CachedBusinessesData,
          PrefetchHooks Function()
        > {
  $$CachedBusinessesTableTableManager(
    _$KgweboDatabase db,
    $CachedBusinessesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CachedBusinessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedBusinessesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CachedBusinessesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> businessType = const Value.absent(),
                Value<String> countryCode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> openingBalanceMinor = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> startedOn = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBusinessesCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                name: name,
                businessType: businessType,
                countryCode: countryCode,
                currencyCode: currencyCode,
                openingBalanceMinor: openingBalanceMinor,
                description: description,
                startedOn: startedOn,
                contactPhone: contactPhone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String name,
                required String businessType,
                required String countryCode,
                required String currencyCode,
                required int openingBalanceMinor,
                Value<String?> description = const Value.absent(),
                Value<String?> startedOn = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBusinessesCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                name: name,
                businessType: businessType,
                countryCode: countryCode,
                currencyCode: currencyCode,
                openingBalanceMinor: openingBalanceMinor,
                description: description,
                startedOn: startedOn,
                contactPhone: contactPhone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBusinessesTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedBusinessesTable,
      CachedBusinessesData,
      $$CachedBusinessesTableFilterComposer,
      $$CachedBusinessesTableOrderingComposer,
      $$CachedBusinessesTableAnnotationComposer,
      $$CachedBusinessesTableCreateCompanionBuilder,
      $$CachedBusinessesTableUpdateCompanionBuilder,
      (
        CachedBusinessesData,
        BaseReferences<
          _$KgweboDatabase,
          $CachedBusinessesTable,
          CachedBusinessesData
        >,
      ),
      CachedBusinessesData,
      PrefetchHooks Function()
    >;
typedef $$CachedTransactionsTableCreateCompanionBuilder =
    CachedTransactionsCompanion Function({
      required String remoteId,
      required String ownerId,
      required String businessId,
      required String createdBy,
      required String idempotencyKey,
      required String type,
      required int amountMinor,
      required String currencyCode,
      required String category,
      Value<String?> description,
      required DateTime occurredAt,
      required String paymentMethod,
      required String paymentStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedTransactionsTableUpdateCompanionBuilder =
    CachedTransactionsCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> businessId,
      Value<String> createdBy,
      Value<String> idempotencyKey,
      Value<String> type,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> category,
      Value<String?> description,
      Value<DateTime> occurredAt,
      Value<String> paymentMethod,
      Value<String> paymentStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedTransactionsTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedTransactionsTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTransactionsTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedTransactionsTable> {
  $$CachedTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedTransactionsTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedTransactionsTable,
          CachedTransaction,
          $$CachedTransactionsTableFilterComposer,
          $$CachedTransactionsTableOrderingComposer,
          $$CachedTransactionsTableAnnotationComposer,
          $$CachedTransactionsTableCreateCompanionBuilder,
          $$CachedTransactionsTableUpdateCompanionBuilder,
          (
            CachedTransaction,
            BaseReferences<
              _$KgweboDatabase,
              $CachedTransactionsTable,
              CachedTransaction
            >,
          ),
          CachedTransaction,
          PrefetchHooks Function()
        > {
  $$CachedTransactionsTableTableManager(
    _$KgweboDatabase db,
    $CachedTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CachedTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CachedTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTransactionsCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                type: type,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                category: category,
                description: description,
                occurredAt: occurredAt,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String businessId,
                required String createdBy,
                required String idempotencyKey,
                required String type,
                required int amountMinor,
                required String currencyCode,
                required String category,
                Value<String?> description = const Value.absent(),
                required DateTime occurredAt,
                required String paymentMethod,
                required String paymentStatus,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTransactionsCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                type: type,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                category: category,
                description: description,
                occurredAt: occurredAt,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedTransactionsTable,
      CachedTransaction,
      $$CachedTransactionsTableFilterComposer,
      $$CachedTransactionsTableOrderingComposer,
      $$CachedTransactionsTableAnnotationComposer,
      $$CachedTransactionsTableCreateCompanionBuilder,
      $$CachedTransactionsTableUpdateCompanionBuilder,
      (
        CachedTransaction,
        BaseReferences<
          _$KgweboDatabase,
          $CachedTransactionsTable,
          CachedTransaction
        >,
      ),
      CachedTransaction,
      PrefetchHooks Function()
    >;
typedef $$CachedObligationsTableCreateCompanionBuilder =
    CachedObligationsCompanion Function({
      required String remoteId,
      required String ownerId,
      required String businessId,
      required String createdBy,
      required String idempotencyKey,
      required String title,
      required int amountMinor,
      required String currencyCode,
      required DateTime dueOn,
      required String status,
      required String category,
      Value<String?> notes,
      Value<String?> recordedTransactionId,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedObligationsTableUpdateCompanionBuilder =
    CachedObligationsCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> businessId,
      Value<String> createdBy,
      Value<String> idempotencyKey,
      Value<String> title,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<DateTime> dueOn,
      Value<String> status,
      Value<String> category,
      Value<String?> notes,
      Value<String?> recordedTransactionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedObligationsTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedObligationsTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedObligationsTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedObligationsTable> {
  $$CachedObligationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get recordedTransactionId => $composableBuilder(
    column: $table.recordedTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedObligationsTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedObligationsTable,
          CachedObligation,
          $$CachedObligationsTableFilterComposer,
          $$CachedObligationsTableOrderingComposer,
          $$CachedObligationsTableAnnotationComposer,
          $$CachedObligationsTableCreateCompanionBuilder,
          $$CachedObligationsTableUpdateCompanionBuilder,
          (
            CachedObligation,
            BaseReferences<
              _$KgweboDatabase,
              $CachedObligationsTable,
              CachedObligation
            >,
          ),
          CachedObligation,
          PrefetchHooks Function()
        > {
  $$CachedObligationsTableTableManager(
    _$KgweboDatabase db,
    $CachedObligationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedObligationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CachedObligationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CachedObligationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> dueOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> recordedTransactionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedObligationsCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                dueOn: dueOn,
                status: status,
                category: category,
                notes: notes,
                recordedTransactionId: recordedTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String businessId,
                required String createdBy,
                required String idempotencyKey,
                required String title,
                required int amountMinor,
                required String currencyCode,
                required DateTime dueOn,
                required String status,
                required String category,
                Value<String?> notes = const Value.absent(),
                Value<String?> recordedTransactionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedObligationsCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                title: title,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                dueOn: dueOn,
                status: status,
                category: category,
                notes: notes,
                recordedTransactionId: recordedTransactionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedObligationsTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedObligationsTable,
      CachedObligation,
      $$CachedObligationsTableFilterComposer,
      $$CachedObligationsTableOrderingComposer,
      $$CachedObligationsTableAnnotationComposer,
      $$CachedObligationsTableCreateCompanionBuilder,
      $$CachedObligationsTableUpdateCompanionBuilder,
      (
        CachedObligation,
        BaseReferences<
          _$KgweboDatabase,
          $CachedObligationsTable,
          CachedObligation
        >,
      ),
      CachedObligation,
      PrefetchHooks Function()
    >;
typedef $$CachedProductsTableCreateCompanionBuilder =
    CachedProductsCompanion Function({
      required String remoteId,
      required String ownerId,
      required String businessId,
      required String createdBy,
      required String name,
      Value<String?> sku,
      Value<String?> description,
      required int sellingPriceMinor,
      Value<int?> unitCostMinor,
      required int stockQuantityMilli,
      Value<int?> lowStockThresholdMilli,
      required String unitOfMeasure,
      required bool isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedProductsTableUpdateCompanionBuilder =
    CachedProductsCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> businessId,
      Value<String> createdBy,
      Value<String> name,
      Value<String?> sku,
      Value<String?> description,
      Value<int> sellingPriceMinor,
      Value<int?> unitCostMinor,
      Value<int> stockQuantityMilli,
      Value<int?> lowStockThresholdMilli,
      Value<String> unitOfMeasure,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedProductsTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedProductsTable> {
  $$CachedProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQuantityMilli => $composableBuilder(
    column: $table.stockQuantityMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProductsTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedProductsTable> {
  $$CachedProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQuantityMilli => $composableBuilder(
    column: $table.stockQuantityMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProductsTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedProductsTable> {
  $$CachedProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQuantityMilli => $composableBuilder(
    column: $table.stockQuantityMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedProductsTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedProductsTable,
          CachedProduct,
          $$CachedProductsTableFilterComposer,
          $$CachedProductsTableOrderingComposer,
          $$CachedProductsTableAnnotationComposer,
          $$CachedProductsTableCreateCompanionBuilder,
          $$CachedProductsTableUpdateCompanionBuilder,
          (
            CachedProduct,
            BaseReferences<
              _$KgweboDatabase,
              $CachedProductsTable,
              CachedProduct
            >,
          ),
          CachedProduct,
          PrefetchHooks Function()
        > {
  $$CachedProductsTableTableManager(
    _$KgweboDatabase db,
    $CachedProductsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CachedProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CachedProductsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sellingPriceMinor = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                Value<int> stockQuantityMilli = const Value.absent(),
                Value<int?> lowStockThresholdMilli = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProductsCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                name: name,
                sku: sku,
                description: description,
                sellingPriceMinor: sellingPriceMinor,
                unitCostMinor: unitCostMinor,
                stockQuantityMilli: stockQuantityMilli,
                lowStockThresholdMilli: lowStockThresholdMilli,
                unitOfMeasure: unitOfMeasure,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String businessId,
                required String createdBy,
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int sellingPriceMinor,
                Value<int?> unitCostMinor = const Value.absent(),
                required int stockQuantityMilli,
                Value<int?> lowStockThresholdMilli = const Value.absent(),
                required String unitOfMeasure,
                required bool isActive,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProductsCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                name: name,
                sku: sku,
                description: description,
                sellingPriceMinor: sellingPriceMinor,
                unitCostMinor: unitCostMinor,
                stockQuantityMilli: stockQuantityMilli,
                lowStockThresholdMilli: lowStockThresholdMilli,
                unitOfMeasure: unitOfMeasure,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedProductsTable,
      CachedProduct,
      $$CachedProductsTableFilterComposer,
      $$CachedProductsTableOrderingComposer,
      $$CachedProductsTableAnnotationComposer,
      $$CachedProductsTableCreateCompanionBuilder,
      $$CachedProductsTableUpdateCompanionBuilder,
      (
        CachedProduct,
        BaseReferences<_$KgweboDatabase, $CachedProductsTable, CachedProduct>,
      ),
      CachedProduct,
      PrefetchHooks Function()
    >;
typedef $$CachedStockMovementsTableCreateCompanionBuilder =
    CachedStockMovementsCompanion Function({
      required String remoteId,
      required String ownerId,
      required String businessId,
      required String productId,
      required String createdBy,
      required String idempotencyKey,
      required String movementType,
      required int quantityMilli,
      required int quantityDeltaMilli,
      required int resultingQuantityMilli,
      Value<int?> unitCostMinor,
      Value<String?> reason,
      Value<String?> notes,
      Value<String?> reference,
      Value<String?> transactionId,
      Value<String?> reversesMovementId,
      required DateTime createdAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedStockMovementsTableUpdateCompanionBuilder =
    CachedStockMovementsCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> businessId,
      Value<String> productId,
      Value<String> createdBy,
      Value<String> idempotencyKey,
      Value<String> movementType,
      Value<int> quantityMilli,
      Value<int> quantityDeltaMilli,
      Value<int> resultingQuantityMilli,
      Value<int?> unitCostMinor,
      Value<String?> reason,
      Value<String?> notes,
      Value<String?> reference,
      Value<String?> transactionId,
      Value<String?> reversesMovementId,
      Value<DateTime> createdAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedStockMovementsTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedStockMovementsTable> {
  $$CachedStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityDeltaMilli => $composableBuilder(
    column: $table.quantityDeltaMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resultingQuantityMilli => $composableBuilder(
    column: $table.resultingQuantityMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesMovementId => $composableBuilder(
    column: $table.reversesMovementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedStockMovementsTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedStockMovementsTable> {
  $$CachedStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityDeltaMilli => $composableBuilder(
    column: $table.quantityDeltaMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resultingQuantityMilli => $composableBuilder(
    column: $table.resultingQuantityMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesMovementId => $composableBuilder(
    column: $table.reversesMovementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedStockMovementsTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedStockMovementsTable> {
  $$CachedStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityDeltaMilli => $composableBuilder(
    column: $table.quantityDeltaMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resultingQuantityMilli => $composableBuilder(
    column: $table.resultingQuantityMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
    column: $table.unitCostMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversesMovementId => $composableBuilder(
    column: $table.reversesMovementId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedStockMovementsTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedStockMovementsTable,
          CachedStockMovement,
          $$CachedStockMovementsTableFilterComposer,
          $$CachedStockMovementsTableOrderingComposer,
          $$CachedStockMovementsTableAnnotationComposer,
          $$CachedStockMovementsTableCreateCompanionBuilder,
          $$CachedStockMovementsTableUpdateCompanionBuilder,
          (
            CachedStockMovement,
            BaseReferences<
              _$KgweboDatabase,
              $CachedStockMovementsTable,
              CachedStockMovement
            >,
          ),
          CachedStockMovement,
          PrefetchHooks Function()
        > {
  $$CachedStockMovementsTableTableManager(
    _$KgweboDatabase db,
    $CachedStockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedStockMovementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CachedStockMovementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CachedStockMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<int> quantityMilli = const Value.absent(),
                Value<int> quantityDeltaMilli = const Value.absent(),
                Value<int> resultingQuantityMilli = const Value.absent(),
                Value<int?> unitCostMinor = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> reversesMovementId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedStockMovementsCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                productId: productId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                movementType: movementType,
                quantityMilli: quantityMilli,
                quantityDeltaMilli: quantityDeltaMilli,
                resultingQuantityMilli: resultingQuantityMilli,
                unitCostMinor: unitCostMinor,
                reason: reason,
                notes: notes,
                reference: reference,
                transactionId: transactionId,
                reversesMovementId: reversesMovementId,
                createdAt: createdAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String businessId,
                required String productId,
                required String createdBy,
                required String idempotencyKey,
                required String movementType,
                required int quantityMilli,
                required int quantityDeltaMilli,
                required int resultingQuantityMilli,
                Value<int?> unitCostMinor = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> reversesMovementId = const Value.absent(),
                required DateTime createdAt,
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedStockMovementsCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                productId: productId,
                createdBy: createdBy,
                idempotencyKey: idempotencyKey,
                movementType: movementType,
                quantityMilli: quantityMilli,
                quantityDeltaMilli: quantityDeltaMilli,
                resultingQuantityMilli: resultingQuantityMilli,
                unitCostMinor: unitCostMinor,
                reason: reason,
                notes: notes,
                reference: reference,
                transactionId: transactionId,
                reversesMovementId: reversesMovementId,
                createdAt: createdAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedStockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedStockMovementsTable,
      CachedStockMovement,
      $$CachedStockMovementsTableFilterComposer,
      $$CachedStockMovementsTableOrderingComposer,
      $$CachedStockMovementsTableAnnotationComposer,
      $$CachedStockMovementsTableCreateCompanionBuilder,
      $$CachedStockMovementsTableUpdateCompanionBuilder,
      (
        CachedStockMovement,
        BaseReferences<
          _$KgweboDatabase,
          $CachedStockMovementsTable,
          CachedStockMovement
        >,
      ),
      CachedStockMovement,
      PrefetchHooks Function()
    >;
typedef $$CachedRecommendationsTableCreateCompanionBuilder =
    CachedRecommendationsCompanion Function({
      required String remoteId,
      required String ownerId,
      required String businessId,
      required String createdBy,
      required String ruleKey,
      required String conditionKey,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      required DateTime cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedRecommendationsTableUpdateCompanionBuilder =
    CachedRecommendationsCompanion Function({
      Value<String> remoteId,
      Value<String> ownerId,
      Value<String> businessId,
      Value<String> createdBy,
      Value<String> ruleKey,
      Value<String> conditionKey,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> cachedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedRecommendationsTableFilterComposer
    extends Composer<_$KgweboDatabase, $CachedRecommendationsTable> {
  $$CachedRecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionKey => $composableBuilder(
    column: $table.conditionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRecommendationsTableOrderingComposer
    extends Composer<_$KgweboDatabase, $CachedRecommendationsTable> {
  $$CachedRecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionKey => $composableBuilder(
    column: $table.conditionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRecommendationsTableAnnotationComposer
    extends Composer<_$KgweboDatabase, $CachedRecommendationsTable> {
  $$CachedRecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get ruleKey =>
      $composableBuilder(column: $table.ruleKey, builder: (column) => column);

  GeneratedColumn<String> get conditionKey => $composableBuilder(
    column: $table.conditionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedRecommendationsTableTableManager
    extends
        RootTableManager<
          _$KgweboDatabase,
          $CachedRecommendationsTable,
          CachedRecommendation,
          $$CachedRecommendationsTableFilterComposer,
          $$CachedRecommendationsTableOrderingComposer,
          $$CachedRecommendationsTableAnnotationComposer,
          $$CachedRecommendationsTableCreateCompanionBuilder,
          $$CachedRecommendationsTableUpdateCompanionBuilder,
          (
            CachedRecommendation,
            BaseReferences<
              _$KgweboDatabase,
              $CachedRecommendationsTable,
              CachedRecommendation
            >,
          ),
          CachedRecommendation,
          PrefetchHooks Function()
        > {
  $$CachedRecommendationsTableTableManager(
    _$KgweboDatabase db,
    $CachedRecommendationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedRecommendationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CachedRecommendationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CachedRecommendationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> remoteId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String> ruleKey = const Value.absent(),
                Value<String> conditionKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRecommendationsCompanion(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                ruleKey: ruleKey,
                conditionKey: conditionKey,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String remoteId,
                required String ownerId,
                required String businessId,
                required String createdBy,
                required String ruleKey,
                required String conditionKey,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                required DateTime cachedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRecommendationsCompanion.insert(
                remoteId: remoteId,
                ownerId: ownerId,
                businessId: businessId,
                createdBy: createdBy,
                ruleKey: ruleKey,
                conditionKey: conditionKey,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cachedAt: cachedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRecommendationsTableProcessedTableManager =
    ProcessedTableManager<
      _$KgweboDatabase,
      $CachedRecommendationsTable,
      CachedRecommendation,
      $$CachedRecommendationsTableFilterComposer,
      $$CachedRecommendationsTableOrderingComposer,
      $$CachedRecommendationsTableAnnotationComposer,
      $$CachedRecommendationsTableCreateCompanionBuilder,
      $$CachedRecommendationsTableUpdateCompanionBuilder,
      (
        CachedRecommendation,
        BaseReferences<
          _$KgweboDatabase,
          $CachedRecommendationsTable,
          CachedRecommendation
        >,
      ),
      CachedRecommendation,
      PrefetchHooks Function()
    >;

class $KgweboDatabaseManager {
  final _$KgweboDatabase _db;
  $KgweboDatabaseManager(this._db);
  $$CachedBusinessesTableTableManager get cachedBusinesses =>
      $$CachedBusinessesTableTableManager(_db, _db.cachedBusinesses);
  $$CachedTransactionsTableTableManager get cachedTransactions =>
      $$CachedTransactionsTableTableManager(_db, _db.cachedTransactions);
  $$CachedObligationsTableTableManager get cachedObligations =>
      $$CachedObligationsTableTableManager(_db, _db.cachedObligations);
  $$CachedProductsTableTableManager get cachedProducts =>
      $$CachedProductsTableTableManager(_db, _db.cachedProducts);
  $$CachedStockMovementsTableTableManager get cachedStockMovements =>
      $$CachedStockMovementsTableTableManager(_db, _db.cachedStockMovements);
  $$CachedRecommendationsTableTableManager get cachedRecommendations =>
      $$CachedRecommendationsTableTableManager(_db, _db.cachedRecommendations);
}
