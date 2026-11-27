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

  /// 权威编号（服务端将来下发，如内置示例的 `example.naiwa-family`）。
  ///
  /// 服务的「身份」字段：拉取云端权威版时按它判断「本地这条是不是同一个卡片集」，
  /// 编号相同就整条覆盖。null 表示用户手工新建、还没有资格身份。
  TextColumn get sourceKey => text().nullable()();

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

  /// 这张卡片是「跟着哪次删除卡片集一起进来的」：存卡片集 id。
  ///
  /// 为 null 表示用户单独删掉了这张卡片（回收站顶层按「卡片」列出、并标注来源）；
  /// 非 null 表示它跟着那个卡片集进了回收站（只在回收站里的卡片集详情里出现）。
  /// 两者分开，才能做到「恢复整个卡片集只带回它带走的卡片」。
  TextColumn get deletedWithDeck => text().nullable()();

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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // v1 → v2：卡片增加「跟着哪个卡片集一起进回收站」的标记。
      // 老库里的卡片都是 v1 之前就存在的，没有回收站历史，补空列即可。
      if (from < 2) {
        await m.addColumn(localCards, localCards.deletedWithDeck);
      }
      // v2 → v3：卡片集增加权威编号。老卡片集都是用户自己建的，没有编号，补空列即可。
      if (from < 3) {
        await m.addColumn(localDecks, localDecks.sourceKey);
      }
    },
  );
}
