// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalListsTable extends LocalLists
    with TableInfo<$LocalListsTable, ShoppingListEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shareCodeMeta = const VerificationMeta(
    'shareCode',
  );
  @override
  late final GeneratedColumn<String> shareCode = GeneratedColumn<String>(
    'share_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isJoinedRemoteMeta = const VerificationMeta(
    'isJoinedRemote',
  );
  @override
  late final GeneratedColumn<bool> isJoinedRemote = GeneratedColumn<bool>(
    'is_joined_remote',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_joined_remote" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    ownerId,
    isShared,
    shareCode,
    isJoinedRemote,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('share_code')) {
      context.handle(
        _shareCodeMeta,
        shareCode.isAcceptableOrUnknown(data['share_code']!, _shareCodeMeta),
      );
    }
    if (data.containsKey('is_joined_remote')) {
      context.handle(
        _isJoinedRemoteMeta,
        isJoinedRemote.isAcceptableOrUnknown(
          data['is_joined_remote']!,
          _isJoinedRemoteMeta,
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
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      shareCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_code'],
      ),
      isJoinedRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_joined_remote'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalListsTable createAlias(String alias) {
    return $LocalListsTable(attachedDatabase, alias);
  }
}

class ShoppingListEntity extends DataClass
    implements Insertable<ShoppingListEntity> {
  final String id;
  final String title;
  final String? ownerId;
  final bool isShared;
  final String? shareCode;
  final bool isJoinedRemote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const ShoppingListEntity({
    required this.id,
    required this.title,
    this.ownerId,
    required this.isShared,
    this.shareCode,
    required this.isJoinedRemote,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['is_shared'] = Variable<bool>(isShared);
    if (!nullToAbsent || shareCode != null) {
      map['share_code'] = Variable<String>(shareCode);
    }
    map['is_joined_remote'] = Variable<bool>(isJoinedRemote);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalListsCompanion toCompanion(bool nullToAbsent) {
    return LocalListsCompanion(
      id: Value(id),
      title: Value(title),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      isShared: Value(isShared),
      shareCode: shareCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shareCode),
      isJoinedRemote: Value(isJoinedRemote),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ShoppingListEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListEntity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      shareCode: serializer.fromJson<String?>(json['shareCode']),
      isJoinedRemote: serializer.fromJson<bool>(json['isJoinedRemote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'ownerId': serializer.toJson<String?>(ownerId),
      'isShared': serializer.toJson<bool>(isShared),
      'shareCode': serializer.toJson<String?>(shareCode),
      'isJoinedRemote': serializer.toJson<bool>(isJoinedRemote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ShoppingListEntity copyWith({
    String? id,
    String? title,
    Value<String?> ownerId = const Value.absent(),
    bool? isShared,
    Value<String?> shareCode = const Value.absent(),
    bool? isJoinedRemote,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => ShoppingListEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    isShared: isShared ?? this.isShared,
    shareCode: shareCode.present ? shareCode.value : this.shareCode,
    isJoinedRemote: isJoinedRemote ?? this.isJoinedRemote,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ShoppingListEntity copyWithCompanion(LocalListsCompanion data) {
    return ShoppingListEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      shareCode: data.shareCode.present ? data.shareCode.value : this.shareCode,
      isJoinedRemote: data.isJoinedRemote.present
          ? data.isJoinedRemote.value
          : this.isJoinedRemote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ownerId: $ownerId, ')
          ..write('isShared: $isShared, ')
          ..write('shareCode: $shareCode, ')
          ..write('isJoinedRemote: $isJoinedRemote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    ownerId,
    isShared,
    shareCode,
    isJoinedRemote,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.ownerId == this.ownerId &&
          other.isShared == this.isShared &&
          other.shareCode == this.shareCode &&
          other.isJoinedRemote == this.isJoinedRemote &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalListsCompanion extends UpdateCompanion<ShoppingListEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> ownerId;
  final Value<bool> isShared;
  final Value<String?> shareCode;
  final Value<bool> isJoinedRemote;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalListsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.isJoinedRemote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalListsCompanion.insert({
    required String id,
    required String title,
    this.ownerId = const Value.absent(),
    this.isShared = const Value.absent(),
    this.shareCode = const Value.absent(),
    this.isJoinedRemote = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ShoppingListEntity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? ownerId,
    Expression<bool>? isShared,
    Expression<String>? shareCode,
    Expression<bool>? isJoinedRemote,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (ownerId != null) 'owner_id': ownerId,
      if (isShared != null) 'is_shared': isShared,
      if (shareCode != null) 'share_code': shareCode,
      if (isJoinedRemote != null) 'is_joined_remote': isJoinedRemote,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalListsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? ownerId,
    Value<bool>? isShared,
    Value<String?>? shareCode,
    Value<bool>? isJoinedRemote,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalListsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      isShared: isShared ?? this.isShared,
      shareCode: shareCode ?? this.shareCode,
      isJoinedRemote: isJoinedRemote ?? this.isJoinedRemote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (shareCode.present) {
      map['share_code'] = Variable<String>(shareCode.value);
    }
    if (isJoinedRemote.present) {
      map['is_joined_remote'] = Variable<bool>(isJoinedRemote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    return (StringBuffer('LocalListsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ownerId: $ownerId, ')
          ..write('isShared: $isShared, ')
          ..write('shareCode: $shareCode, ')
          ..write('isJoinedRemote: $isJoinedRemote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalItemsTable extends LocalItems
    with TableInfo<$LocalItemsTable, ShoppingItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cleanNameMeta = const VerificationMeta(
    'cleanName',
  );
  @override
  late final GeneratedColumn<String> cleanName = GeneratedColumn<String>(
    'clean_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('u'),
  );
  static const VerificationMeta _storeCategoryMeta = const VerificationMeta(
    'storeCategory',
  );
  @override
  late final GeneratedColumn<String> storeCategory = GeneratedColumn<String>(
    'store_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aisleNameMeta = const VerificationMeta(
    'aisleName',
  );
  @override
  late final GeneratedColumn<String> aisleName = GeneratedColumn<String>(
    'aisle_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    rawText,
    cleanName,
    quantity,
    unit,
    storeCategory,
    aisleName,
    isChecked,
    price,
    position,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItemEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('clean_name')) {
      context.handle(
        _cleanNameMeta,
        cleanName.isAcceptableOrUnknown(data['clean_name']!, _cleanNameMeta),
      );
    } else if (isInserting) {
      context.missing(_cleanNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('store_category')) {
      context.handle(
        _storeCategoryMeta,
        storeCategory.isAcceptableOrUnknown(
          data['store_category']!,
          _storeCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storeCategoryMeta);
    }
    if (data.containsKey('aisle_name')) {
      context.handle(
        _aisleNameMeta,
        aisleName.isAcceptableOrUnknown(data['aisle_name']!, _aisleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_aisleNameMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      cleanName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clean_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      storeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_category'],
      )!,
      aisleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aisle_name'],
      )!,
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalItemsTable createAlias(String alias) {
    return $LocalItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItemEntity extends DataClass
    implements Insertable<ShoppingItemEntity> {
  final String id;
  final String listId;
  final String rawText;
  final String cleanName;
  final double quantity;
  final String unit;
  final String storeCategory;
  final String aisleName;
  final bool isChecked;
  final double? price;
  final int position;
  final DateTime updatedAt;
  final String syncStatus;
  const ShoppingItemEntity({
    required this.id,
    required this.listId,
    required this.rawText,
    required this.cleanName,
    required this.quantity,
    required this.unit,
    required this.storeCategory,
    required this.aisleName,
    required this.isChecked,
    this.price,
    required this.position,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['raw_text'] = Variable<String>(rawText);
    map['clean_name'] = Variable<String>(cleanName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['store_category'] = Variable<String>(storeCategory);
    map['aisle_name'] = Variable<String>(aisleName);
    map['is_checked'] = Variable<bool>(isChecked);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    map['position'] = Variable<int>(position);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      rawText: Value(rawText),
      cleanName: Value(cleanName),
      quantity: Value(quantity),
      unit: Value(unit),
      storeCategory: Value(storeCategory),
      aisleName: Value(aisleName),
      isChecked: Value(isChecked),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      position: Value(position),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ShoppingItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemEntity(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      rawText: serializer.fromJson<String>(json['rawText']),
      cleanName: serializer.fromJson<String>(json['cleanName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      storeCategory: serializer.fromJson<String>(json['storeCategory']),
      aisleName: serializer.fromJson<String>(json['aisleName']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      price: serializer.fromJson<double?>(json['price']),
      position: serializer.fromJson<int>(json['position']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'rawText': serializer.toJson<String>(rawText),
      'cleanName': serializer.toJson<String>(cleanName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'storeCategory': serializer.toJson<String>(storeCategory),
      'aisleName': serializer.toJson<String>(aisleName),
      'isChecked': serializer.toJson<bool>(isChecked),
      'price': serializer.toJson<double?>(price),
      'position': serializer.toJson<int>(position),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ShoppingItemEntity copyWith({
    String? id,
    String? listId,
    String? rawText,
    String? cleanName,
    double? quantity,
    String? unit,
    String? storeCategory,
    String? aisleName,
    bool? isChecked,
    Value<double?> price = const Value.absent(),
    int? position,
    DateTime? updatedAt,
    String? syncStatus,
  }) => ShoppingItemEntity(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    rawText: rawText ?? this.rawText,
    cleanName: cleanName ?? this.cleanName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    storeCategory: storeCategory ?? this.storeCategory,
    aisleName: aisleName ?? this.aisleName,
    isChecked: isChecked ?? this.isChecked,
    price: price.present ? price.value : this.price,
    position: position ?? this.position,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ShoppingItemEntity copyWithCompanion(LocalItemsCompanion data) {
    return ShoppingItemEntity(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      cleanName: data.cleanName.present ? data.cleanName.value : this.cleanName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      storeCategory: data.storeCategory.present
          ? data.storeCategory.value
          : this.storeCategory,
      aisleName: data.aisleName.present ? data.aisleName.value : this.aisleName,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      price: data.price.present ? data.price.value : this.price,
      position: data.position.present ? data.position.value : this.position,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemEntity(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('rawText: $rawText, ')
          ..write('cleanName: $cleanName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('storeCategory: $storeCategory, ')
          ..write('aisleName: $aisleName, ')
          ..write('isChecked: $isChecked, ')
          ..write('price: $price, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    rawText,
    cleanName,
    quantity,
    unit,
    storeCategory,
    aisleName,
    isChecked,
    price,
    position,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemEntity &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.rawText == this.rawText &&
          other.cleanName == this.cleanName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.storeCategory == this.storeCategory &&
          other.aisleName == this.aisleName &&
          other.isChecked == this.isChecked &&
          other.price == this.price &&
          other.position == this.position &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalItemsCompanion extends UpdateCompanion<ShoppingItemEntity> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> rawText;
  final Value<String> cleanName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<String> storeCategory;
  final Value<String> aisleName;
  final Value<bool> isChecked;
  final Value<double?> price;
  final Value<int> position;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.rawText = const Value.absent(),
    this.cleanName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.storeCategory = const Value.absent(),
    this.aisleName = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.price = const Value.absent(),
    this.position = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalItemsCompanion.insert({
    required String id,
    required String listId,
    required String rawText,
    required String cleanName,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    required String storeCategory,
    required String aisleName,
    this.isChecked = const Value.absent(),
    this.price = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       rawText = Value(rawText),
       cleanName = Value(cleanName),
       storeCategory = Value(storeCategory),
       aisleName = Value(aisleName),
       updatedAt = Value(updatedAt);
  static Insertable<ShoppingItemEntity> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? rawText,
    Expression<String>? cleanName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? storeCategory,
    Expression<String>? aisleName,
    Expression<bool>? isChecked,
    Expression<double>? price,
    Expression<int>? position,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (rawText != null) 'raw_text': rawText,
      if (cleanName != null) 'clean_name': cleanName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (storeCategory != null) 'store_category': storeCategory,
      if (aisleName != null) 'aisle_name': aisleName,
      if (isChecked != null) 'is_checked': isChecked,
      if (price != null) 'price': price,
      if (position != null) 'position': position,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? rawText,
    Value<String>? cleanName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<String>? storeCategory,
    Value<String>? aisleName,
    Value<bool>? isChecked,
    Value<double?>? price,
    Value<int>? position,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      rawText: rawText ?? this.rawText,
      cleanName: cleanName ?? this.cleanName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storeCategory: storeCategory ?? this.storeCategory,
      aisleName: aisleName ?? this.aisleName,
      isChecked: isChecked ?? this.isChecked,
      price: price ?? this.price,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (cleanName.present) {
      map['clean_name'] = Variable<String>(cleanName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (storeCategory.present) {
      map['store_category'] = Variable<String>(storeCategory.value);
    }
    if (aisleName.present) {
      map['aisle_name'] = Variable<String>(aisleName.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    return (StringBuffer('LocalItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('rawText: $rawText, ')
          ..write('cleanName: $cleanName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('storeCategory: $storeCategory, ')
          ..write('aisleName: $aisleName, ')
          ..write('isChecked: $isChecked, ')
          ..write('price: $price, ')
          ..write('position: $position, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAisleOrderTable extends LocalAisleOrder
    with TableInfo<$LocalAisleOrderTable, AisleOrderEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAisleOrderTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storeCategoryMeta = const VerificationMeta(
    'storeCategory',
  );
  @override
  late final GeneratedColumn<String> storeCategory = GeneratedColumn<String>(
    'store_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aisleNameMeta = const VerificationMeta(
    'aisleName',
  );
  @override
  late final GeneratedColumn<String> aisleName = GeneratedColumn<String>(
    'aisle_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    defaultValue: const Constant('seeded'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    storeCategory,
    aisleName,
    sortOrder,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_aisle_order';
  @override
  VerificationContext validateIntegrity(
    Insertable<AisleOrderEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('store_category')) {
      context.handle(
        _storeCategoryMeta,
        storeCategory.isAcceptableOrUnknown(
          data['store_category']!,
          _storeCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storeCategoryMeta);
    }
    if (data.containsKey('aisle_name')) {
      context.handle(
        _aisleNameMeta,
        aisleName.isAcceptableOrUnknown(data['aisle_name']!, _aisleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_aisleNameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {storeCategory, aisleName};
  @override
  AisleOrderEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AisleOrderEntity(
      storeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_category'],
      )!,
      aisleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aisle_name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalAisleOrderTable createAlias(String alias) {
    return $LocalAisleOrderTable(attachedDatabase, alias);
  }
}

class AisleOrderEntity extends DataClass
    implements Insertable<AisleOrderEntity> {
  final String storeCategory;
  final String aisleName;
  final int sortOrder;
  final DateTime? updatedAt;
  final String syncStatus;
  const AisleOrderEntity({
    required this.storeCategory,
    required this.aisleName,
    required this.sortOrder,
    this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['store_category'] = Variable<String>(storeCategory);
    map['aisle_name'] = Variable<String>(aisleName);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalAisleOrderCompanion toCompanion(bool nullToAbsent) {
    return LocalAisleOrderCompanion(
      storeCategory: Value(storeCategory),
      aisleName: Value(aisleName),
      sortOrder: Value(sortOrder),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory AisleOrderEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AisleOrderEntity(
      storeCategory: serializer.fromJson<String>(json['storeCategory']),
      aisleName: serializer.fromJson<String>(json['aisleName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storeCategory': serializer.toJson<String>(storeCategory),
      'aisleName': serializer.toJson<String>(aisleName),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  AisleOrderEntity copyWith({
    String? storeCategory,
    String? aisleName,
    int? sortOrder,
    Value<DateTime?> updatedAt = const Value.absent(),
    String? syncStatus,
  }) => AisleOrderEntity(
    storeCategory: storeCategory ?? this.storeCategory,
    aisleName: aisleName ?? this.aisleName,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  AisleOrderEntity copyWithCompanion(LocalAisleOrderCompanion data) {
    return AisleOrderEntity(
      storeCategory: data.storeCategory.present
          ? data.storeCategory.value
          : this.storeCategory,
      aisleName: data.aisleName.present ? data.aisleName.value : this.aisleName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AisleOrderEntity(')
          ..write('storeCategory: $storeCategory, ')
          ..write('aisleName: $aisleName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(storeCategory, aisleName, sortOrder, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AisleOrderEntity &&
          other.storeCategory == this.storeCategory &&
          other.aisleName == this.aisleName &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalAisleOrderCompanion extends UpdateCompanion<AisleOrderEntity> {
  final Value<String> storeCategory;
  final Value<String> aisleName;
  final Value<int> sortOrder;
  final Value<DateTime?> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalAisleOrderCompanion({
    this.storeCategory = const Value.absent(),
    this.aisleName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAisleOrderCompanion.insert({
    required String storeCategory,
    required String aisleName,
    required int sortOrder,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : storeCategory = Value(storeCategory),
       aisleName = Value(aisleName),
       sortOrder = Value(sortOrder);
  static Insertable<AisleOrderEntity> custom({
    Expression<String>? storeCategory,
    Expression<String>? aisleName,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storeCategory != null) 'store_category': storeCategory,
      if (aisleName != null) 'aisle_name': aisleName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAisleOrderCompanion copyWith({
    Value<String>? storeCategory,
    Value<String>? aisleName,
    Value<int>? sortOrder,
    Value<DateTime?>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalAisleOrderCompanion(
      storeCategory: storeCategory ?? this.storeCategory,
      aisleName: aisleName ?? this.aisleName,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storeCategory.present) {
      map['store_category'] = Variable<String>(storeCategory.value);
    }
    if (aisleName.present) {
      map['aisle_name'] = Variable<String>(aisleName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    return (StringBuffer('LocalAisleOrderCompanion(')
          ..write('storeCategory: $storeCategory, ')
          ..write('aisleName: $aisleName, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLearnedItemsTable extends LocalLearnedItems
    with TableInfo<$LocalLearnedItemsTable, LearnedItemEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLearnedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredStoreMeta = const VerificationMeta(
    'preferredStore',
  );
  @override
  late final GeneratedColumn<String> preferredStore = GeneratedColumn<String>(
    'preferred_store',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredAisleMeta = const VerificationMeta(
    'preferredAisle',
  );
  @override
  late final GeneratedColumn<String> preferredAisle = GeneratedColumn<String>(
    'preferred_aisle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _useCountMeta = const VerificationMeta(
    'useCount',
  );
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
    'use_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    normalizedName,
    displayName,
    preferredStore,
    preferredAisle,
    useCount,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_learned_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnedItemEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('preferred_store')) {
      context.handle(
        _preferredStoreMeta,
        preferredStore.isAcceptableOrUnknown(
          data['preferred_store']!,
          _preferredStoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredStoreMeta);
    }
    if (data.containsKey('preferred_aisle')) {
      context.handle(
        _preferredAisleMeta,
        preferredAisle.isAcceptableOrUnknown(
          data['preferred_aisle']!,
          _preferredAisleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredAisleMeta);
    }
    if (data.containsKey('use_count')) {
      context.handle(
        _useCountMeta,
        useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {normalizedName};
  @override
  LearnedItemEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedItemEntity(
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      preferredStore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_store'],
      )!,
      preferredAisle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_aisle'],
      )!,
      useCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalLearnedItemsTable createAlias(String alias) {
    return $LocalLearnedItemsTable(attachedDatabase, alias);
  }
}

class LearnedItemEntity extends DataClass
    implements Insertable<LearnedItemEntity> {
  final String normalizedName;
  final String? displayName;
  final String preferredStore;
  final String preferredAisle;
  final int useCount;
  final DateTime updatedAt;
  final String syncStatus;
  const LearnedItemEntity({
    required this.normalizedName,
    this.displayName,
    required this.preferredStore,
    required this.preferredAisle,
    required this.useCount,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['preferred_store'] = Variable<String>(preferredStore);
    map['preferred_aisle'] = Variable<String>(preferredAisle);
    map['use_count'] = Variable<int>(useCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalLearnedItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalLearnedItemsCompanion(
      normalizedName: Value(normalizedName),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      preferredStore: Value(preferredStore),
      preferredAisle: Value(preferredAisle),
      useCount: Value(useCount),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LearnedItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedItemEntity(
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      preferredStore: serializer.fromJson<String>(json['preferredStore']),
      preferredAisle: serializer.fromJson<String>(json['preferredAisle']),
      useCount: serializer.fromJson<int>(json['useCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedName': serializer.toJson<String>(normalizedName),
      'displayName': serializer.toJson<String?>(displayName),
      'preferredStore': serializer.toJson<String>(preferredStore),
      'preferredAisle': serializer.toJson<String>(preferredAisle),
      'useCount': serializer.toJson<int>(useCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LearnedItemEntity copyWith({
    String? normalizedName,
    Value<String?> displayName = const Value.absent(),
    String? preferredStore,
    String? preferredAisle,
    int? useCount,
    DateTime? updatedAt,
    String? syncStatus,
  }) => LearnedItemEntity(
    normalizedName: normalizedName ?? this.normalizedName,
    displayName: displayName.present ? displayName.value : this.displayName,
    preferredStore: preferredStore ?? this.preferredStore,
    preferredAisle: preferredAisle ?? this.preferredAisle,
    useCount: useCount ?? this.useCount,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LearnedItemEntity copyWithCompanion(LocalLearnedItemsCompanion data) {
    return LearnedItemEntity(
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      preferredStore: data.preferredStore.present
          ? data.preferredStore.value
          : this.preferredStore,
      preferredAisle: data.preferredAisle.present
          ? data.preferredAisle.value
          : this.preferredAisle,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedItemEntity(')
          ..write('normalizedName: $normalizedName, ')
          ..write('displayName: $displayName, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('preferredAisle: $preferredAisle, ')
          ..write('useCount: $useCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    normalizedName,
    displayName,
    preferredStore,
    preferredAisle,
    useCount,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedItemEntity &&
          other.normalizedName == this.normalizedName &&
          other.displayName == this.displayName &&
          other.preferredStore == this.preferredStore &&
          other.preferredAisle == this.preferredAisle &&
          other.useCount == this.useCount &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalLearnedItemsCompanion extends UpdateCompanion<LearnedItemEntity> {
  final Value<String> normalizedName;
  final Value<String?> displayName;
  final Value<String> preferredStore;
  final Value<String> preferredAisle;
  final Value<int> useCount;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalLearnedItemsCompanion({
    this.normalizedName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.preferredStore = const Value.absent(),
    this.preferredAisle = const Value.absent(),
    this.useCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLearnedItemsCompanion.insert({
    required String normalizedName,
    this.displayName = const Value.absent(),
    required String preferredStore,
    required String preferredAisle,
    this.useCount = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : normalizedName = Value(normalizedName),
       preferredStore = Value(preferredStore),
       preferredAisle = Value(preferredAisle),
       updatedAt = Value(updatedAt);
  static Insertable<LearnedItemEntity> custom({
    Expression<String>? normalizedName,
    Expression<String>? displayName,
    Expression<String>? preferredStore,
    Expression<String>? preferredAisle,
    Expression<int>? useCount,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (displayName != null) 'display_name': displayName,
      if (preferredStore != null) 'preferred_store': preferredStore,
      if (preferredAisle != null) 'preferred_aisle': preferredAisle,
      if (useCount != null) 'use_count': useCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLearnedItemsCompanion copyWith({
    Value<String>? normalizedName,
    Value<String?>? displayName,
    Value<String>? preferredStore,
    Value<String>? preferredAisle,
    Value<int>? useCount,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalLearnedItemsCompanion(
      normalizedName: normalizedName ?? this.normalizedName,
      displayName: displayName ?? this.displayName,
      preferredStore: preferredStore ?? this.preferredStore,
      preferredAisle: preferredAisle ?? this.preferredAisle,
      useCount: useCount ?? this.useCount,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (preferredStore.present) {
      map['preferred_store'] = Variable<String>(preferredStore.value);
    }
    if (preferredAisle.present) {
      map['preferred_aisle'] = Variable<String>(preferredAisle.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
    return (StringBuffer('LocalLearnedItemsCompanion(')
          ..write('normalizedName: $normalizedName, ')
          ..write('displayName: $displayName, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('preferredAisle: $preferredAisle, ')
          ..write('useCount: $useCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPreferencesTable extends LocalPreferences
    with TableInfo<$LocalPreferencesTable, UserPreferencesEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(StoreHierarchy.defaultCity),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keepScreenOnMeta = const VerificationMeta(
    'keepScreenOn',
  );
  @override
  late final GeneratedColumn<bool> keepScreenOn = GeneratedColumn<bool>(
    'keep_screen_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_screen_on" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _avatarChoiceMeta = const VerificationMeta(
    'avatarChoice',
  );
  @override
  late final GeneratedColumn<String> avatarChoice = GeneratedColumn<String>(
    'avatar_choice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('avatar_1'),
  );
  static const VerificationMeta _googlePhotoUrlMeta = const VerificationMeta(
    'googlePhotoUrl',
  );
  @override
  late final GeneratedColumn<String> googlePhotoUrl = GeneratedColumn<String>(
    'google_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planTierMeta = const VerificationMeta(
    'planTier',
  );
  @override
  late final GeneratedColumn<String> planTier = GeneratedColumn<String>(
    'plan_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _freeMaxListsMeta = const VerificationMeta(
    'freeMaxLists',
  );
  @override
  late final GeneratedColumn<int> freeMaxLists = GeneratedColumn<int>(
    'free_max_lists',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _basicMaxListsMeta = const VerificationMeta(
    'basicMaxLists',
  );
  @override
  late final GeneratedColumn<int> basicMaxLists = GeneratedColumn<int>(
    'basic_max_lists',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _proMaxListsMeta = const VerificationMeta(
    'proMaxLists',
  );
  @override
  late final GeneratedColumn<int> proMaxLists = GeneratedColumn<int>(
    'pro_max_lists',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(999),
  );
  static const VerificationMeta _monthlyBudgetArsMeta = const VerificationMeta(
    'monthlyBudgetArs',
  );
  @override
  late final GeneratedColumn<double> monthlyBudgetArs = GeneratedColumn<double>(
    'monthly_budget_ars',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    city,
    themeMode,
    onboardingCompleted,
    keepScreenOn,
    soundEnabled,
    vibrationEnabled,
    avatarChoice,
    googlePhotoUrl,
    planTier,
    freeMaxLists,
    basicMaxLists,
    proMaxLists,
    monthlyBudgetArs,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferencesEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('keep_screen_on')) {
      context.handle(
        _keepScreenOnMeta,
        keepScreenOn.isAcceptableOrUnknown(
          data['keep_screen_on']!,
          _keepScreenOnMeta,
        ),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('avatar_choice')) {
      context.handle(
        _avatarChoiceMeta,
        avatarChoice.isAcceptableOrUnknown(
          data['avatar_choice']!,
          _avatarChoiceMeta,
        ),
      );
    }
    if (data.containsKey('google_photo_url')) {
      context.handle(
        _googlePhotoUrlMeta,
        googlePhotoUrl.isAcceptableOrUnknown(
          data['google_photo_url']!,
          _googlePhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('plan_tier')) {
      context.handle(
        _planTierMeta,
        planTier.isAcceptableOrUnknown(data['plan_tier']!, _planTierMeta),
      );
    }
    if (data.containsKey('free_max_lists')) {
      context.handle(
        _freeMaxListsMeta,
        freeMaxLists.isAcceptableOrUnknown(
          data['free_max_lists']!,
          _freeMaxListsMeta,
        ),
      );
    }
    if (data.containsKey('basic_max_lists')) {
      context.handle(
        _basicMaxListsMeta,
        basicMaxLists.isAcceptableOrUnknown(
          data['basic_max_lists']!,
          _basicMaxListsMeta,
        ),
      );
    }
    if (data.containsKey('pro_max_lists')) {
      context.handle(
        _proMaxListsMeta,
        proMaxLists.isAcceptableOrUnknown(
          data['pro_max_lists']!,
          _proMaxListsMeta,
        ),
      );
    }
    if (data.containsKey('monthly_budget_ars')) {
      context.handle(
        _monthlyBudgetArsMeta,
        monthlyBudgetArs.isAcceptableOrUnknown(
          data['monthly_budget_ars']!,
          _monthlyBudgetArsMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreferencesEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferencesEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      keepScreenOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_screen_on'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
      avatarChoice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_choice'],
      )!,
      googlePhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}google_photo_url'],
      ),
      planTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_tier'],
      )!,
      freeMaxLists: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}free_max_lists'],
      )!,
      basicMaxLists: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}basic_max_lists'],
      )!,
      proMaxLists: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pro_max_lists'],
      )!,
      monthlyBudgetArs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget_ars'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalPreferencesTable createAlias(String alias) {
    return $LocalPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreferencesEntity extends DataClass
    implements Insertable<UserPreferencesEntity> {
  final int id;
  final String city;
  final String themeMode;
  final bool onboardingCompleted;
  final bool keepScreenOn;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String avatarChoice;
  final String? googlePhotoUrl;
  final String planTier;
  final int freeMaxLists;
  final int basicMaxLists;
  final int proMaxLists;
  final double? monthlyBudgetArs;
  final DateTime? lastSyncedAt;
  const UserPreferencesEntity({
    required this.id,
    required this.city,
    required this.themeMode,
    required this.onboardingCompleted,
    required this.keepScreenOn,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.avatarChoice,
    this.googlePhotoUrl,
    required this.planTier,
    required this.freeMaxLists,
    required this.basicMaxLists,
    required this.proMaxLists,
    this.monthlyBudgetArs,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city'] = Variable<String>(city);
    map['theme_mode'] = Variable<String>(themeMode);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['keep_screen_on'] = Variable<bool>(keepScreenOn);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    map['avatar_choice'] = Variable<String>(avatarChoice);
    if (!nullToAbsent || googlePhotoUrl != null) {
      map['google_photo_url'] = Variable<String>(googlePhotoUrl);
    }
    map['plan_tier'] = Variable<String>(planTier);
    map['free_max_lists'] = Variable<int>(freeMaxLists);
    map['basic_max_lists'] = Variable<int>(basicMaxLists);
    map['pro_max_lists'] = Variable<int>(proMaxLists);
    if (!nullToAbsent || monthlyBudgetArs != null) {
      map['monthly_budget_ars'] = Variable<double>(monthlyBudgetArs);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalPreferencesCompanion toCompanion(bool nullToAbsent) {
    return LocalPreferencesCompanion(
      id: Value(id),
      city: Value(city),
      themeMode: Value(themeMode),
      onboardingCompleted: Value(onboardingCompleted),
      keepScreenOn: Value(keepScreenOn),
      soundEnabled: Value(soundEnabled),
      vibrationEnabled: Value(vibrationEnabled),
      avatarChoice: Value(avatarChoice),
      googlePhotoUrl: googlePhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(googlePhotoUrl),
      planTier: Value(planTier),
      freeMaxLists: Value(freeMaxLists),
      basicMaxLists: Value(basicMaxLists),
      proMaxLists: Value(proMaxLists),
      monthlyBudgetArs: monthlyBudgetArs == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyBudgetArs),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserPreferencesEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferencesEntity(
      id: serializer.fromJson<int>(json['id']),
      city: serializer.fromJson<String>(json['city']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      keepScreenOn: serializer.fromJson<bool>(json['keepScreenOn']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
      avatarChoice: serializer.fromJson<String>(json['avatarChoice']),
      googlePhotoUrl: serializer.fromJson<String?>(json['googlePhotoUrl']),
      planTier: serializer.fromJson<String>(json['planTier']),
      freeMaxLists: serializer.fromJson<int>(json['freeMaxLists']),
      basicMaxLists: serializer.fromJson<int>(json['basicMaxLists']),
      proMaxLists: serializer.fromJson<int>(json['proMaxLists']),
      monthlyBudgetArs: serializer.fromJson<double?>(json['monthlyBudgetArs']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'city': serializer.toJson<String>(city),
      'themeMode': serializer.toJson<String>(themeMode),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'keepScreenOn': serializer.toJson<bool>(keepScreenOn),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
      'avatarChoice': serializer.toJson<String>(avatarChoice),
      'googlePhotoUrl': serializer.toJson<String?>(googlePhotoUrl),
      'planTier': serializer.toJson<String>(planTier),
      'freeMaxLists': serializer.toJson<int>(freeMaxLists),
      'basicMaxLists': serializer.toJson<int>(basicMaxLists),
      'proMaxLists': serializer.toJson<int>(proMaxLists),
      'monthlyBudgetArs': serializer.toJson<double?>(monthlyBudgetArs),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  UserPreferencesEntity copyWith({
    int? id,
    String? city,
    String? themeMode,
    bool? onboardingCompleted,
    bool? keepScreenOn,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? avatarChoice,
    Value<String?> googlePhotoUrl = const Value.absent(),
    String? planTier,
    int? freeMaxLists,
    int? basicMaxLists,
    int? proMaxLists,
    Value<double?> monthlyBudgetArs = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => UserPreferencesEntity(
    id: id ?? this.id,
    city: city ?? this.city,
    themeMode: themeMode ?? this.themeMode,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    avatarChoice: avatarChoice ?? this.avatarChoice,
    googlePhotoUrl: googlePhotoUrl.present
        ? googlePhotoUrl.value
        : this.googlePhotoUrl,
    planTier: planTier ?? this.planTier,
    freeMaxLists: freeMaxLists ?? this.freeMaxLists,
    basicMaxLists: basicMaxLists ?? this.basicMaxLists,
    proMaxLists: proMaxLists ?? this.proMaxLists,
    monthlyBudgetArs: monthlyBudgetArs.present
        ? monthlyBudgetArs.value
        : this.monthlyBudgetArs,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserPreferencesEntity copyWithCompanion(LocalPreferencesCompanion data) {
    return UserPreferencesEntity(
      id: data.id.present ? data.id.value : this.id,
      city: data.city.present ? data.city.value : this.city,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      keepScreenOn: data.keepScreenOn.present
          ? data.keepScreenOn.value
          : this.keepScreenOn,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
      avatarChoice: data.avatarChoice.present
          ? data.avatarChoice.value
          : this.avatarChoice,
      googlePhotoUrl: data.googlePhotoUrl.present
          ? data.googlePhotoUrl.value
          : this.googlePhotoUrl,
      planTier: data.planTier.present ? data.planTier.value : this.planTier,
      freeMaxLists: data.freeMaxLists.present
          ? data.freeMaxLists.value
          : this.freeMaxLists,
      basicMaxLists: data.basicMaxLists.present
          ? data.basicMaxLists.value
          : this.basicMaxLists,
      proMaxLists: data.proMaxLists.present
          ? data.proMaxLists.value
          : this.proMaxLists,
      monthlyBudgetArs: data.monthlyBudgetArs.present
          ? data.monthlyBudgetArs.value
          : this.monthlyBudgetArs,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesEntity(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('keepScreenOn: $keepScreenOn, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('avatarChoice: $avatarChoice, ')
          ..write('googlePhotoUrl: $googlePhotoUrl, ')
          ..write('planTier: $planTier, ')
          ..write('freeMaxLists: $freeMaxLists, ')
          ..write('basicMaxLists: $basicMaxLists, ')
          ..write('proMaxLists: $proMaxLists, ')
          ..write('monthlyBudgetArs: $monthlyBudgetArs, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    city,
    themeMode,
    onboardingCompleted,
    keepScreenOn,
    soundEnabled,
    vibrationEnabled,
    avatarChoice,
    googlePhotoUrl,
    planTier,
    freeMaxLists,
    basicMaxLists,
    proMaxLists,
    monthlyBudgetArs,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferencesEntity &&
          other.id == this.id &&
          other.city == this.city &&
          other.themeMode == this.themeMode &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.keepScreenOn == this.keepScreenOn &&
          other.soundEnabled == this.soundEnabled &&
          other.vibrationEnabled == this.vibrationEnabled &&
          other.avatarChoice == this.avatarChoice &&
          other.googlePhotoUrl == this.googlePhotoUrl &&
          other.planTier == this.planTier &&
          other.freeMaxLists == this.freeMaxLists &&
          other.basicMaxLists == this.basicMaxLists &&
          other.proMaxLists == this.proMaxLists &&
          other.monthlyBudgetArs == this.monthlyBudgetArs &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalPreferencesCompanion extends UpdateCompanion<UserPreferencesEntity> {
  final Value<int> id;
  final Value<String> city;
  final Value<String> themeMode;
  final Value<bool> onboardingCompleted;
  final Value<bool> keepScreenOn;
  final Value<bool> soundEnabled;
  final Value<bool> vibrationEnabled;
  final Value<String> avatarChoice;
  final Value<String?> googlePhotoUrl;
  final Value<String> planTier;
  final Value<int> freeMaxLists;
  final Value<int> basicMaxLists;
  final Value<int> proMaxLists;
  final Value<double?> monthlyBudgetArs;
  final Value<DateTime?> lastSyncedAt;
  const LocalPreferencesCompanion({
    this.id = const Value.absent(),
    this.city = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.avatarChoice = const Value.absent(),
    this.googlePhotoUrl = const Value.absent(),
    this.planTier = const Value.absent(),
    this.freeMaxLists = const Value.absent(),
    this.basicMaxLists = const Value.absent(),
    this.proMaxLists = const Value.absent(),
    this.monthlyBudgetArs = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.city = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.avatarChoice = const Value.absent(),
    this.googlePhotoUrl = const Value.absent(),
    this.planTier = const Value.absent(),
    this.freeMaxLists = const Value.absent(),
    this.basicMaxLists = const Value.absent(),
    this.proMaxLists = const Value.absent(),
    this.monthlyBudgetArs = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<UserPreferencesEntity> custom({
    Expression<int>? id,
    Expression<String>? city,
    Expression<String>? themeMode,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? keepScreenOn,
    Expression<bool>? soundEnabled,
    Expression<bool>? vibrationEnabled,
    Expression<String>? avatarChoice,
    Expression<String>? googlePhotoUrl,
    Expression<String>? planTier,
    Expression<int>? freeMaxLists,
    Expression<int>? basicMaxLists,
    Expression<int>? proMaxLists,
    Expression<double>? monthlyBudgetArs,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (city != null) 'city': city,
      if (themeMode != null) 'theme_mode': themeMode,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (keepScreenOn != null) 'keep_screen_on': keepScreenOn,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
      if (avatarChoice != null) 'avatar_choice': avatarChoice,
      if (googlePhotoUrl != null) 'google_photo_url': googlePhotoUrl,
      if (planTier != null) 'plan_tier': planTier,
      if (freeMaxLists != null) 'free_max_lists': freeMaxLists,
      if (basicMaxLists != null) 'basic_max_lists': basicMaxLists,
      if (proMaxLists != null) 'pro_max_lists': proMaxLists,
      if (monthlyBudgetArs != null) 'monthly_budget_ars': monthlyBudgetArs,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? city,
    Value<String>? themeMode,
    Value<bool>? onboardingCompleted,
    Value<bool>? keepScreenOn,
    Value<bool>? soundEnabled,
    Value<bool>? vibrationEnabled,
    Value<String>? avatarChoice,
    Value<String?>? googlePhotoUrl,
    Value<String>? planTier,
    Value<int>? freeMaxLists,
    Value<int>? basicMaxLists,
    Value<int>? proMaxLists,
    Value<double?>? monthlyBudgetArs,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalPreferencesCompanion(
      id: id ?? this.id,
      city: city ?? this.city,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      avatarChoice: avatarChoice ?? this.avatarChoice,
      googlePhotoUrl: googlePhotoUrl ?? this.googlePhotoUrl,
      planTier: planTier ?? this.planTier,
      freeMaxLists: freeMaxLists ?? this.freeMaxLists,
      basicMaxLists: basicMaxLists ?? this.basicMaxLists,
      proMaxLists: proMaxLists ?? this.proMaxLists,
      monthlyBudgetArs: monthlyBudgetArs ?? this.monthlyBudgetArs,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (keepScreenOn.present) {
      map['keep_screen_on'] = Variable<bool>(keepScreenOn.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    if (avatarChoice.present) {
      map['avatar_choice'] = Variable<String>(avatarChoice.value);
    }
    if (googlePhotoUrl.present) {
      map['google_photo_url'] = Variable<String>(googlePhotoUrl.value);
    }
    if (planTier.present) {
      map['plan_tier'] = Variable<String>(planTier.value);
    }
    if (freeMaxLists.present) {
      map['free_max_lists'] = Variable<int>(freeMaxLists.value);
    }
    if (basicMaxLists.present) {
      map['basic_max_lists'] = Variable<int>(basicMaxLists.value);
    }
    if (proMaxLists.present) {
      map['pro_max_lists'] = Variable<int>(proMaxLists.value);
    }
    if (monthlyBudgetArs.present) {
      map['monthly_budget_ars'] = Variable<double>(monthlyBudgetArs.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('keepScreenOn: $keepScreenOn, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('avatarChoice: $avatarChoice, ')
          ..write('googlePhotoUrl: $googlePhotoUrl, ')
          ..write('planTier: $planTier, ')
          ..write('freeMaxLists: $freeMaxLists, ')
          ..write('basicMaxLists: $basicMaxLists, ')
          ..write('proMaxLists: $proMaxLists, ')
          ..write('monthlyBudgetArs: $monthlyBudgetArs, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalPendingDeletionsTable extends LocalPendingDeletions
    with TableInfo<$LocalPendingDeletionsTable, PendingDeletionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPendingDeletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLeaveOnlyMeta = const VerificationMeta(
    'isLeaveOnly',
  );
  @override
  late final GeneratedColumn<bool> isLeaveOnly = GeneratedColumn<bool>(
    'is_leave_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leave_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityKey,
    isLeaveOnly,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pending_deletions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingDeletionEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('is_leave_only')) {
      context.handle(
        _isLeaveOnlyMeta,
        isLeaveOnly.isAcceptableOrUnknown(
          data['is_leave_only']!,
          _isLeaveOnlyMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingDeletionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDeletionEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      isLeaveOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leave_only'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $LocalPendingDeletionsTable createAlias(String alias) {
    return $LocalPendingDeletionsTable(attachedDatabase, alias);
  }
}

class PendingDeletionEntity extends DataClass
    implements Insertable<PendingDeletionEntity> {
  final String id;
  final String entityType;
  final String entityKey;
  final bool isLeaveOnly;
  final DateTime deletedAt;
  const PendingDeletionEntity({
    required this.id,
    required this.entityType,
    required this.entityKey,
    required this.isLeaveOnly,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_key'] = Variable<String>(entityKey);
    map['is_leave_only'] = Variable<bool>(isLeaveOnly);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  LocalPendingDeletionsCompanion toCompanion(bool nullToAbsent) {
    return LocalPendingDeletionsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityKey: Value(entityKey),
      isLeaveOnly: Value(isLeaveOnly),
      deletedAt: Value(deletedAt),
    );
  }

  factory PendingDeletionEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDeletionEntity(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityKey: serializer.fromJson<String>(json['entityKey']),
      isLeaveOnly: serializer.fromJson<bool>(json['isLeaveOnly']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityKey': serializer.toJson<String>(entityKey),
      'isLeaveOnly': serializer.toJson<bool>(isLeaveOnly),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  PendingDeletionEntity copyWith({
    String? id,
    String? entityType,
    String? entityKey,
    bool? isLeaveOnly,
    DateTime? deletedAt,
  }) => PendingDeletionEntity(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityKey: entityKey ?? this.entityKey,
    isLeaveOnly: isLeaveOnly ?? this.isLeaveOnly,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  PendingDeletionEntity copyWithCompanion(LocalPendingDeletionsCompanion data) {
    return PendingDeletionEntity(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      isLeaveOnly: data.isLeaveOnly.present
          ? data.isLeaveOnly.value
          : this.isLeaveOnly,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletionEntity(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('isLeaveOnly: $isLeaveOnly, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entityKey, isLeaveOnly, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDeletionEntity &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityKey == this.entityKey &&
          other.isLeaveOnly == this.isLeaveOnly &&
          other.deletedAt == this.deletedAt);
}

class LocalPendingDeletionsCompanion
    extends UpdateCompanion<PendingDeletionEntity> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityKey;
  final Value<bool> isLeaveOnly;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const LocalPendingDeletionsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityKey = const Value.absent(),
    this.isLeaveOnly = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPendingDeletionsCompanion.insert({
    required String id,
    required String entityType,
    required String entityKey,
    this.isLeaveOnly = const Value.absent(),
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityKey = Value(entityKey),
       deletedAt = Value(deletedAt);
  static Insertable<PendingDeletionEntity> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityKey,
    Expression<bool>? isLeaveOnly,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityKey != null) 'entity_key': entityKey,
      if (isLeaveOnly != null) 'is_leave_only': isLeaveOnly,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPendingDeletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityKey,
    Value<bool>? isLeaveOnly,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalPendingDeletionsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityKey: entityKey ?? this.entityKey,
      isLeaveOnly: isLeaveOnly ?? this.isLeaveOnly,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (isLeaveOnly.present) {
      map['is_leave_only'] = Variable<bool>(isLeaveOnly.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPendingDeletionsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('isLeaveOnly: $isLeaveOnly, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCachedAdsTable extends LocalCachedAds
    with TableInfo<$LocalCachedAdsTable, CachedAdEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCachedAdsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessNameMeta = const VerificationMeta(
    'businessName',
  );
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
    'business_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bannerUrlMeta = const VerificationMeta(
    'bannerUrl',
  );
  @override
  late final GeneratedColumn<String> bannerUrl = GeneratedColumn<String>(
    'banner_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interstitialUrlMeta = const VerificationMeta(
    'interstitialUrl',
  );
  @override
  late final GeneratedColumn<String> interstitialUrl = GeneratedColumn<String>(
    'interstitial_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionUrlMeta = const VerificationMeta(
    'actionUrl',
  );
  @override
  late final GeneratedColumn<String> actionUrl = GeneratedColumn<String>(
    'action_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessName,
    city,
    tier,
    bannerUrl,
    interstitialUrl,
    actionUrl,
    expiresAt,
    isActive,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cached_ads';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAdEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
        _businessNameMeta,
        businessName.isAcceptableOrUnknown(
          data['business_name']!,
          _businessNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessNameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('banner_url')) {
      context.handle(
        _bannerUrlMeta,
        bannerUrl.isAcceptableOrUnknown(data['banner_url']!, _bannerUrlMeta),
      );
    }
    if (data.containsKey('interstitial_url')) {
      context.handle(
        _interstitialUrlMeta,
        interstitialUrl.isAcceptableOrUnknown(
          data['interstitial_url']!,
          _interstitialUrlMeta,
        ),
      );
    }
    if (data.containsKey('action_url')) {
      context.handle(
        _actionUrlMeta,
        actionUrl.isAcceptableOrUnknown(data['action_url']!, _actionUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_actionUrlMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAdEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAdEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      bannerUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banner_url'],
      ),
      interstitialUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interstitial_url'],
      ),
      actionUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_url'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LocalCachedAdsTable createAlias(String alias) {
    return $LocalCachedAdsTable(attachedDatabase, alias);
  }
}

class CachedAdEntity extends DataClass implements Insertable<CachedAdEntity> {
  final String id;
  final String businessName;
  final String city;
  final String tier;
  final String? bannerUrl;
  final String? interstitialUrl;
  final String actionUrl;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime cachedAt;
  const CachedAdEntity({
    required this.id,
    required this.businessName,
    required this.city,
    required this.tier,
    this.bannerUrl,
    this.interstitialUrl,
    required this.actionUrl,
    required this.expiresAt,
    required this.isActive,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_name'] = Variable<String>(businessName);
    map['city'] = Variable<String>(city);
    map['tier'] = Variable<String>(tier);
    if (!nullToAbsent || bannerUrl != null) {
      map['banner_url'] = Variable<String>(bannerUrl);
    }
    if (!nullToAbsent || interstitialUrl != null) {
      map['interstitial_url'] = Variable<String>(interstitialUrl);
    }
    map['action_url'] = Variable<String>(actionUrl);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['is_active'] = Variable<bool>(isActive);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalCachedAdsCompanion toCompanion(bool nullToAbsent) {
    return LocalCachedAdsCompanion(
      id: Value(id),
      businessName: Value(businessName),
      city: Value(city),
      tier: Value(tier),
      bannerUrl: bannerUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bannerUrl),
      interstitialUrl: interstitialUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(interstitialUrl),
      actionUrl: Value(actionUrl),
      expiresAt: Value(expiresAt),
      isActive: Value(isActive),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAdEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAdEntity(
      id: serializer.fromJson<String>(json['id']),
      businessName: serializer.fromJson<String>(json['businessName']),
      city: serializer.fromJson<String>(json['city']),
      tier: serializer.fromJson<String>(json['tier']),
      bannerUrl: serializer.fromJson<String?>(json['bannerUrl']),
      interstitialUrl: serializer.fromJson<String?>(json['interstitialUrl']),
      actionUrl: serializer.fromJson<String>(json['actionUrl']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessName': serializer.toJson<String>(businessName),
      'city': serializer.toJson<String>(city),
      'tier': serializer.toJson<String>(tier),
      'bannerUrl': serializer.toJson<String?>(bannerUrl),
      'interstitialUrl': serializer.toJson<String?>(interstitialUrl),
      'actionUrl': serializer.toJson<String>(actionUrl),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'isActive': serializer.toJson<bool>(isActive),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAdEntity copyWith({
    String? id,
    String? businessName,
    String? city,
    String? tier,
    Value<String?> bannerUrl = const Value.absent(),
    Value<String?> interstitialUrl = const Value.absent(),
    String? actionUrl,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? cachedAt,
  }) => CachedAdEntity(
    id: id ?? this.id,
    businessName: businessName ?? this.businessName,
    city: city ?? this.city,
    tier: tier ?? this.tier,
    bannerUrl: bannerUrl.present ? bannerUrl.value : this.bannerUrl,
    interstitialUrl: interstitialUrl.present
        ? interstitialUrl.value
        : this.interstitialUrl,
    actionUrl: actionUrl ?? this.actionUrl,
    expiresAt: expiresAt ?? this.expiresAt,
    isActive: isActive ?? this.isActive,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedAdEntity copyWithCompanion(LocalCachedAdsCompanion data) {
    return CachedAdEntity(
      id: data.id.present ? data.id.value : this.id,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      city: data.city.present ? data.city.value : this.city,
      tier: data.tier.present ? data.tier.value : this.tier,
      bannerUrl: data.bannerUrl.present ? data.bannerUrl.value : this.bannerUrl,
      interstitialUrl: data.interstitialUrl.present
          ? data.interstitialUrl.value
          : this.interstitialUrl,
      actionUrl: data.actionUrl.present ? data.actionUrl.value : this.actionUrl,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAdEntity(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('city: $city, ')
          ..write('tier: $tier, ')
          ..write('bannerUrl: $bannerUrl, ')
          ..write('interstitialUrl: $interstitialUrl, ')
          ..write('actionUrl: $actionUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isActive: $isActive, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessName,
    city,
    tier,
    bannerUrl,
    interstitialUrl,
    actionUrl,
    expiresAt,
    isActive,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAdEntity &&
          other.id == this.id &&
          other.businessName == this.businessName &&
          other.city == this.city &&
          other.tier == this.tier &&
          other.bannerUrl == this.bannerUrl &&
          other.interstitialUrl == this.interstitialUrl &&
          other.actionUrl == this.actionUrl &&
          other.expiresAt == this.expiresAt &&
          other.isActive == this.isActive &&
          other.cachedAt == this.cachedAt);
}

class LocalCachedAdsCompanion extends UpdateCompanion<CachedAdEntity> {
  final Value<String> id;
  final Value<String> businessName;
  final Value<String> city;
  final Value<String> tier;
  final Value<String?> bannerUrl;
  final Value<String?> interstitialUrl;
  final Value<String> actionUrl;
  final Value<DateTime> expiresAt;
  final Value<bool> isActive;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalCachedAdsCompanion({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.city = const Value.absent(),
    this.tier = const Value.absent(),
    this.bannerUrl = const Value.absent(),
    this.interstitialUrl = const Value.absent(),
    this.actionUrl = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCachedAdsCompanion.insert({
    required String id,
    required String businessName,
    required String city,
    required String tier,
    this.bannerUrl = const Value.absent(),
    this.interstitialUrl = const Value.absent(),
    required String actionUrl,
    required DateTime expiresAt,
    this.isActive = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessName = Value(businessName),
       city = Value(city),
       tier = Value(tier),
       actionUrl = Value(actionUrl),
       expiresAt = Value(expiresAt),
       cachedAt = Value(cachedAt);
  static Insertable<CachedAdEntity> custom({
    Expression<String>? id,
    Expression<String>? businessName,
    Expression<String>? city,
    Expression<String>? tier,
    Expression<String>? bannerUrl,
    Expression<String>? interstitialUrl,
    Expression<String>? actionUrl,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isActive,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessName != null) 'business_name': businessName,
      if (city != null) 'city': city,
      if (tier != null) 'tier': tier,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (interstitialUrl != null) 'interstitial_url': interstitialUrl,
      if (actionUrl != null) 'action_url': actionUrl,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isActive != null) 'is_active': isActive,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCachedAdsCompanion copyWith({
    Value<String>? id,
    Value<String>? businessName,
    Value<String>? city,
    Value<String>? tier,
    Value<String?>? bannerUrl,
    Value<String?>? interstitialUrl,
    Value<String>? actionUrl,
    Value<DateTime>? expiresAt,
    Value<bool>? isActive,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LocalCachedAdsCompanion(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      city: city ?? this.city,
      tier: tier ?? this.tier,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      interstitialUrl: interstitialUrl ?? this.interstitialUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (bannerUrl.present) {
      map['banner_url'] = Variable<String>(bannerUrl.value);
    }
    if (interstitialUrl.present) {
      map['interstitial_url'] = Variable<String>(interstitialUrl.value);
    }
    if (actionUrl.present) {
      map['action_url'] = Variable<String>(actionUrl.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCachedAdsCompanion(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('city: $city, ')
          ..write('tier: $tier, ')
          ..write('bannerUrl: $bannerUrl, ')
          ..write('interstitialUrl: $interstitialUrl, ')
          ..write('actionUrl: $actionUrl, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isActive: $isActive, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpenseHistoryTable extends LocalExpenseHistory
    with TableInfo<$LocalExpenseHistoryTable, ExpenseHistoryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpenseHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listTitleMeta = const VerificationMeta(
    'listTitle',
  );
  @override
  late final GeneratedColumn<String> listTitle = GeneratedColumn<String>(
    'list_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeCategoryMeta = const VerificationMeta(
    'storeCategory',
  );
  @override
  late final GeneratedColumn<String> storeCategory = GeneratedColumn<String>(
    'store_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    listTitle,
    storeCategory,
    totalAmount,
    itemCount,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expense_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseHistoryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    }
    if (data.containsKey('list_title')) {
      context.handle(
        _listTitleMeta,
        listTitle.isAcceptableOrUnknown(data['list_title']!, _listTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_listTitleMeta);
    }
    if (data.containsKey('store_category')) {
      context.handle(
        _storeCategoryMeta,
        storeCategory.isAcceptableOrUnknown(
          data['store_category']!,
          _storeCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storeCategoryMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseHistoryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseHistoryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      ),
      listTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_title'],
      )!,
      storeCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_category'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $LocalExpenseHistoryTable createAlias(String alias) {
    return $LocalExpenseHistoryTable(attachedDatabase, alias);
  }
}

class ExpenseHistoryEntity extends DataClass
    implements Insertable<ExpenseHistoryEntity> {
  final String id;
  final String? listId;
  final String listTitle;
  final String storeCategory;
  final double totalAmount;
  final int itemCount;
  final DateTime recordedAt;
  const ExpenseHistoryEntity({
    required this.id,
    this.listId,
    required this.listTitle,
    required this.storeCategory,
    required this.totalAmount,
    required this.itemCount,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || listId != null) {
      map['list_id'] = Variable<String>(listId);
    }
    map['list_title'] = Variable<String>(listTitle);
    map['store_category'] = Variable<String>(storeCategory);
    map['total_amount'] = Variable<double>(totalAmount);
    map['item_count'] = Variable<int>(itemCount);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  LocalExpenseHistoryCompanion toCompanion(bool nullToAbsent) {
    return LocalExpenseHistoryCompanion(
      id: Value(id),
      listId: listId == null && nullToAbsent
          ? const Value.absent()
          : Value(listId),
      listTitle: Value(listTitle),
      storeCategory: Value(storeCategory),
      totalAmount: Value(totalAmount),
      itemCount: Value(itemCount),
      recordedAt: Value(recordedAt),
    );
  }

  factory ExpenseHistoryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseHistoryEntity(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String?>(json['listId']),
      listTitle: serializer.fromJson<String>(json['listTitle']),
      storeCategory: serializer.fromJson<String>(json['storeCategory']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String?>(listId),
      'listTitle': serializer.toJson<String>(listTitle),
      'storeCategory': serializer.toJson<String>(storeCategory),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'itemCount': serializer.toJson<int>(itemCount),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  ExpenseHistoryEntity copyWith({
    String? id,
    Value<String?> listId = const Value.absent(),
    String? listTitle,
    String? storeCategory,
    double? totalAmount,
    int? itemCount,
    DateTime? recordedAt,
  }) => ExpenseHistoryEntity(
    id: id ?? this.id,
    listId: listId.present ? listId.value : this.listId,
    listTitle: listTitle ?? this.listTitle,
    storeCategory: storeCategory ?? this.storeCategory,
    totalAmount: totalAmount ?? this.totalAmount,
    itemCount: itemCount ?? this.itemCount,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  ExpenseHistoryEntity copyWithCompanion(LocalExpenseHistoryCompanion data) {
    return ExpenseHistoryEntity(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      listTitle: data.listTitle.present ? data.listTitle.value : this.listTitle,
      storeCategory: data.storeCategory.present
          ? data.storeCategory.value
          : this.storeCategory,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseHistoryEntity(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('listTitle: $listTitle, ')
          ..write('storeCategory: $storeCategory, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('itemCount: $itemCount, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    listTitle,
    storeCategory,
    totalAmount,
    itemCount,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseHistoryEntity &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.listTitle == this.listTitle &&
          other.storeCategory == this.storeCategory &&
          other.totalAmount == this.totalAmount &&
          other.itemCount == this.itemCount &&
          other.recordedAt == this.recordedAt);
}

class LocalExpenseHistoryCompanion
    extends UpdateCompanion<ExpenseHistoryEntity> {
  final Value<String> id;
  final Value<String?> listId;
  final Value<String> listTitle;
  final Value<String> storeCategory;
  final Value<double> totalAmount;
  final Value<int> itemCount;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const LocalExpenseHistoryCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.listTitle = const Value.absent(),
    this.storeCategory = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpenseHistoryCompanion.insert({
    required String id,
    this.listId = const Value.absent(),
    required String listTitle,
    required String storeCategory,
    required double totalAmount,
    this.itemCount = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listTitle = Value(listTitle),
       storeCategory = Value(storeCategory),
       totalAmount = Value(totalAmount),
       recordedAt = Value(recordedAt);
  static Insertable<ExpenseHistoryEntity> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? listTitle,
    Expression<String>? storeCategory,
    Expression<double>? totalAmount,
    Expression<int>? itemCount,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (listTitle != null) 'list_title': listTitle,
      if (storeCategory != null) 'store_category': storeCategory,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (itemCount != null) 'item_count': itemCount,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpenseHistoryCompanion copyWith({
    Value<String>? id,
    Value<String?>? listId,
    Value<String>? listTitle,
    Value<String>? storeCategory,
    Value<double>? totalAmount,
    Value<int>? itemCount,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return LocalExpenseHistoryCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      listTitle: listTitle ?? this.listTitle,
      storeCategory: storeCategory ?? this.storeCategory,
      totalAmount: totalAmount ?? this.totalAmount,
      itemCount: itemCount ?? this.itemCount,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (listTitle.present) {
      map['list_title'] = Variable<String>(listTitle.value);
    }
    if (storeCategory.present) {
      map['store_category'] = Variable<String>(storeCategory.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpenseHistoryCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('listTitle: $listTitle, ')
          ..write('storeCategory: $storeCategory, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('itemCount: $itemCount, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalListsTable localLists = $LocalListsTable(this);
  late final $LocalItemsTable localItems = $LocalItemsTable(this);
  late final $LocalAisleOrderTable localAisleOrder = $LocalAisleOrderTable(
    this,
  );
  late final $LocalLearnedItemsTable localLearnedItems =
      $LocalLearnedItemsTable(this);
  late final $LocalPreferencesTable localPreferences = $LocalPreferencesTable(
    this,
  );
  late final $LocalPendingDeletionsTable localPendingDeletions =
      $LocalPendingDeletionsTable(this);
  late final $LocalCachedAdsTable localCachedAds = $LocalCachedAdsTable(this);
  late final $LocalExpenseHistoryTable localExpenseHistory =
      $LocalExpenseHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localLists,
    localItems,
    localAisleOrder,
    localLearnedItems,
    localPreferences,
    localPendingDeletions,
    localCachedAds,
    localExpenseHistory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'local_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('local_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LocalListsTableCreateCompanionBuilder =
    LocalListsCompanion Function({
      required String id,
      required String title,
      Value<String?> ownerId,
      Value<bool> isShared,
      Value<String?> shareCode,
      Value<bool> isJoinedRemote,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalListsTableUpdateCompanionBuilder =
    LocalListsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> ownerId,
      Value<bool> isShared,
      Value<String?> shareCode,
      Value<bool> isJoinedRemote,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$LocalListsTableReferences
    extends
        BaseReferences<_$AppDatabase, $LocalListsTable, ShoppingListEntity> {
  $$LocalListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalItemsTable, List<ShoppingItemEntity>>
  _localItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localItems,
    aliasName: 'local_lists__id__local_items__list_id',
  );

  $$LocalItemsTableProcessedTableManager get localItemsRefs {
    final manager = $$LocalItemsTableTableManager(
      $_db,
      $_db.localItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalListsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalListsTable> {
  $$LocalListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isJoinedRemote => $composableBuilder(
    column: $table.isJoinedRemote,
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

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localItemsRefs(
    Expression<bool> Function($$LocalItemsTableFilterComposer f) f,
  ) {
    final $$LocalItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalItemsTableFilterComposer(
            $db: $db,
            $table: $db.localItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalListsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalListsTable> {
  $$LocalListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareCode => $composableBuilder(
    column: $table.shareCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isJoinedRemote => $composableBuilder(
    column: $table.isJoinedRemote,
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

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalListsTable> {
  $$LocalListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<String> get shareCode =>
      $composableBuilder(column: $table.shareCode, builder: (column) => column);

  GeneratedColumn<bool> get isJoinedRemote => $composableBuilder(
    column: $table.isJoinedRemote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> localItemsRefs<T extends Object>(
    Expression<T> Function($$LocalItemsTableAnnotationComposer a) f,
  ) {
    final $$LocalItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.localItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalListsTable,
          ShoppingListEntity,
          $$LocalListsTableFilterComposer,
          $$LocalListsTableOrderingComposer,
          $$LocalListsTableAnnotationComposer,
          $$LocalListsTableCreateCompanionBuilder,
          $$LocalListsTableUpdateCompanionBuilder,
          (ShoppingListEntity, $$LocalListsTableReferences),
          ShoppingListEntity,
          PrefetchHooks Function({bool localItemsRefs})
        > {
  $$LocalListsTableTableManager(_$AppDatabase db, $LocalListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<bool> isJoinedRemote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalListsCompanion(
                id: id,
                title: title,
                ownerId: ownerId,
                isShared: isShared,
                shareCode: shareCode,
                isJoinedRemote: isJoinedRemote,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> ownerId = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<String?> shareCode = const Value.absent(),
                Value<bool> isJoinedRemote = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalListsCompanion.insert(
                id: id,
                title: title,
                ownerId: ownerId,
                isShared: isShared,
                shareCode: shareCode,
                isJoinedRemote: isJoinedRemote,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalListsTable, ShoppingListEntity>(table),
                  $$LocalListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localItemsRefs) db.localItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      ShoppingListEntity,
                      $LocalListsTable,
                      ShoppingItemEntity,
                      $LocalItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$LocalListsTableReferences
                          ._localItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalListsTableReferences(
                            db,
                            table,
                            p0,
                          ).localItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'list_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalListsTable,
      ShoppingListEntity,
      $$LocalListsTableFilterComposer,
      $$LocalListsTableOrderingComposer,
      $$LocalListsTableAnnotationComposer,
      $$LocalListsTableCreateCompanionBuilder,
      $$LocalListsTableUpdateCompanionBuilder,
      (ShoppingListEntity, $$LocalListsTableReferences),
      ShoppingListEntity,
      PrefetchHooks Function({bool localItemsRefs})
    >;
typedef $$LocalItemsTableCreateCompanionBuilder =
    LocalItemsCompanion Function({
      required String id,
      required String listId,
      required String rawText,
      required String cleanName,
      Value<double> quantity,
      Value<String> unit,
      required String storeCategory,
      required String aisleName,
      Value<bool> isChecked,
      Value<double?> price,
      Value<int> position,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalItemsTableUpdateCompanionBuilder =
    LocalItemsCompanion Function({
      Value<String> id,
      Value<String> listId,
      Value<String> rawText,
      Value<String> cleanName,
      Value<double> quantity,
      Value<String> unit,
      Value<String> storeCategory,
      Value<String> aisleName,
      Value<bool> isChecked,
      Value<double?> price,
      Value<int> position,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$LocalItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $LocalItemsTable, ShoppingItemEntity> {
  $$LocalItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalListsTable _listIdTable(_$AppDatabase db) =>
      db.localLists.createAlias('local_items__list_id__local_lists__id');

  $$LocalListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<String>('list_id')!;

    final manager = $$LocalListsTableTableManager(
      $_db,
      $_db.localLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalItemsTable> {
  $$LocalItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cleanName => $composableBuilder(
    column: $table.cleanName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aisleName => $composableBuilder(
    column: $table.aisleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalListsTableFilterComposer get listId {
    final $$LocalListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.localLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalListsTableFilterComposer(
            $db: $db,
            $table: $db.localLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalItemsTable> {
  $$LocalItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cleanName => $composableBuilder(
    column: $table.cleanName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aisleName => $composableBuilder(
    column: $table.aisleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalListsTableOrderingComposer get listId {
    final $$LocalListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.localLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalListsTableOrderingComposer(
            $db: $db,
            $table: $db.localLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalItemsTable> {
  $$LocalItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get cleanName =>
      $composableBuilder(column: $table.cleanName, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aisleName =>
      $composableBuilder(column: $table.aisleName, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$LocalListsTableAnnotationComposer get listId {
    final $$LocalListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.localLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalListsTableAnnotationComposer(
            $db: $db,
            $table: $db.localLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalItemsTable,
          ShoppingItemEntity,
          $$LocalItemsTableFilterComposer,
          $$LocalItemsTableOrderingComposer,
          $$LocalItemsTableAnnotationComposer,
          $$LocalItemsTableCreateCompanionBuilder,
          $$LocalItemsTableUpdateCompanionBuilder,
          (ShoppingItemEntity, $$LocalItemsTableReferences),
          ShoppingItemEntity,
          PrefetchHooks Function({bool listId})
        > {
  $$LocalItemsTableTableManager(_$AppDatabase db, $LocalItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String> cleanName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> storeCategory = const Value.absent(),
                Value<String> aisleName = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalItemsCompanion(
                id: id,
                listId: listId,
                rawText: rawText,
                cleanName: cleanName,
                quantity: quantity,
                unit: unit,
                storeCategory: storeCategory,
                aisleName: aisleName,
                isChecked: isChecked,
                price: price,
                position: position,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String rawText,
                required String cleanName,
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                required String storeCategory,
                required String aisleName,
                Value<bool> isChecked = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<int> position = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalItemsCompanion.insert(
                id: id,
                listId: listId,
                rawText: rawText,
                cleanName: cleanName,
                quantity: quantity,
                unit: unit,
                storeCategory: storeCategory,
                aisleName: aisleName,
                isChecked: isChecked,
                price: price,
                position: position,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalItemsTable, ShoppingItemEntity>(table),
                  $$LocalItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable: $$LocalItemsTableReferences
                                    ._listIdTable(db),
                                referencedColumn: $$LocalItemsTableReferences
                                    ._listIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalItemsTable,
      ShoppingItemEntity,
      $$LocalItemsTableFilterComposer,
      $$LocalItemsTableOrderingComposer,
      $$LocalItemsTableAnnotationComposer,
      $$LocalItemsTableCreateCompanionBuilder,
      $$LocalItemsTableUpdateCompanionBuilder,
      (ShoppingItemEntity, $$LocalItemsTableReferences),
      ShoppingItemEntity,
      PrefetchHooks Function({bool listId})
    >;
typedef $$LocalAisleOrderTableCreateCompanionBuilder =
    LocalAisleOrderCompanion Function({
      required String storeCategory,
      required String aisleName,
      required int sortOrder,
      Value<DateTime?> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalAisleOrderTableUpdateCompanionBuilder =
    LocalAisleOrderCompanion Function({
      Value<String> storeCategory,
      Value<String> aisleName,
      Value<int> sortOrder,
      Value<DateTime?> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$LocalAisleOrderTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAisleOrderTable> {
  $$LocalAisleOrderTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aisleName => $composableBuilder(
    column: $table.aisleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAisleOrderTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAisleOrderTable> {
  $$LocalAisleOrderTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aisleName => $composableBuilder(
    column: $table.aisleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAisleOrderTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAisleOrderTable> {
  $$LocalAisleOrderTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aisleName =>
      $composableBuilder(column: $table.aisleName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LocalAisleOrderTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAisleOrderTable,
          AisleOrderEntity,
          $$LocalAisleOrderTableFilterComposer,
          $$LocalAisleOrderTableOrderingComposer,
          $$LocalAisleOrderTableAnnotationComposer,
          $$LocalAisleOrderTableCreateCompanionBuilder,
          $$LocalAisleOrderTableUpdateCompanionBuilder,
          (
            AisleOrderEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalAisleOrderTable,
              AisleOrderEntity
            >,
          ),
          AisleOrderEntity,
          PrefetchHooks Function()
        > {
  $$LocalAisleOrderTableTableManager(
    _$AppDatabase db,
    $LocalAisleOrderTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAisleOrderTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAisleOrderTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAisleOrderTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> storeCategory = const Value.absent(),
                Value<String> aisleName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAisleOrderCompanion(
                storeCategory: storeCategory,
                aisleName: aisleName,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storeCategory,
                required String aisleName,
                required int sortOrder,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAisleOrderCompanion.insert(
                storeCategory: storeCategory,
                aisleName: aisleName,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalAisleOrderTable, AisleOrderEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalAisleOrderTable,
                    AisleOrderEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAisleOrderTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAisleOrderTable,
      AisleOrderEntity,
      $$LocalAisleOrderTableFilterComposer,
      $$LocalAisleOrderTableOrderingComposer,
      $$LocalAisleOrderTableAnnotationComposer,
      $$LocalAisleOrderTableCreateCompanionBuilder,
      $$LocalAisleOrderTableUpdateCompanionBuilder,
      (
        AisleOrderEntity,
        BaseReferences<_$AppDatabase, $LocalAisleOrderTable, AisleOrderEntity>,
      ),
      AisleOrderEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalLearnedItemsTableCreateCompanionBuilder =
    LocalLearnedItemsCompanion Function({
      required String normalizedName,
      Value<String?> displayName,
      required String preferredStore,
      required String preferredAisle,
      Value<int> useCount,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalLearnedItemsTableUpdateCompanionBuilder =
    LocalLearnedItemsCompanion Function({
      Value<String> normalizedName,
      Value<String?> displayName,
      Value<String> preferredStore,
      Value<String> preferredAisle,
      Value<int> useCount,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$LocalLearnedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLearnedItemsTable> {
  $$LocalLearnedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredAisle => $composableBuilder(
    column: $table.preferredAisle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLearnedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLearnedItemsTable> {
  $$LocalLearnedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredAisle => $composableBuilder(
    column: $table.preferredAisle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useCount => $composableBuilder(
    column: $table.useCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLearnedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLearnedItemsTable> {
  $$LocalLearnedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredAisle => $composableBuilder(
    column: $table.preferredAisle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LocalLearnedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLearnedItemsTable,
          LearnedItemEntity,
          $$LocalLearnedItemsTableFilterComposer,
          $$LocalLearnedItemsTableOrderingComposer,
          $$LocalLearnedItemsTableAnnotationComposer,
          $$LocalLearnedItemsTableCreateCompanionBuilder,
          $$LocalLearnedItemsTableUpdateCompanionBuilder,
          (
            LearnedItemEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalLearnedItemsTable,
              LearnedItemEntity
            >,
          ),
          LearnedItemEntity,
          PrefetchHooks Function()
        > {
  $$LocalLearnedItemsTableTableManager(
    _$AppDatabase db,
    $LocalLearnedItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLearnedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLearnedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLearnedItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> normalizedName = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> preferredStore = const Value.absent(),
                Value<String> preferredAisle = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLearnedItemsCompanion(
                normalizedName: normalizedName,
                displayName: displayName,
                preferredStore: preferredStore,
                preferredAisle: preferredAisle,
                useCount: useCount,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedName,
                Value<String?> displayName = const Value.absent(),
                required String preferredStore,
                required String preferredAisle,
                Value<int> useCount = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLearnedItemsCompanion.insert(
                normalizedName: normalizedName,
                displayName: displayName,
                preferredStore: preferredStore,
                preferredAisle: preferredAisle,
                useCount: useCount,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalLearnedItemsTable, LearnedItemEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalLearnedItemsTable,
                    LearnedItemEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLearnedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLearnedItemsTable,
      LearnedItemEntity,
      $$LocalLearnedItemsTableFilterComposer,
      $$LocalLearnedItemsTableOrderingComposer,
      $$LocalLearnedItemsTableAnnotationComposer,
      $$LocalLearnedItemsTableCreateCompanionBuilder,
      $$LocalLearnedItemsTableUpdateCompanionBuilder,
      (
        LearnedItemEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalLearnedItemsTable,
          LearnedItemEntity
        >,
      ),
      LearnedItemEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalPreferencesTableCreateCompanionBuilder =
    LocalPreferencesCompanion Function({
      Value<int> id,
      Value<String> city,
      Value<String> themeMode,
      Value<bool> onboardingCompleted,
      Value<bool> keepScreenOn,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
      Value<String> avatarChoice,
      Value<String?> googlePhotoUrl,
      Value<String> planTier,
      Value<int> freeMaxLists,
      Value<int> basicMaxLists,
      Value<int> proMaxLists,
      Value<double?> monthlyBudgetArs,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalPreferencesTableUpdateCompanionBuilder =
    LocalPreferencesCompanion Function({
      Value<int> id,
      Value<String> city,
      Value<String> themeMode,
      Value<bool> onboardingCompleted,
      Value<bool> keepScreenOn,
      Value<bool> soundEnabled,
      Value<bool> vibrationEnabled,
      Value<String> avatarChoice,
      Value<String?> googlePhotoUrl,
      Value<String> planTier,
      Value<int> freeMaxLists,
      Value<int> basicMaxLists,
      Value<int> proMaxLists,
      Value<double?> monthlyBudgetArs,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPreferencesTable> {
  $$LocalPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarChoice => $composableBuilder(
    column: $table.avatarChoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get googlePhotoUrl => $composableBuilder(
    column: $table.googlePhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planTier => $composableBuilder(
    column: $table.planTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freeMaxLists => $composableBuilder(
    column: $table.freeMaxLists,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get basicMaxLists => $composableBuilder(
    column: $table.basicMaxLists,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proMaxLists => $composableBuilder(
    column: $table.proMaxLists,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyBudgetArs => $composableBuilder(
    column: $table.monthlyBudgetArs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPreferencesTable> {
  $$LocalPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarChoice => $composableBuilder(
    column: $table.avatarChoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get googlePhotoUrl => $composableBuilder(
    column: $table.googlePhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planTier => $composableBuilder(
    column: $table.planTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freeMaxLists => $composableBuilder(
    column: $table.freeMaxLists,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get basicMaxLists => $composableBuilder(
    column: $table.basicMaxLists,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proMaxLists => $composableBuilder(
    column: $table.proMaxLists,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyBudgetArs => $composableBuilder(
    column: $table.monthlyBudgetArs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPreferencesTable> {
  $$LocalPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepScreenOn => $composableBuilder(
    column: $table.keepScreenOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarChoice => $composableBuilder(
    column: $table.avatarChoice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get googlePhotoUrl => $composableBuilder(
    column: $table.googlePhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planTier =>
      $composableBuilder(column: $table.planTier, builder: (column) => column);

  GeneratedColumn<int> get freeMaxLists => $composableBuilder(
    column: $table.freeMaxLists,
    builder: (column) => column,
  );

  GeneratedColumn<int> get basicMaxLists => $composableBuilder(
    column: $table.basicMaxLists,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proMaxLists => $composableBuilder(
    column: $table.proMaxLists,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyBudgetArs => $composableBuilder(
    column: $table.monthlyBudgetArs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPreferencesTable,
          UserPreferencesEntity,
          $$LocalPreferencesTableFilterComposer,
          $$LocalPreferencesTableOrderingComposer,
          $$LocalPreferencesTableAnnotationComposer,
          $$LocalPreferencesTableCreateCompanionBuilder,
          $$LocalPreferencesTableUpdateCompanionBuilder,
          (
            UserPreferencesEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalPreferencesTable,
              UserPreferencesEntity
            >,
          ),
          UserPreferencesEntity,
          PrefetchHooks Function()
        > {
  $$LocalPreferencesTableTableManager(
    _$AppDatabase db,
    $LocalPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> keepScreenOn = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<String> avatarChoice = const Value.absent(),
                Value<String?> googlePhotoUrl = const Value.absent(),
                Value<String> planTier = const Value.absent(),
                Value<int> freeMaxLists = const Value.absent(),
                Value<int> basicMaxLists = const Value.absent(),
                Value<int> proMaxLists = const Value.absent(),
                Value<double?> monthlyBudgetArs = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalPreferencesCompanion(
                id: id,
                city: city,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                keepScreenOn: keepScreenOn,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
                avatarChoice: avatarChoice,
                googlePhotoUrl: googlePhotoUrl,
                planTier: planTier,
                freeMaxLists: freeMaxLists,
                basicMaxLists: basicMaxLists,
                proMaxLists: proMaxLists,
                monthlyBudgetArs: monthlyBudgetArs,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> keepScreenOn = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<String> avatarChoice = const Value.absent(),
                Value<String?> googlePhotoUrl = const Value.absent(),
                Value<String> planTier = const Value.absent(),
                Value<int> freeMaxLists = const Value.absent(),
                Value<int> basicMaxLists = const Value.absent(),
                Value<int> proMaxLists = const Value.absent(),
                Value<double?> monthlyBudgetArs = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalPreferencesCompanion.insert(
                id: id,
                city: city,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                keepScreenOn: keepScreenOn,
                soundEnabled: soundEnabled,
                vibrationEnabled: vibrationEnabled,
                avatarChoice: avatarChoice,
                googlePhotoUrl: googlePhotoUrl,
                planTier: planTier,
                freeMaxLists: freeMaxLists,
                basicMaxLists: basicMaxLists,
                proMaxLists: proMaxLists,
                monthlyBudgetArs: monthlyBudgetArs,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalPreferencesTable, UserPreferencesEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalPreferencesTable,
                    UserPreferencesEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPreferencesTable,
      UserPreferencesEntity,
      $$LocalPreferencesTableFilterComposer,
      $$LocalPreferencesTableOrderingComposer,
      $$LocalPreferencesTableAnnotationComposer,
      $$LocalPreferencesTableCreateCompanionBuilder,
      $$LocalPreferencesTableUpdateCompanionBuilder,
      (
        UserPreferencesEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalPreferencesTable,
          UserPreferencesEntity
        >,
      ),
      UserPreferencesEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalPendingDeletionsTableCreateCompanionBuilder =
    LocalPendingDeletionsCompanion Function({
      required String id,
      required String entityType,
      required String entityKey,
      Value<bool> isLeaveOnly,
      required DateTime deletedAt,
      Value<int> rowid,
    });
typedef $$LocalPendingDeletionsTableUpdateCompanionBuilder =
    LocalPendingDeletionsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityKey,
      Value<bool> isLeaveOnly,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

class $$LocalPendingDeletionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPendingDeletionsTable> {
  $$LocalPendingDeletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeaveOnly => $composableBuilder(
    column: $table.isLeaveOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPendingDeletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPendingDeletionsTable> {
  $$LocalPendingDeletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeaveOnly => $composableBuilder(
    column: $table.isLeaveOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPendingDeletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPendingDeletionsTable> {
  $$LocalPendingDeletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<bool> get isLeaveOnly => $composableBuilder(
    column: $table.isLeaveOnly,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalPendingDeletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPendingDeletionsTable,
          PendingDeletionEntity,
          $$LocalPendingDeletionsTableFilterComposer,
          $$LocalPendingDeletionsTableOrderingComposer,
          $$LocalPendingDeletionsTableAnnotationComposer,
          $$LocalPendingDeletionsTableCreateCompanionBuilder,
          $$LocalPendingDeletionsTableUpdateCompanionBuilder,
          (
            PendingDeletionEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalPendingDeletionsTable,
              PendingDeletionEntity
            >,
          ),
          PendingDeletionEntity,
          PrefetchHooks Function()
        > {
  $$LocalPendingDeletionsTableTableManager(
    _$AppDatabase db,
    $LocalPendingDeletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPendingDeletionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalPendingDeletionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPendingDeletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityKey = const Value.absent(),
                Value<bool> isLeaveOnly = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPendingDeletionsCompanion(
                id: id,
                entityType: entityType,
                entityKey: entityKey,
                isLeaveOnly: isLeaveOnly,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityKey,
                Value<bool> isLeaveOnly = const Value.absent(),
                required DateTime deletedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalPendingDeletionsCompanion.insert(
                id: id,
                entityType: entityType,
                entityKey: entityKey,
                isLeaveOnly: isLeaveOnly,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $LocalPendingDeletionsTable,
                    PendingDeletionEntity
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalPendingDeletionsTable,
                    PendingDeletionEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPendingDeletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPendingDeletionsTable,
      PendingDeletionEntity,
      $$LocalPendingDeletionsTableFilterComposer,
      $$LocalPendingDeletionsTableOrderingComposer,
      $$LocalPendingDeletionsTableAnnotationComposer,
      $$LocalPendingDeletionsTableCreateCompanionBuilder,
      $$LocalPendingDeletionsTableUpdateCompanionBuilder,
      (
        PendingDeletionEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalPendingDeletionsTable,
          PendingDeletionEntity
        >,
      ),
      PendingDeletionEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalCachedAdsTableCreateCompanionBuilder =
    LocalCachedAdsCompanion Function({
      required String id,
      required String businessName,
      required String city,
      required String tier,
      Value<String?> bannerUrl,
      Value<String?> interstitialUrl,
      required String actionUrl,
      required DateTime expiresAt,
      Value<bool> isActive,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$LocalCachedAdsTableUpdateCompanionBuilder =
    LocalCachedAdsCompanion Function({
      Value<String> id,
      Value<String> businessName,
      Value<String> city,
      Value<String> tier,
      Value<String?> bannerUrl,
      Value<String?> interstitialUrl,
      Value<String> actionUrl,
      Value<DateTime> expiresAt,
      Value<bool> isActive,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LocalCachedAdsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCachedAdsTable> {
  $$LocalCachedAdsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bannerUrl => $composableBuilder(
    column: $table.bannerUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interstitialUrl => $composableBuilder(
    column: $table.interstitialUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionUrl => $composableBuilder(
    column: $table.actionUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCachedAdsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCachedAdsTable> {
  $$LocalCachedAdsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bannerUrl => $composableBuilder(
    column: $table.bannerUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interstitialUrl => $composableBuilder(
    column: $table.interstitialUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionUrl => $composableBuilder(
    column: $table.actionUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCachedAdsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCachedAdsTable> {
  $$LocalCachedAdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
    column: $table.businessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get bannerUrl =>
      $composableBuilder(column: $table.bannerUrl, builder: (column) => column);

  GeneratedColumn<String> get interstitialUrl => $composableBuilder(
    column: $table.interstitialUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionUrl =>
      $composableBuilder(column: $table.actionUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalCachedAdsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCachedAdsTable,
          CachedAdEntity,
          $$LocalCachedAdsTableFilterComposer,
          $$LocalCachedAdsTableOrderingComposer,
          $$LocalCachedAdsTableAnnotationComposer,
          $$LocalCachedAdsTableCreateCompanionBuilder,
          $$LocalCachedAdsTableUpdateCompanionBuilder,
          (
            CachedAdEntity,
            BaseReferences<_$AppDatabase, $LocalCachedAdsTable, CachedAdEntity>,
          ),
          CachedAdEntity,
          PrefetchHooks Function()
        > {
  $$LocalCachedAdsTableTableManager(
    _$AppDatabase db,
    $LocalCachedAdsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCachedAdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCachedAdsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCachedAdsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessName = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String?> bannerUrl = const Value.absent(),
                Value<String?> interstitialUrl = const Value.absent(),
                Value<String> actionUrl = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCachedAdsCompanion(
                id: id,
                businessName: businessName,
                city: city,
                tier: tier,
                bannerUrl: bannerUrl,
                interstitialUrl: interstitialUrl,
                actionUrl: actionUrl,
                expiresAt: expiresAt,
                isActive: isActive,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessName,
                required String city,
                required String tier,
                Value<String?> bannerUrl = const Value.absent(),
                Value<String?> interstitialUrl = const Value.absent(),
                required String actionUrl,
                required DateTime expiresAt,
                Value<bool> isActive = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalCachedAdsCompanion.insert(
                id: id,
                businessName: businessName,
                city: city,
                tier: tier,
                bannerUrl: bannerUrl,
                interstitialUrl: interstitialUrl,
                actionUrl: actionUrl,
                expiresAt: expiresAt,
                isActive: isActive,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCachedAdsTable, CachedAdEntity>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalCachedAdsTable,
                    CachedAdEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCachedAdsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCachedAdsTable,
      CachedAdEntity,
      $$LocalCachedAdsTableFilterComposer,
      $$LocalCachedAdsTableOrderingComposer,
      $$LocalCachedAdsTableAnnotationComposer,
      $$LocalCachedAdsTableCreateCompanionBuilder,
      $$LocalCachedAdsTableUpdateCompanionBuilder,
      (
        CachedAdEntity,
        BaseReferences<_$AppDatabase, $LocalCachedAdsTable, CachedAdEntity>,
      ),
      CachedAdEntity,
      PrefetchHooks Function()
    >;
typedef $$LocalExpenseHistoryTableCreateCompanionBuilder =
    LocalExpenseHistoryCompanion Function({
      required String id,
      Value<String?> listId,
      required String listTitle,
      required String storeCategory,
      required double totalAmount,
      Value<int> itemCount,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$LocalExpenseHistoryTableUpdateCompanionBuilder =
    LocalExpenseHistoryCompanion Function({
      Value<String> id,
      Value<String?> listId,
      Value<String> listTitle,
      Value<String> storeCategory,
      Value<double> totalAmount,
      Value<int> itemCount,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$LocalExpenseHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExpenseHistoryTable> {
  $$LocalExpenseHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listTitle => $composableBuilder(
    column: $table.listTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpenseHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExpenseHistoryTable> {
  $$LocalExpenseHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listTitle => $composableBuilder(
    column: $table.listTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpenseHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExpenseHistoryTable> {
  $$LocalExpenseHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get listTitle =>
      $composableBuilder(column: $table.listTitle, builder: (column) => column);

  GeneratedColumn<String> get storeCategory => $composableBuilder(
    column: $table.storeCategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$LocalExpenseHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExpenseHistoryTable,
          ExpenseHistoryEntity,
          $$LocalExpenseHistoryTableFilterComposer,
          $$LocalExpenseHistoryTableOrderingComposer,
          $$LocalExpenseHistoryTableAnnotationComposer,
          $$LocalExpenseHistoryTableCreateCompanionBuilder,
          $$LocalExpenseHistoryTableUpdateCompanionBuilder,
          (
            ExpenseHistoryEntity,
            BaseReferences<
              _$AppDatabase,
              $LocalExpenseHistoryTable,
              ExpenseHistoryEntity
            >,
          ),
          ExpenseHistoryEntity,
          PrefetchHooks Function()
        > {
  $$LocalExpenseHistoryTableTableManager(
    _$AppDatabase db,
    $LocalExpenseHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpenseHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpenseHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalExpenseHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> listId = const Value.absent(),
                Value<String> listTitle = const Value.absent(),
                Value<String> storeCategory = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpenseHistoryCompanion(
                id: id,
                listId: listId,
                listTitle: listTitle,
                storeCategory: storeCategory,
                totalAmount: totalAmount,
                itemCount: itemCount,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> listId = const Value.absent(),
                required String listTitle,
                required String storeCategory,
                required double totalAmount,
                Value<int> itemCount = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalExpenseHistoryCompanion.insert(
                id: id,
                listId: listId,
                listTitle: listTitle,
                storeCategory: storeCategory,
                totalAmount: totalAmount,
                itemCount: itemCount,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalExpenseHistoryTable, ExpenseHistoryEntity>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalExpenseHistoryTable,
                    ExpenseHistoryEntity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpenseHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExpenseHistoryTable,
      ExpenseHistoryEntity,
      $$LocalExpenseHistoryTableFilterComposer,
      $$LocalExpenseHistoryTableOrderingComposer,
      $$LocalExpenseHistoryTableAnnotationComposer,
      $$LocalExpenseHistoryTableCreateCompanionBuilder,
      $$LocalExpenseHistoryTableUpdateCompanionBuilder,
      (
        ExpenseHistoryEntity,
        BaseReferences<
          _$AppDatabase,
          $LocalExpenseHistoryTable,
          ExpenseHistoryEntity
        >,
      ),
      ExpenseHistoryEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalListsTableTableManager get localLists =>
      $$LocalListsTableTableManager(_db, _db.localLists);
  $$LocalItemsTableTableManager get localItems =>
      $$LocalItemsTableTableManager(_db, _db.localItems);
  $$LocalAisleOrderTableTableManager get localAisleOrder =>
      $$LocalAisleOrderTableTableManager(_db, _db.localAisleOrder);
  $$LocalLearnedItemsTableTableManager get localLearnedItems =>
      $$LocalLearnedItemsTableTableManager(_db, _db.localLearnedItems);
  $$LocalPreferencesTableTableManager get localPreferences =>
      $$LocalPreferencesTableTableManager(_db, _db.localPreferences);
  $$LocalPendingDeletionsTableTableManager get localPendingDeletions =>
      $$LocalPendingDeletionsTableTableManager(_db, _db.localPendingDeletions);
  $$LocalCachedAdsTableTableManager get localCachedAds =>
      $$LocalCachedAdsTableTableManager(_db, _db.localCachedAds);
  $$LocalExpenseHistoryTableTableManager get localExpenseHistory =>
      $$LocalExpenseHistoryTableTableManager(_db, _db.localExpenseHistory);
}
