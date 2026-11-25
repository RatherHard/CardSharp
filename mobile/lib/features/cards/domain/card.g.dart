// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardImage _$CardImageFromJson(Map<String, dynamic> json) => _CardImage(
  key: json['key'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  alt: json['alt'] as String?,
);

Map<String, dynamic> _$CardImageToJson(_CardImage instance) => <String, dynamic>{
  'key': instance.key,
  'width': instance.width,
  'height': instance.height,
  'alt': instance.alt,
};

_CardFields _$CardFieldsFromJson(Map<String, dynamic> json) => _CardFields(
  plaintext: json['plaintext'] as String,
  ciphertext: json['ciphertext'] as String,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => CardImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CardImage>[],
  hint: json['hint'] as String?,
  extra: json['extra'] as String?,
);

Map<String, dynamic> _$CardFieldsToJson(_CardFields instance) => <String, dynamic>{
  'plaintext': instance.plaintext,
  'ciphertext': instance.ciphertext,
  'images': instance.images,
  'hint': instance.hint,
  'extra': instance.extra,
};

_Card _$CardFromJson(Map<String, dynamic> json) => _Card(
  id: json['id'] as String,
  deckId: json['deckId'] as String,
  cardType: json['cardType'] as String? ?? 'memory',
  fields: CardFields.fromJson(json['fields'] as Map<String, dynamic>),
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CardToJson(_Card instance) => <String, dynamic>{
  'id': instance.id,
  'deckId': instance.deckId,
  'cardType': instance.cardType,
  'fields': instance.fields,
  'sortOrder': instance.sortOrder,
};
