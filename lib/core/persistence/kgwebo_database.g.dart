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

abstract class _$KgweboDatabase extends GeneratedDatabase {
  _$KgweboDatabase(QueryExecutor e) : super(e);
  $KgweboDatabaseManager get managers => $KgweboDatabaseManager(this);
  late final $CachedBusinessesTable cachedBusinesses = $CachedBusinessesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedBusinesses];
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

class $KgweboDatabaseManager {
  final _$KgweboDatabase _db;
  $KgweboDatabaseManager(this._db);
  $$CachedBusinessesTableTableManager get cachedBusinesses =>
      $$CachedBusinessesTableTableManager(_db, _db.cachedBusinesses);
}
