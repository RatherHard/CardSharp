import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/network/page.dart';
import '../../../core/storage/app_database.dart';
import '../domain/card.dart';
import '../domain/card_repository.dart';

/// 基于 Drift 的卡片仓储。
///
/// `cards.fields` 以 JSON 原文存放（键名与后端一致），解析交给 `CardFields.fromJson`。
class LocalCardRepository implements CardRepository {
  LocalCardRepository(this._db);

  final AppDatabase _db;

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
    final int changed =
        await (_db.update(
          _db.localCards,
        )..where((LocalCards t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          LocalCardsCompanion(deletedAt: Value<int>(DateTime.now().millisecondsSinceEpoch)),
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
    await (_db.update(_db.localCards)..where((LocalCards t) => t.id.isIn(ids))).write(
      LocalCardsCompanion(deletedAt: Value<int>(now), updatedAt: Value<int>(now)),
    );
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
