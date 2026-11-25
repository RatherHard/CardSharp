// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deck _$DeckFromJson(Map<String, dynamic> json) => _Deck(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  color: json['color'] as String? ?? '',
  cardType: json['card_type'] as String? ?? 'memory',
  folderId: json['folder_id'] as String?,
  config: json['config'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  stats: json['stats'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$DeckToJson(_Deck instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'color': instance.color,
  'card_type': instance.cardType,
  'folder_id': instance.folderId,
  'config': instance.config,
  'stats': instance.stats,
};
