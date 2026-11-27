import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// 卡片集缓存（服务端 `decks` 的本地副本）。
///
/// 列名与后端保持一致（snake_case），`config` / `stats` 以 JSON 原文存放，
/// 客户端不解析其内部结构——这样接后端时不需要写字段映射。
class LocalDecks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant(''))();
  TextColumn get cardType => text().withDefault(const Constant('memory'))();
  TextColumn get folderId => text().nullable()();
  TextColumn get config => text().withDefault(const Constant('{}'))();
  TextColumn get stats => text().withDefault(const Constant('{}'))();

  /// 本地新建时间（毫秒），用于保持列表顺序；接后端后改用服务端 `created_at`。
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// 软删除（`docs/02` FR-2.5 回收站）；非空表示已删除。
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 卡片缓存（服务端 `cards` 的本地副本）。
class LocalCards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text()();
  TextColumn get cardType => text().withDefault(const Constant('memory'))();

  /// `cards.fields` 的 JSON 原文（含 plaintext / ciphertext / hint / extra / question）。
  TextColumn get fields => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 本地缓存数据库。
///
/// 只存「服务端数据的副本」，不存排程结果、不计算 `due_at`（ADR-004 / ADR-006）。
@DriftDatabase(tables: <Type>[LocalDecks, LocalCards])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}
