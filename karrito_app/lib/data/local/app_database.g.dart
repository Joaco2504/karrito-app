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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const ShoppingListEntity({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LocalListsCompanion toCompanion(bool nullToAbsent) {
    return LocalListsCompanion(
      id: Value(id),
      title: Value(title),
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ShoppingListEntity copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => ShoppingListEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ShoppingListEntity copyWithCompanion(LocalListsCompanion data) {
    return ShoppingListEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalListsCompanion extends UpdateCompanion<ShoppingListEntity> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LocalListsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalListsCompanion.insert({
    required String id,
    required String title,
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
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalListsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LocalListsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
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
  @override
  List<GeneratedColumn> get $columns => [storeCategory, aisleName, sortOrder];
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
  const AisleOrderEntity({
    required this.storeCategory,
    required this.aisleName,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['store_category'] = Variable<String>(storeCategory);
    map['aisle_name'] = Variable<String>(aisleName);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalAisleOrderCompanion toCompanion(bool nullToAbsent) {
    return LocalAisleOrderCompanion(
      storeCategory: Value(storeCategory),
      aisleName: Value(aisleName),
      sortOrder: Value(sortOrder),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storeCategory': serializer.toJson<String>(storeCategory),
      'aisleName': serializer.toJson<String>(aisleName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AisleOrderEntity copyWith({
    String? storeCategory,
    String? aisleName,
    int? sortOrder,
  }) => AisleOrderEntity(
    storeCategory: storeCategory ?? this.storeCategory,
    aisleName: aisleName ?? this.aisleName,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AisleOrderEntity copyWithCompanion(LocalAisleOrderCompanion data) {
    return AisleOrderEntity(
      storeCategory: data.storeCategory.present
          ? data.storeCategory.value
          : this.storeCategory,
      aisleName: data.aisleName.present ? data.aisleName.value : this.aisleName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AisleOrderEntity(')
          ..write('storeCategory: $storeCategory, ')
          ..write('aisleName: $aisleName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(storeCategory, aisleName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AisleOrderEntity &&
          other.storeCategory == this.storeCategory &&
          other.aisleName == this.aisleName &&
          other.sortOrder == this.sortOrder);
}

class LocalAisleOrderCompanion extends UpdateCompanion<AisleOrderEntity> {
  final Value<String> storeCategory;
  final Value<String> aisleName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LocalAisleOrderCompanion({
    this.storeCategory = const Value.absent(),
    this.aisleName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAisleOrderCompanion.insert({
    required String storeCategory,
    required String aisleName,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : storeCategory = Value(storeCategory),
       aisleName = Value(aisleName),
       sortOrder = Value(sortOrder);
  static Insertable<AisleOrderEntity> custom({
    Expression<String>? storeCategory,
    Expression<String>? aisleName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storeCategory != null) 'store_category': storeCategory,
      if (aisleName != null) 'aisle_name': aisleName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAisleOrderCompanion copyWith({
    Value<String>? storeCategory,
    Value<String>? aisleName,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LocalAisleOrderCompanion(
      storeCategory: storeCategory ?? this.storeCategory,
      aisleName: aisleName ?? this.aisleName,
      sortOrder: sortOrder ?? this.sortOrder,
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
  @override
  List<GeneratedColumn> get $columns => [
    normalizedName,
    preferredStore,
    preferredAisle,
    useCount,
    updatedAt,
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
  final String preferredStore;
  final String preferredAisle;
  final int useCount;
  final DateTime updatedAt;
  const LearnedItemEntity({
    required this.normalizedName,
    required this.preferredStore,
    required this.preferredAisle,
    required this.useCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_name'] = Variable<String>(normalizedName);
    map['preferred_store'] = Variable<String>(preferredStore);
    map['preferred_aisle'] = Variable<String>(preferredAisle);
    map['use_count'] = Variable<int>(useCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalLearnedItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalLearnedItemsCompanion(
      normalizedName: Value(normalizedName),
      preferredStore: Value(preferredStore),
      preferredAisle: Value(preferredAisle),
      useCount: Value(useCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory LearnedItemEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedItemEntity(
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      preferredStore: serializer.fromJson<String>(json['preferredStore']),
      preferredAisle: serializer.fromJson<String>(json['preferredAisle']),
      useCount: serializer.fromJson<int>(json['useCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedName': serializer.toJson<String>(normalizedName),
      'preferredStore': serializer.toJson<String>(preferredStore),
      'preferredAisle': serializer.toJson<String>(preferredAisle),
      'useCount': serializer.toJson<int>(useCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LearnedItemEntity copyWith({
    String? normalizedName,
    String? preferredStore,
    String? preferredAisle,
    int? useCount,
    DateTime? updatedAt,
  }) => LearnedItemEntity(
    normalizedName: normalizedName ?? this.normalizedName,
    preferredStore: preferredStore ?? this.preferredStore,
    preferredAisle: preferredAisle ?? this.preferredAisle,
    useCount: useCount ?? this.useCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LearnedItemEntity copyWithCompanion(LocalLearnedItemsCompanion data) {
    return LearnedItemEntity(
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      preferredStore: data.preferredStore.present
          ? data.preferredStore.value
          : this.preferredStore,
      preferredAisle: data.preferredAisle.present
          ? data.preferredAisle.value
          : this.preferredAisle,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedItemEntity(')
          ..write('normalizedName: $normalizedName, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('preferredAisle: $preferredAisle, ')
          ..write('useCount: $useCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    normalizedName,
    preferredStore,
    preferredAisle,
    useCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedItemEntity &&
          other.normalizedName == this.normalizedName &&
          other.preferredStore == this.preferredStore &&
          other.preferredAisle == this.preferredAisle &&
          other.useCount == this.useCount &&
          other.updatedAt == this.updatedAt);
}

class LocalLearnedItemsCompanion extends UpdateCompanion<LearnedItemEntity> {
  final Value<String> normalizedName;
  final Value<String> preferredStore;
  final Value<String> preferredAisle;
  final Value<int> useCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalLearnedItemsCompanion({
    this.normalizedName = const Value.absent(),
    this.preferredStore = const Value.absent(),
    this.preferredAisle = const Value.absent(),
    this.useCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLearnedItemsCompanion.insert({
    required String normalizedName,
    required String preferredStore,
    required String preferredAisle,
    this.useCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : normalizedName = Value(normalizedName),
       preferredStore = Value(preferredStore),
       preferredAisle = Value(preferredAisle),
       updatedAt = Value(updatedAt);
  static Insertable<LearnedItemEntity> custom({
    Expression<String>? normalizedName,
    Expression<String>? preferredStore,
    Expression<String>? preferredAisle,
    Expression<int>? useCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (preferredStore != null) 'preferred_store': preferredStore,
      if (preferredAisle != null) 'preferred_aisle': preferredAisle,
      if (useCount != null) 'use_count': useCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLearnedItemsCompanion copyWith({
    Value<String>? normalizedName,
    Value<String>? preferredStore,
    Value<String>? preferredAisle,
    Value<int>? useCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalLearnedItemsCompanion(
      normalizedName: normalizedName ?? this.normalizedName,
      preferredStore: preferredStore ?? this.preferredStore,
      preferredAisle: preferredAisle ?? this.preferredAisle,
      useCount: useCount ?? this.useCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLearnedItemsCompanion(')
          ..write('normalizedName: $normalizedName, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('preferredAisle: $preferredAisle, ')
          ..write('useCount: $useCount, ')
          ..write('updatedAt: $updatedAt, ')
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    city,
    themeMode,
    onboardingCompleted,
    keepScreenOn,
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
  const UserPreferencesEntity({
    required this.id,
    required this.city,
    required this.themeMode,
    required this.onboardingCompleted,
    required this.keepScreenOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['city'] = Variable<String>(city);
    map['theme_mode'] = Variable<String>(themeMode);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['keep_screen_on'] = Variable<bool>(keepScreenOn);
    return map;
  }

  LocalPreferencesCompanion toCompanion(bool nullToAbsent) {
    return LocalPreferencesCompanion(
      id: Value(id),
      city: Value(city),
      themeMode: Value(themeMode),
      onboardingCompleted: Value(onboardingCompleted),
      keepScreenOn: Value(keepScreenOn),
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
    };
  }

  UserPreferencesEntity copyWith({
    int? id,
    String? city,
    String? themeMode,
    bool? onboardingCompleted,
    bool? keepScreenOn,
  }) => UserPreferencesEntity(
    id: id ?? this.id,
    city: city ?? this.city,
    themeMode: themeMode ?? this.themeMode,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesEntity(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('keepScreenOn: $keepScreenOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, city, themeMode, onboardingCompleted, keepScreenOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferencesEntity &&
          other.id == this.id &&
          other.city == this.city &&
          other.themeMode == this.themeMode &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.keepScreenOn == this.keepScreenOn);
}

class LocalPreferencesCompanion extends UpdateCompanion<UserPreferencesEntity> {
  final Value<int> id;
  final Value<String> city;
  final Value<String> themeMode;
  final Value<bool> onboardingCompleted;
  final Value<bool> keepScreenOn;
  const LocalPreferencesCompanion({
    this.id = const Value.absent(),
    this.city = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
  });
  LocalPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.city = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.keepScreenOn = const Value.absent(),
  });
  static Insertable<UserPreferencesEntity> custom({
    Expression<int>? id,
    Expression<String>? city,
    Expression<String>? themeMode,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? keepScreenOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (city != null) 'city': city,
      if (themeMode != null) 'theme_mode': themeMode,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (keepScreenOn != null) 'keep_screen_on': keepScreenOn,
    });
  }

  LocalPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? city,
    Value<String>? themeMode,
    Value<bool>? onboardingCompleted,
    Value<bool>? keepScreenOn,
  }) {
    return LocalPreferencesCompanion(
      id: id ?? this.id,
      city: city ?? this.city,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('city: $city, ')
          ..write('themeMode: $themeMode, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('keepScreenOn: $keepScreenOn')
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
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$LocalListsTableUpdateCompanionBuilder =
    LocalListsCompanion Function({
      Value<String> id,
      Value<String> title,
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalListsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalListsCompanion.insert(
                id: id,
                title: title,
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
      Value<int> rowid,
    });
typedef $$LocalAisleOrderTableUpdateCompanionBuilder =
    LocalAisleOrderCompanion Function({
      Value<String> storeCategory,
      Value<String> aisleName,
      Value<int> sortOrder,
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
                Value<int> rowid = const Value.absent(),
              }) => LocalAisleOrderCompanion(
                storeCategory: storeCategory,
                aisleName: aisleName,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storeCategory,
                required String aisleName,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LocalAisleOrderCompanion.insert(
                storeCategory: storeCategory,
                aisleName: aisleName,
                sortOrder: sortOrder,
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
      required String preferredStore,
      required String preferredAisle,
      Value<int> useCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalLearnedItemsTableUpdateCompanionBuilder =
    LocalLearnedItemsCompanion Function({
      Value<String> normalizedName,
      Value<String> preferredStore,
      Value<String> preferredAisle,
      Value<int> useCount,
      Value<DateTime> updatedAt,
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
                Value<String> preferredStore = const Value.absent(),
                Value<String> preferredAisle = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLearnedItemsCompanion(
                normalizedName: normalizedName,
                preferredStore: preferredStore,
                preferredAisle: preferredAisle,
                useCount: useCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedName,
                required String preferredStore,
                required String preferredAisle,
                Value<int> useCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalLearnedItemsCompanion.insert(
                normalizedName: normalizedName,
                preferredStore: preferredStore,
                preferredAisle: preferredAisle,
                useCount: useCount,
                updatedAt: updatedAt,
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
    });
typedef $$LocalPreferencesTableUpdateCompanionBuilder =
    LocalPreferencesCompanion Function({
      Value<int> id,
      Value<String> city,
      Value<String> themeMode,
      Value<bool> onboardingCompleted,
      Value<bool> keepScreenOn,
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
              }) => LocalPreferencesCompanion(
                id: id,
                city: city,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                keepScreenOn: keepScreenOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> keepScreenOn = const Value.absent(),
              }) => LocalPreferencesCompanion.insert(
                id: id,
                city: city,
                themeMode: themeMode,
                onboardingCompleted: onboardingCompleted,
                keepScreenOn: keepScreenOn,
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
}
