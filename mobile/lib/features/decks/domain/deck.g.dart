// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deck _$DeckFromJson(Map<String, dynamic> json) => _Deck(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  cardCount: (json['cardCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DeckToJson(_Deck instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'cardCount': instance.cardCount,
};
