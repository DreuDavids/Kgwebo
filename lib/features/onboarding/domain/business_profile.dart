class BusinessProfile {
  const BusinessProfile({
    required this.id,
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
  });

  final String id;
  final String ownerId;
  final String name;
  final String businessType;
  final String countryCode;
  final String currencyCode;
  final int openingBalanceMinor;
  final String? description;
  final DateTime? startedOn;
  final String? contactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOnboardingComplete {
    return name.trim().isNotEmpty &&
        businessType.trim().isNotEmpty &&
        countryCode.trim().length == 2 &&
        currencyCode.trim().length == 3;
  }

  bool belongsTo(String ownerId) => this.ownerId == ownerId;

  BusinessProfile copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? businessType,
    String? countryCode,
    String? currencyCode,
    int? openingBalanceMinor,
    String? description,
    DateTime? startedOn,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearStartedOn = false,
    bool clearContactPhone = false,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      description: clearDescription ? null : (description ?? this.description),
      startedOn: clearStartedOn ? null : (startedOn ?? this.startedOn),
      contactPhone:
          clearContactPhone ? null : (contactPhone ?? this.contactPhone),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> row) {
    return BusinessProfile(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      businessType: row['business_type'] as String,
      countryCode: row['country_code'] as String,
      currencyCode: row['currency_code'] as String,
      openingBalanceMinor: (row['opening_balance_minor'] as num).toInt(),
      description: row['description'] as String?,
      startedOn: _parseDate(row['started_on']),
      contactPhone: row['contact_phone'] as String?,
      createdAt: _parseStamp(row['created_at']),
      updatedAt: _parseStamp(row['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is DateTime) {
      return DateTime.utc(raw.year, raw.month, raw.day);
    }
    return DateTime.tryParse(raw as String);
  }

  static DateTime? _parseStamp(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.tryParse(raw as String)?.toUtc();
  }
}
