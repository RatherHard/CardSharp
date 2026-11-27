import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/network/page.dart';
import '../../../core/storage/app_database.dart';
import '../domain/deck.dart';
import '../domain/deck_repository.dart';
import '../domain/trashed_deck.dart';

/// 基于 Drift 的卡片集仓储：数据落在手机本地库里，重启不丢。
///
/// 与 `FakeDeckRepository` 实现同一个接口，所以页面、用例、Notifier 都不用改；
/// 接后端时再新增 `HttpDeckRepository` 并做「本地 + 远程」组合即可。
class LocalDeckRepository implements DeckRepository {
  LocalDeckRepository(this._db);

  final AppDatabase _db;

  /// 同一毫秒内连续新建时用来区分 id；否则主键会撞。
  static int _seq = 0;

  @override
  Future<PagedResult<Deck>> fetchDecks({String? cursor, int limit = 20}) async {
    final int offset = int.tryParse(cursor ?? '') ?? 0;
    final List<LocalDeck> rows =
        await (_db.select(_db.localDecks)
              ..where((LocalDecks t) => t.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(LocalDecks)>[
                (LocalDecks t) => OrderingTerm.asc(t.createdAt),
              ])
              ..limit(limit, offset: offset))
            .get();

    final Expression<int> totalExpr = _db.localDecks.id.count();
    final int total =
        (await (_db.selectOnly(_db.localDecks)
                  ..addColumns(<Expression<Object>>[totalExpr])
                  ..where(_db.localDecks.deletedAt.isNull()))
                .getSingle())
            .read(totalExpr) ??
        0;

    final List<Deck> decks = <Deck>[];
    for (final LocalDeck row in rows) {
      decks.add(await _toDeck(row));
    }
    return PagedResult<Deck>(
      items: List<Deck>.unmodifiable(decks),
      nextCursor: offset + rows.length < total ? '${offset + rows.length}' : null,
    );
  }

  @override
  Future<Deck> createDeck({
    required String title,
    String cardType = 'memory',
    Map<String, dynamic> config = const <String, dynamic>{},
  }) async {
    final String normalized = title.trim();
    if (normalized.isEmpty) {
      throw const DeckException(DeckFailure.titleRequired);
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    final LocalDeck row = LocalDeck(
      id: 'local-$now-${_seq++}',
      title: normalized,
      description: '',
      color: '',
      cardType: cardType,
      config: jsonEncode(config),
      stats: '{}',
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.localDecks).insert(row);
    return _toDeck(row);
  }

  @override
  Future<Deck> updateDeck(String id, {String? title, String? description, String? color}) async {
    final LocalDeck? row = await _find(id);
    if (row == null) {
      throw const DeckException(DeckFailure.notFound);
    }
    final String nextTitle = title?.trim() ?? row.title;
    if (nextTitle.isEmpty) {
      throw const DeckException(DeckFailure.titleRequired);
    }
    await (_db.update(_db.localDecks)..where((LocalDecks t) => t.id.equals(id))).write(
      LocalDecksCompanion(
        title: Value<String>(nextTitle),
        description: description == null
            ? const Value<String>.absent()
            : Value<String>(description),
        color: color == null ? const Value<String>.absent() : Value<String>(color),
        updatedAt: Value<int>(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return _toDeck(
      LocalDeck(
        id: row.id,
        title: nextTitle,
        description: description ?? row.description,
        color: color ?? row.color,
        cardType: row.cardType,
        folderId: row.folderId,
        config: row.config,
        stats: row.stats,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      ),
    );
  }

  @override
  Future<void> deleteDeck(String id) async {
    final LocalDeck? row = await _find(id);
    if (row == null) {
      throw const DeckException(DeckFailure.notFound);
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.localDecks)..where((LocalDecks t) => t.id.equals(id))).write(
        LocalDecksCompanion(deletedAt: Value<int>(now), updatedAt: Value<int>(now)),
      );
      // 先把「更早被单独删掉」的卡片合并进这次删除：保留它们原来的删除时间，
      // 只补上批次标记，这样它们不会同时出现在回收站顶层。
      await (_db.update(_db.localCards)..where(
            (LocalCards t) =>
                t.deckId.equals(id) & t.deletedAt.isNotNull() & t.deletedWithDeck.isNull(),
          ))
          .write(LocalCardsCompanion(deletedWithDeck: Value<String>(id)));
      // 再把还在用的卡片一起移入回收站。
      await (_db.update(
        _db.localCards,
      )..where((LocalCards t) => t.deckId.equals(id) & t.deletedAt.isNull())).write(
        LocalCardsCompanion(
          deletedAt: Value<int>(now),
          deletedWithDeck: Value<String>(id),
          updatedAt: Value<int>(now),
        ),
      );
    });
  }

  @override
  Future<List<TrashedDeck>> fetchTrashedDecks() async {
    final List<LocalDeck> rows =
        await (_db.select(_db.localDecks)
              ..where((LocalDecks t) => t.deletedAt.isNotNull())
              ..orderBy(<OrderingTerm Function(LocalDecks)>[
                (LocalDecks t) => OrderingTerm.desc(t.deletedAt),
              ]))
            .get();
    final List<TrashedDeck> result = <TrashedDeck>[];
    for (final LocalDeck row in rows) {
      result.add(
        TrashedDeck(
          deck: await _toTrashedDeck(row),
          deletedAt: DateTime.fromMillisecondsSinceEpoch(row.deletedAt!),
        ),
      );
    }
    return List<TrashedDeck>.unmodifiable(result);
  }

  @override
  Future<void> restoreDeck(String id) async {
    final LocalDeck? row = await (_db.select(
      _db.localDecks,
    )..where((LocalDecks t) => t.id.equals(id) & t.deletedAt.isNotNull())).getSingleOrNull();
    if (row == null) {
      throw const DeckException(DeckFailure.notFound);
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.localDecks)..where((LocalDecks t) => t.id.equals(id))).write(
        LocalDecksCompanion(deletedAt: const Value<int?>(null), updatedAt: Value<int>(now)),
      );
      // 只恢复这次删除带走的卡片；单独删掉的卡片本来就该留在回收站。
      await (_db.update(
        _db.localCards,
      )..where((LocalCards t) => t.deletedWithDeck.equals(id))).write(
        LocalCardsCompanion(
          deletedAt: const Value<int?>(null),
          deletedWithDeck: const Value<String?>(null),
          updatedAt: Value<int>(now),
        ),
      );
    });
  }

  Future<LocalDeck?> _find(String id) => (_db.select(
    _db.localDecks,
  )..where((LocalDecks t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  @override
  Future<void> purgeDeck(String id) async {
    // 只允许从回收站里永久删除：不在回收站（或根本不存在）就当无事发生。
    final LocalDeck? row = await (_db.select(
      _db.localDecks,
    )..where((LocalDecks t) => t.id.equals(id) & t.deletedAt.isNotNull())).getSingleOrNull();
    if (row == null) {
      return;
    }
    await _db.transaction(() async {
      // 被这次删除带走的卡片跟着一起抹掉；用户单独删的卡片不在这个批次里，留在回收站。
      await (_db.delete(
        _db.localCards,
      )..where((LocalCards t) => t.deletedWithDeck.equals(id))).go();
      await (_db.delete(_db.localDecks)..where((LocalDecks t) => t.id.equals(id))).go();
    });
  }

  Future<Deck> _toDeck(LocalDeck row) async {
    final Expression<int> countExpr = _db.localCards.id.count();
    final int count =
        (await (_db.selectOnly(_db.localCards)
                  ..addColumns(<Expression<Object>>[countExpr])
                  ..where(_db.localCards.deckId.equals(row.id) & _db.localCards.deletedAt.isNull()))
                .getSingle())
            .read(countExpr) ??
        0;
    return Deck(
      id: row.id,
      title: row.title,
      description: row.description,
      color: row.color,
      cardType: row.cardType,
      folderId: row.folderId,
      config: _decodeMap(row.config),
      stats: _decodeMap(row.stats),
      cardCount: count,
    );
  }

  /// 回收站里的卡片集只数「被这次删除带走」的卡片，用于展示删了多少张。
  Future<Deck> _toTrashedDeck(LocalDeck row) async {
    final Expression<int> countExpr = _db.localCards.id.count();
    final int count =
        (await (_db.selectOnly(_db.localCards)
                  ..addColumns(<Expression<Object>>[countExpr])
                  ..where(_db.localCards.deletedWithDeck.equals(row.id)))
                .getSingle())
            .read(countExpr) ??
        0;
    return Deck(
      id: row.id,
      title: row.title,
      description: row.description,
      color: row.color,
      cardType: row.cardType,
      folderId: row.folderId,
      config: _decodeMap(row.config),
      stats: _decodeMap(row.stats),
      cardCount: count,
    );
  }

  Map<String, dynamic> _decodeMap(String raw) {
    final Object? decoded = raw.isEmpty ? null : jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
