import 'dart:convert';

import '../../cards/domain/card.dart';

/// 导入失败的类型。文案由展示层映射到 `AppStrings`，领域层不写中文。
enum DeckImportError {
  invalidJson,
  notAnObject,
  missingTitle,
  missingCards,

  /// 卡片集层面的可选字段（`config` 等）形状不对。
  invalidDeck,

  /// 卡片内容（`fields`）不合法：缺明文/暗文、超长、图片形状不对。
  invalidCard,

  /// `card_type` 不是 MVP 支持的 `memory`（`docs/02` FR-2.2）。
  unsupportedCardType,
}

/// 导入失败。`error` 供调用方决定提示什么。
class DeckImportException implements Exception {
  const DeckImportException(this.error);

  final DeckImportError error;

  @override
  String toString() => 'DeckImportException($error)';
}

/// 一份待导入的卡片集。
///
/// 字段与后端契约一一对应（`docs/03` §4.2 `decks` 表、§4.4 `cards.fields`）：
/// - 卡片集：`title` / `description` / `color` / `card_type` / `config`
/// - 卡片：`fields{plaintext, ciphertext, images, hint, extra}` + `sort_order`
///
/// `id`、`deck_id`、`stats`、`content_hash`、时间戳都不出现在导入文件里，
/// 由服务端（本地期是仓储实现）分配。
class DeckImport {
  const DeckImport({
    required this.title,
    this.description = '',
    this.color = '',
    this.cardType = kMemoryCardType,
    this.config = const <String, dynamic>{},
    required this.cards,
  });

  final String title;
  final String description;
  final String color;
  final String cardType;

  /// 卡片集配置，对应后端 `decks.config`（`docs/03` §4.3）。
  /// 客户端不解析内部结构，原样透传给数据源。
  final Map<String, dynamic> config;

  /// 卡片内容，顺序即最终 `sort_order`（文件里给了 `sort_order` 时按它排）。
  final List<CardFields> cards;
}

/// MVP 唯一的卡片类型（`docs/03` §4.2：`card_type` 固定 `memory`）。
const String kMemoryCardType = 'memory';

/// 明文/暗文长度上限见 `cards/domain/card.dart` 的 `kPlaintextMaxLength` /
/// `kCiphertextMaxLength`（导入、编辑校验、文案共用一处定义）。

/// 解析导入文件。
///
/// 容错原则：未知字段忽略；可选字段缺失按默认值处理；必需字段不合法直接拒绝，
/// 避免把半截数据写进本地库（接后端后同理，避免脏数据上传）。
DeckImport parseDeckImport(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    throw const DeckImportException(DeckImportError.invalidJson);
  }
  if (decoded is! Map<String, dynamic>) {
    throw const DeckImportException(DeckImportError.notAnObject);
  }

  final String title = _string(decoded['title'])?.trim() ?? '';
  if (title.isEmpty) {
    throw const DeckImportException(DeckImportError.missingTitle);
  }

  final String cardType = _memoryCardType(decoded['card_type']);
  final Map<String, dynamic> config = _config(decoded['config']);

  final Object? rawCards = decoded['cards'];
  if (rawCards is! List<dynamic> || rawCards.isEmpty) {
    throw const DeckImportException(DeckImportError.missingCards);
  }

  final List<_IndexedCard> ordered = <_IndexedCard>[];
  for (int index = 0; index < rawCards.length; index++) {
    final Object? raw = rawCards[index];
    if (raw is! Map<String, dynamic>) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    // 卡片的 card_type 是冗余列（`docs/03` §4.2），有就校验、没有跟随卡片集。
    _memoryCardType(raw['card_type']);
    final Object? rawFields = raw['fields'];
    if (rawFields is! Map<String, dynamic>) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    final Object? rawSortOrder = raw['sort_order'];
    if (rawSortOrder != null && rawSortOrder is! int) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    ordered.add(
      _IndexedCard(fields: _parseFields(rawFields), sortOrder: rawSortOrder as int?, index: index),
    );
  }

  // 后端按 sort_order 排序；文件没写就沿用数组顺序，两者混用时缺省值按原下标算。
  ordered.sort((_IndexedCard a, _IndexedCard b) {
    final int bySort = (a.sortOrder ?? a.index).compareTo(b.sortOrder ?? b.index);
    return bySort != 0 ? bySort : a.index.compareTo(b.index);
  });

  return DeckImport(
    title: title,
    description: _string(decoded['description'])?.trim() ?? '',
    color: _normalizeColor(_string(decoded['color'])),
    cardType: cardType,
    config: config,
    cards: <CardFields>[for (final _IndexedCard card in ordered) card.fields],
  );
}

class _IndexedCard {
  const _IndexedCard({required this.fields, required this.sortOrder, required this.index});

  final CardFields fields;
  final int? sortOrder;
  final int index;
}

CardFields _parseFields(Map<String, dynamic> raw) {
  final String plaintext = _string(raw['plaintext'])?.trim() ?? '';
  final String ciphertext = _string(raw['ciphertext'])?.trim() ?? '';
  if (plaintext.isEmpty ||
      ciphertext.isEmpty ||
      plaintext.length > kPlaintextMaxLength ||
      ciphertext.length > kCiphertextMaxLength) {
    throw const DeckImportException(DeckImportError.invalidCard);
  }
  return CardFields(
    plaintext: plaintext,
    ciphertext: ciphertext,
    images: _parseImages(raw['images']),
    hint: _string(raw['hint'])?.trim(),
    extra: _string(raw['extra'])?.trim(),
    question: _optionalQuestion(raw['question']),
  );
}

/// `question` 是本地演示字段（见 `CardFields` 注释），有值时才收，超长按明文上限拒绝。
String? _optionalQuestion(Object? raw) {
  final String? value = _string(raw)?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.length > kPlaintextMaxLength) {
    throw const DeckImportException(DeckImportError.invalidCard);
  }
  return value;
}

/// 解析 `fields.images`：`[{key, width, height, alt}]`（`docs/03` §4.4）。
///
/// `key` 是对象存储的 key，不是 URL；本期没有上传通道，导入文件里给空数组即可。
List<CardImage> _parseImages(Object? raw) {
  if (raw == null) {
    return const <CardImage>[];
  }
  if (raw is! List<dynamic>) {
    throw const DeckImportException(DeckImportError.invalidCard);
  }
  final List<CardImage> images = <CardImage>[];
  for (final Object? item in raw) {
    if (item is! Map<String, dynamic>) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    final String key = _string(item['key'])?.trim() ?? '';
    final Object? width = item['width'];
    final Object? height = item['height'];
    if (key.isEmpty || (width != null && width is! int) || (height != null && height is! int)) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    images.add(
      CardImage(key: key, width: width as int?, height: height as int?, alt: _string(item['alt'])),
    );
  }
  return images;
}

/// 只接受 `memory`：其它类型需要对应的渲染器/运行器，MVP 没有（`docs/03` §4.6）。
String _memoryCardType(Object? raw) {
  if (raw == null) {
    return kMemoryCardType;
  }
  final String value = _string(raw)?.trim() ?? '';
  if (value != kMemoryCardType) {
    throw const DeckImportException(DeckImportError.unsupportedCardType);
  }
  return value;
}

/// `config` 原样透传（结构由后端 §4.3 定义并校验），只要求是对象。
Map<String, dynamic> _config(Object? raw) {
  if (raw == null) {
    return const <String, dynamic>{};
  }
  if (raw is! Map<String, dynamic>) {
    throw const DeckImportException(DeckImportError.invalidDeck);
  }
  return Map<String, dynamic>.of(raw);
}

String? _string(Object? value) => value is String ? value : null;

/// 只接受 `#RRGGBB` / `#AARRGGBB`，其余一律视为无颜色。
String _normalizeColor(String? value) {
  if (value == null) {
    return '';
  }
  final String trimmed = value.trim();
  if (!RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(trimmed)) {
    return '';
  }
  return trimmed;
}
