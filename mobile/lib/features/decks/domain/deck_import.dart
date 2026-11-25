import 'dart:convert';

/// 导入失败的类型。文案由展示层映射到 `AppStrings`，领域层不写中文。
enum DeckImportError { invalidJson, notAnObject, missingTitle, missingCards, invalidCard }

/// 导入失败。`error` 供调用方决定提示什么。
class DeckImportException implements Exception {
  const DeckImportException(this.error);

  final DeckImportError error;

  @override
  String toString() => 'DeckImportException($error)';
}

/// 导入文件里的单张卡片（没有 id、归属，由数据源分配）。
class ImportedDeckCard {
  const ImportedDeckCard({
    required this.plaintext,
    required this.ciphertext,
    this.hint,
    this.extra,
  });

  final String plaintext;
  final String ciphertext;
  final String? hint;
  final String? extra;
}

/// 一份待导入的卡片集。
///
/// 字段与后端契约一致：`decks` 的 title/description/color，`cards.fields` 的
/// plaintext/ciphertext/hint/extra（`docs/03` §4.2、§4.4）。
class DeckImport {
  const DeckImport({
    required this.title,
    this.description = '',
    this.color = '',
    required this.cards,
  });

  final String title;
  final String description;
  final String color;
  final List<ImportedDeckCard> cards;
}

/// 明文/暗文长度上限，来自 `docs/03` §4.4。
const int kPlaintextMaxLength = 200;
const int kCiphertextMaxLength = 500;

/// 解析导入文件。
///
/// 容错原则：多余字段忽略；可选字段缺失按空处理；必需字段不合法直接拒绝，
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

  final List<dynamic>? rawCards = decoded['cards'] as List<dynamic>?;
  if (rawCards == null || rawCards.isEmpty) {
    throw const DeckImportException(DeckImportError.missingCards);
  }

  final List<ImportedDeckCard> cards = <ImportedDeckCard>[];
  for (final dynamic raw in rawCards) {
    if (raw is! Map<String, dynamic>) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    final String plaintext = _string(raw['plaintext'])?.trim() ?? '';
    final String ciphertext = _string(raw['ciphertext'])?.trim() ?? '';
    if (plaintext.isEmpty ||
        ciphertext.isEmpty ||
        plaintext.length > kPlaintextMaxLength ||
        ciphertext.length > kCiphertextMaxLength) {
      throw const DeckImportException(DeckImportError.invalidCard);
    }
    cards.add(
      ImportedDeckCard(
        plaintext: plaintext,
        ciphertext: ciphertext,
        hint: _string(raw['hint'])?.trim(),
        extra: _string(raw['extra'])?.trim(),
      ),
    );
  }

  return DeckImport(
    title: title,
    description: _string(decoded['description'])?.trim() ?? '',
    color: _normalizeColor(_string(decoded['color'])),
    cards: cards,
  );
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
