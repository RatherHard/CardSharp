// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalDecksTable extends LocalDecks with TableInfo<$LocalDecksTable, LocalDeck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta('cardType');
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('memory'),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _statsMeta = const VerificationMeta('stats');
  @override
  late final GeneratedColumn<String> stats = GeneratedColumn<String>(
    'stats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    color,
    cardType,
    folderId,
    config,
    stats,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDeck> instance, {
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
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(data['description']!, _descriptionMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta, config.isAcceptableOrUnknown(data['config']!, _configMeta));
    }
    if (data.containsKey('stats')) {
      context.handle(_statsMeta, stats.isAcceptableOrUnknown(data['stats']!, _statsMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDeck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDeck(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      )!,
      stats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalDecksTable createAlias(String alias) {
    return $LocalDecksTable(attachedDatabase, alias);
  }
}

class LocalDeck extends DataClass implements Insertable<LocalDeck> {
  final String id;
  final String title;
  final String description;
  final String color;
  final String cardType;
  final String? folderId;
  final String config;
  final String stats;

  /// 本地新建时间（毫秒），用于保持列表顺序；接后端后改用服务端 `created_at`。
  final int createdAt;
  final int updatedAt;

  /// 软删除（`docs/02` FR-2.5 回收站）；非空表示已删除。
  final int? deletedAt;
  const LocalDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.cardType,
    this.folderId,
    required this.config,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['color'] = Variable<String>(color);
    map['card_type'] = Variable<String>(cardType);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['config'] = Variable<String>(config);
    map['stats'] = Variable<String>(stats);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  LocalDecksCompanion toCompanion(bool nullToAbsent) {
    return LocalDecksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      color: Value(color),
      cardType: Value(cardType),
      folderId: folderId == null && nullToAbsent ? const Value.absent() : Value(folderId),
      config: Value(config),
      stats: Value(stats),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory LocalDeck.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDeck(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      color: serializer.fromJson<String>(json['color']),
      cardType: serializer.fromJson<String>(json['cardType']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      config: serializer.fromJson<String>(json['config']),
      stats: serializer.fromJson<String>(json['stats']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'color': serializer.toJson<String>(color),
      'cardType': serializer.toJson<String>(cardType),
      'folderId': serializer.toJson<String?>(folderId),
      'config': serializer.toJson<String>(config),
      'stats': serializer.toJson<String>(stats),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  LocalDeck copyWith({
    String? id,
    String? title,
    String? description,
    String? color,
    String? cardType,
    Value<String?> folderId = const Value.absent(),
    String? config,
    String? stats,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => LocalDeck(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    color: color ?? this.color,
    cardType: cardType ?? this.cardType,
    folderId: folderId.present ? folderId.value : this.folderId,
    config: config ?? this.config,
    stats: stats ?? this.stats,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalDeck copyWithCompanion(LocalDecksCompanion data) {
    return LocalDeck(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      config: data.config.present ? data.config.value : this.config,
      stats: data.stats.present ? data.stats.value : this.stats,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDeck(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('cardType: $cardType, ')
          ..write('folderId: $folderId, ')
          ..write('config: $config, ')
          ..write('stats: $stats, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    color,
    cardType,
    folderId,
    config,
    stats,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDeck &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.color == this.color &&
          other.cardType == this.cardType &&
          other.folderId == this.folderId &&
          other.config == this.config &&
          other.stats == this.stats &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalDecksCompanion extends UpdateCompanion<LocalDeck> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> color;
  final Value<String> cardType;
  final Value<String?> folderId;
  final Value<String> config;
  final Value<String> stats;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const LocalDecksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.cardType = const Value.absent(),
    this.folderId = const Value.absent(),
    this.config = const Value.absent(),
    this.stats = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDecksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.cardType = const Value.absent(),
    this.folderId = const Value.absent(),
    this.config = const Value.absent(),
    this.stats = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalDeck> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? color,
    Expression<String>? cardType,
    Expression<String>? folderId,
    Expression<String>? config,
    Expression<String>? stats,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (cardType != null) 'card_type': cardType,
      if (folderId != null) 'folder_id': folderId,
      if (config != null) 'config': config,
      if (stats != null) 'stats': stats,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDecksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? color,
    Value<String>? cardType,
    Value<String?>? folderId,
    Value<String>? config,
    Value<String>? stats,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalDecksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      cardType: cardType ?? this.cardType,
      folderId: folderId ?? this.folderId,
      config: config ?? this.config,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (stats.present) {
      map['stats'] = Variable<String>(stats.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDecksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('cardType: $cardType, ')
          ..write('folderId: $folderId, ')
          ..write('config: $config, ')
          ..write('stats: $stats, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCardsTable extends LocalCards with TableInfo<$LocalCardsTable, LocalCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta('cardType');
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('memory'),
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    cardType,
    fields,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta, deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    }
    if (data.containsKey('fields')) {
      context.handle(_fieldsMeta, fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta));
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCard(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LocalCardsTable createAlias(String alias) {
    return $LocalCardsTable(attachedDatabase, alias);
  }
}

class LocalCard extends DataClass implements Insertable<LocalCard> {
  final String id;
  final String deckId;
  final String cardType;

  /// `cards.fields` 的 JSON 原文（含 plaintext / ciphertext / hint / extra / question）。
  final String fields;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const LocalCard({
    required this.id,
    required this.deckId,
    required this.cardType,
    required this.fields,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['card_type'] = Variable<String>(cardType);
    map['fields'] = Variable<String>(fields);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  LocalCardsCompanion toCompanion(bool nullToAbsent) {
    return LocalCardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      cardType: Value(cardType),
      fields: Value(fields),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory LocalCard.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCard(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      cardType: serializer.fromJson<String>(json['cardType']),
      fields: serializer.fromJson<String>(json['fields']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'cardType': serializer.toJson<String>(cardType),
      'fields': serializer.toJson<String>(fields),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  LocalCard copyWith({
    String? id,
    String? deckId,
    String? cardType,
    String? fields,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => LocalCard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    cardType: cardType ?? this.cardType,
    fields: fields ?? this.fields,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LocalCard copyWithCompanion(LocalCardsCompanion data) {
    return LocalCard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      fields: data.fields.present ? data.fields.value : this.fields,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('cardType: $cardType, ')
          ..write('fields: $fields, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deckId, cardType, fields, sortOrder, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.cardType == this.cardType &&
          other.fields == this.fields &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LocalCardsCompanion extends UpdateCompanion<LocalCard> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> cardType;
  final Value<String> fields;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const LocalCardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.cardType = const Value.absent(),
    this.fields = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCardsCompanion.insert({
    required String id,
    required String deckId,
    this.cardType = const Value.absent(),
    required String fields,
    this.sortOrder = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       fields = Value(fields),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCard> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? cardType,
    Expression<String>? fields,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (cardType != null) 'card_type': cardType,
      if (fields != null) 'fields': fields,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? cardType,
    Value<String>? fields,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LocalCardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      cardType: cardType ?? this.cardType,
      fields: fields ?? this.fields,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('cardType: $cardType, ')
          ..write('fields: $fields, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalDecksTable localDecks = $LocalDecksTable(this);
  late final $LocalCardsTable localCards = $LocalCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localDecks, localCards];
}

typedef $$LocalDecksTableCreateCompanionBuilder = LocalDecksCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<String> color,
  Value<String> cardType,
  Value<String?> folderId,
  Value<String> config,
  Value<String> stats,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$LocalDecksTableUpdateCompanionBuilder = LocalDecksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> color,
  Value<String> cardType,
  Value<String?> folderId,
  Value<String> config,
  Value<String> stats,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$LocalDecksTableFilterComposer extends Composer<_$AppDatabase, $LocalDecksTable> {
  $$LocalDecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stats =>
      $composableBuilder(column: $table.stats, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalDecksTableOrderingComposer extends Composer<_$AppDatabase, $LocalDecksTable> {
  $$LocalDecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stats =>
      $composableBuilder(column: $table.stats, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalDecksTableAnnotationComposer extends Composer<_$AppDatabase, $LocalDecksTable> {
  $$LocalDecksTableAnnotationComposer({
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

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<String> get stats =>
      $composableBuilder(column: $table.stats, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDecksTable,
          LocalDeck,
          $$LocalDecksTableFilterComposer,
          $$LocalDecksTableOrderingComposer,
          $$LocalDecksTableAnnotationComposer,
          $$LocalDecksTableCreateCompanionBuilder,
          $$LocalDecksTableUpdateCompanionBuilder,
          (LocalDeck, BaseReferences<_$AppDatabase, $LocalDecksTable, LocalDeck>),
          LocalDeck,
          PrefetchHooks Function()
        > {
  $$LocalDecksTableTableManager(_$AppDatabase db, $LocalDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<String> stats = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDecksCompanion(
                id: id,
                title: title,
                description: description,
                color: color,
                cardType: cardType,
                folderId: folderId,
                config: config,
                stats: stats,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<String> stats = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDecksCompanion.insert(
                id: id,
                title: title,
                description: description,
                color: color,
                cardType: cardType,
                folderId: folderId,
                config: config,
                stats: stats,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalDecksTable, LocalDeck>(table),
                  BaseReferences<_$AppDatabase, $LocalDecksTable, LocalDeck>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDecksTable,
      LocalDeck,
      $$LocalDecksTableFilterComposer,
      $$LocalDecksTableOrderingComposer,
      $$LocalDecksTableAnnotationComposer,
      $$LocalDecksTableCreateCompanionBuilder,
      $$LocalDecksTableUpdateCompanionBuilder,
      (LocalDeck, BaseReferences<_$AppDatabase, $LocalDecksTable, LocalDeck>),
      LocalDeck,
      PrefetchHooks Function()
    >;
typedef $$LocalCardsTableCreateCompanionBuilder = LocalCardsCompanion Function({
  required String id,
  required String deckId,
  Value<String> cardType,
  required String fields,
  Value<int> sortOrder,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$LocalCardsTableUpdateCompanionBuilder = LocalCardsCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> cardType,
  Value<String> fields,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$LocalCardsTableFilterComposer extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCardsTableOrderingComposer extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalCardsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalCardsTable> {
  $$LocalCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$LocalCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCardsTable,
          LocalCard,
          $$LocalCardsTableFilterComposer,
          $$LocalCardsTableOrderingComposer,
          $$LocalCardsTableAnnotationComposer,
          $$LocalCardsTableCreateCompanionBuilder,
          $$LocalCardsTableUpdateCompanionBuilder,
          (LocalCard, BaseReferences<_$AppDatabase, $LocalCardsTable, LocalCard>),
          LocalCard,
          PrefetchHooks Function()
        > {
  $$LocalCardsTableTableManager(_$AppDatabase db, $LocalCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> cardType = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCardsCompanion(
                id: id,
                deckId: deckId,
                cardType: cardType,
                fields: fields,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                Value<String> cardType = const Value.absent(),
                required String fields,
                Value<int> sortOrder = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCardsCompanion.insert(
                id: id,
                deckId: deckId,
                cardType: cardType,
                fields: fields,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCardsTable, LocalCard>(table),
                  BaseReferences<_$AppDatabase, $LocalCardsTable, LocalCard>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCardsTable,
      LocalCard,
      $$LocalCardsTableFilterComposer,
      $$LocalCardsTableOrderingComposer,
      $$LocalCardsTableAnnotationComposer,
      $$LocalCardsTableCreateCompanionBuilder,
      $$LocalCardsTableUpdateCompanionBuilder,
      (LocalCard, BaseReferences<_$AppDatabase, $LocalCardsTable, LocalCard>),
      LocalCard,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalDecksTableTableManager get localDecks =>
      $$LocalDecksTableTableManager(_db, _db.localDecks);
  $$LocalCardsTableTableManager get localCards =>
      $$LocalCardsTableTableManager(_db, _db.localCards);
}
