import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/network/page.dart';
import '../../../core/storage/app_database.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';
import '../domain/trashed_card.dart';

/// 基于 Drift 的卡片仓储。
///
/// `cards.fields` 以 JSON 原文存放（键名与后端一致），解析交给 `CardFields.fromJson`。
class LocalCardRepository implements CardRepository {
  LocalCardRepository(this._db);

  final AppDatabase _db;

  /// 整集替换时用来区分同一毫秒内不同批次的 id，避免主键撞号。
  static int _batchSeq = 0;

  @override
  Future<PagedResult<Card>> fetchCards(String deckId, {String? cursor, int limit = 50}) async {
    final int offset = int.tryParse(cursor ?? '') ?? 0;
    final List<LocalCard> rows =
        await (_db.select(_db.localCards)
              ..where((LocalCards t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function(LocalCards)>[
                (LocalCards t) => OrderingTerm.asc(t.sortOrder),
                (LocalCards t) => OrderingTerm.asc(t.createdAt),
              ])
              ..limit(limit, offset: offset))
            .get();

    final Expression<int> totalExpr = _db.localCards.id.count();
    final int total =
        (await (_db.selectOnly(_db.localCards)
                  ..addColumns(<Expression<Object>>[totalExpr])
                  ..where(_db.localCards.deckId.equals(deckId) & _db.localCards.deletedAt.isNull()))
                .getSingle())
            .read(totalExpr) ??
        0;

    return PagedResult<Card>(
      items: List<Card>.unmodifiable(<Card>[for (final LocalCard row in rows) _toCard(row)]),
      nextCursor: offset + rows.length < total ? '${offset + rows.length}' : null,
    );
  }

  @override
  Future<Card> updateCard(Card card) async {
    final LocalCard? row = await (_db.select(
      _db.localCards,
    )..where((LocalCards t) => t.id.equals(card.id) & t.deletedAt.isNull())).getSingleOrNull();
    if (row == null) {
      throw const CardException(CardFailure.cardNotFound);
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.localCards)..where((LocalCards t) => t.id.equals(card.id))).write(
      LocalCardsCompanion(
        fields: Value<String>(jsonEncode(card.fields.toJson())),
        sortOrder: Value<int>(card.sortOrder),
        updatedAt: Value<int>(now),
      ),
    );
    return card;
  }

  @override
  Future<void> deleteCard(String id) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int changed =
        await (_db.update(
          _db.localCards,
        )..where((LocalCards t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          LocalCardsCompanion(
            deletedAt: Value<int>(now),
            // 单独删除：不归任何卡片集批次，于是会出现在回收站顶层并标注来源。
            deletedWithDeck: const Value<String?>(null),
            updatedAt: Value<int>(now),
          ),
        );
    if (changed == 0) {
      throw const CardException(CardFailure.cardNotFound);
    }
  }

  @override
  Future<void> deleteCards(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(
      _db.localCards,
    )..where((LocalCards t) => t.id.isIn(ids) & t.deletedAt.isNull())).write(
      LocalCardsCompanion(
        deletedAt: Value<int>(now),
        deletedWithDeck: const Value<String?>(null),
        updatedAt: Value<int>(now),
      ),
    );
  }

  @override
  Future<List<TrashedCard>> fetchStandaloneTrashedCards() async {
    final List<LocalCard> rows =
        await (_db.select(_db.localCards)
              ..where((LocalCards t) => t.deletedAt.isNotNull() & t.deletedWithDeck.isNull())
              ..orderBy(<OrderingTerm Function(LocalCards)>[
                (LocalCards t) => OrderingTerm.desc(t.deletedAt),
              ]))
            .get();
    if (rows.isEmpty) {
      return const <TrashedCard>[];
    }

    final Set<String> deckIds = <String>{for (final LocalCard row in rows) row.deckId};
    final List<LocalDeck> decks = await (_db.select(
      _db.localDecks,
    )..where((LocalDecks t) => t.id.isIn(deckIds))).get();
    final Map<String, String> deckTitles = <String, String>{
      for (final LocalDeck deck in decks) deck.id: deck.title,
    };

    return List<TrashedCard>.unmodifiable(<TrashedCard>[
      for (final LocalCard row in rows)
        TrashedCard(
          card: _toCard(row),
          deletedAt: DateTime.fromMillisecondsSinceEpoch(row.deletedAt!),
          sourceDeckTitle: deckTitles[row.deckId] ?? '',
        ),
    ]);
  }

  @override
  Future<List<Card>> fetchTrashedCardsOfDeck(String deckId) async {
    final List<LocalCard> rows =
        await (_db.select(_db.localCards)
              ..where((LocalCards t) => t.deletedWithDeck.equals(deckId))
              ..orderBy(<OrderingTerm Function(LocalCards)>[
                (LocalCards t) => OrderingTerm.asc(t.sortOrder),
                (LocalCards t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();
    return List<Card>.unmodifiable(<Card>[for (final LocalCard row in rows) _toCard(row)]);
  }

  @override
  Future<void> restoreCard(String cardId, {required String targetDeckId}) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int changed =
        await (_db.update(
          _db.localCards,
        )..where((LocalCards t) => t.id.equals(cardId) & t.deletedAt.isNotNull())).write(
          LocalCardsCompanion(
            deckId: Value<String>(targetDeckId),
            deletedAt: const Value<int?>(null),
            deletedWithDeck: const Value<String?>(null),
            updatedAt: Value<int>(now),
          ),
        );
    if (changed == 0) {
      throw const CardException(CardFailure.cardNotFound);
    }
  }

  @override
  Future<void> purgeCards(Iterable<String> cardIds) async {
    final List<String> ids = cardIds.toList();
    if (ids.isEmpty) {
      return;
    }
    // 只删「单独删进回收站」的卡片：跟着卡片集一起删的走卡片集那条路，
    // 正常卡片（deletedAt 为空）一律不碰。
    await (_db.delete(_db.localCards)..where(
          (LocalCards t) => t.id.isIn(ids) & t.deletedAt.isNotNull() & t.deletedWithDeck.isNull(),
        ))
        .go();
  }

  @override
  Future<void> addCards(String deckId, List<CardFields> cards) async {
    if (cards.isEmpty) {
      return;
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Expression<int> existingExpr = _db.localCards.id.count();
    final int existing =
        (await (_db.selectOnly(_db.localCards)
                  ..addColumns(<Expression<Object>>[existingExpr])
                  ..where(_db.localCards.deckId.equals(deckId) & _db.localCards.deletedAt.isNull()))
                .getSingle())
            .read(existingExpr) ??
        0;

    await _db.batch((Batch batch) {
      for (int i = 0; i < cards.length; i++) {
        batch.insert(
          _db.localCards,
          LocalCardsCompanion.insert(
            // 本地生成的 id；接后端后一律由服务端分配。
            id: 'local-$now-$i',
            deckId: deckId,
            fields: jsonEncode(cards[i].toJson()),
            sortOrder: Value<int>(existing + i),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    });
  }

  @override
  Future<void> replaceCards(String deckId, List<CardFields> cards) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    // 同一毫秒内多次整集替换时用来区分 id 批次，避免主键撞号。
    final int batch = _batchSeq++;
    await _db.transaction(() async {
      // 权威版覆盖：该卡片集名下的卡片一律物理删掉（含回收站里的、以及用户
      // 单独删进回收站的），再按权威顺序重建。本地改动会被丢弃，这是预期语义。
      await (_db.delete(_db.localCards)..where((LocalCards t) => t.deckId.equals(deckId))).go();
      await _db.batch((Batch batchWriter) {
        for (int i = 0; i < cards.length; i++) {
          batchWriter.insert(
            _db.localCards,
            LocalCardsCompanion.insert(
              // 本地生成的 id；接后端后一律由服务端分配。
              id: 'local-$now-$batch-$i',
              deckId: deckId,
              fields: jsonEncode(cards[i].toJson()),
              sortOrder: Value<int>(i),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      });
    });
  }

  Card _toCard(LocalCard row) {
    final Object? decoded = jsonDecode(row.fields);
    final Map<String, dynamic> fields = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    return Card(
      id: row.id,
      deckId: row.deckId,
      cardType: row.cardType,
      fields: CardFields.fromJson(fields),
      sortOrder: row.sortOrder,
    );
  }
}
