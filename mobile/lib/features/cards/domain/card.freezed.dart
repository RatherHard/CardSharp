// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardImage {

 String get key; int? get width; int? get height; String? get alt;
/// Create a copy of CardImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardImageCopyWith<CardImage> get copyWith => _$CardImageCopyWithImpl<CardImage>(this as CardImage, _$identity);

  /// Serializes this CardImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardImage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardImage&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.alt, _this.alt) || other.alt == _this.alt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardImage;
  return Object.hash(runtimeType,_this.key,_this.width,_this.height,_this.alt);
}

@override
String toString() {
  final _this = this as CardImage;
  return 'CardImage(key: ${_this.key}, width: ${_this.width}, height: ${_this.height}, alt: ${_this.alt})';
}


}

/// @nodoc
abstract mixin class $CardImageCopyWith<$Res>  {
  factory $CardImageCopyWith(CardImage value, $Res Function(CardImage) _then) = _$CardImageCopyWithImpl;
@useResult
$Res call({
 String key, int? width, int? height, String? alt
});




}
/// @nodoc
class _$CardImageCopyWithImpl<$Res>
    implements $CardImageCopyWith<$Res> {
  _$CardImageCopyWithImpl(this._self, this._then);

  final CardImage _self;
  final $Res Function(CardImage) _then;

/// Create a copy of CardImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? width = freezed,Object? height = freezed,Object? alt = freezed,}) {
  return _then(CardImage(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardImage].
extension CardImagePatterns on CardImage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardImage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardImage value)  $default,){
final _that = this;
switch (_that) {
case _CardImage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardImage value)?  $default,){
final _that = this;
switch (_that) {
case _CardImage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  int? width,  int? height,  String? alt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardImage() when $default != null:
return $default(_that.key,_that.width,_that.height,_that.alt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  int? width,  int? height,  String? alt)  $default,) {final _that = this;
switch (_that) {
case _CardImage():
return $default(_that.key,_that.width,_that.height,_that.alt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  int? width,  int? height,  String? alt)?  $default,) {final _that = this;
switch (_that) {
case _CardImage() when $default != null:
return $default(_that.key,_that.width,_that.height,_that.alt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CardImage implements CardImage {
  const _CardImage({required this.key, this.width, this.height, this.alt});
  factory _CardImage.fromJson(Map<String, dynamic> json) => _$CardImageFromJson(json);

@override final  String key;
@override final  int? width;
@override final  int? height;
@override final  String? alt;

/// Create a copy of CardImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardImageCopyWith<_CardImage> get copyWith => __$CardImageCopyWithImpl<_CardImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardImageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardImage&&(identical(other.key, key) || other.key == key)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.alt, alt) || other.alt == alt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,width,height,alt);
}

@override
String toString() {
    return 'CardImage(key: $key, width: $width, height: $height, alt: $alt)';
}


}

/// @nodoc
abstract mixin class _$CardImageCopyWith<$Res> implements $CardImageCopyWith<$Res> {
  factory _$CardImageCopyWith(_CardImage value, $Res Function(_CardImage) _then) = __$CardImageCopyWithImpl;
@override @useResult
$Res call({
 String key, int? width, int? height, String? alt
});




}
/// @nodoc
class __$CardImageCopyWithImpl<$Res>
    implements _$CardImageCopyWith<$Res> {
  __$CardImageCopyWithImpl(this._self, this._then);

  final _CardImage _self;
  final $Res Function(_CardImage) _then;

/// Create a copy of CardImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? width = freezed,Object? height = freezed,Object? alt = freezed,}) {
  return _then(_CardImage(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CardFields {

 String get plaintext; String get ciphertext; List<CardImage> get images; String? get hint; String? get extra; String? get question;
/// Create a copy of CardFields
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardFieldsCopyWith<CardFields> get copyWith => _$CardFieldsCopyWithImpl<CardFields>(this as CardFields, _$identity);

  /// Serializes this CardFields to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardFields;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardFields&&(identical(other.plaintext, _this.plaintext) || other.plaintext == _this.plaintext)&&(identical(other.ciphertext, _this.ciphertext) || other.ciphertext == _this.ciphertext)&&const DeepCollectionEquality().equals(other.images, _this.images)&&(identical(other.hint, _this.hint) || other.hint == _this.hint)&&(identical(other.extra, _this.extra) || other.extra == _this.extra)&&(identical(other.question, _this.question) || other.question == _this.question));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardFields;
  return Object.hash(runtimeType,_this.plaintext,_this.ciphertext,const DeepCollectionEquality().hash(_this.images),_this.hint,_this.extra,_this.question);
}

@override
String toString() {
  final _this = this as CardFields;
  return 'CardFields(plaintext: ${_this.plaintext}, ciphertext: ${_this.ciphertext}, images: ${_this.images}, hint: ${_this.hint}, extra: ${_this.extra}, question: ${_this.question})';
}


}

/// @nodoc
abstract mixin class $CardFieldsCopyWith<$Res>  {
  factory $CardFieldsCopyWith(CardFields value, $Res Function(CardFields) _then) = _$CardFieldsCopyWithImpl;
@useResult
$Res call({
 String plaintext, String ciphertext, List<CardImage> images, String? hint, String? extra, String? question
});




}
/// @nodoc
class _$CardFieldsCopyWithImpl<$Res>
    implements $CardFieldsCopyWith<$Res> {
  _$CardFieldsCopyWithImpl(this._self, this._then);

  final CardFields _self;
  final $Res Function(CardFields) _then;

/// Create a copy of CardFields
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plaintext = null,Object? ciphertext = null,Object? images = null,Object? hint = freezed,Object? extra = freezed,Object? question = freezed,}) {
  return _then(CardFields(
plaintext: null == plaintext ? _self.plaintext : plaintext // ignore: cast_nullable_to_non_nullable
as String,ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<CardImage>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,extra: freezed == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as String?,question: freezed == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardFields].
extension CardFieldsPatterns on CardFields {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardFields value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardFields() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardFields value)  $default,){
final _that = this;
switch (_that) {
case _CardFields():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardFields value)?  $default,){
final _that = this;
switch (_that) {
case _CardFields() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plaintext,  String ciphertext,  List<CardImage> images,  String? hint,  String? extra,  String? question)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardFields() when $default != null:
return $default(_that.plaintext,_that.ciphertext,_that.images,_that.hint,_that.extra,_that.question);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plaintext,  String ciphertext,  List<CardImage> images,  String? hint,  String? extra,  String? question)  $default,) {final _that = this;
switch (_that) {
case _CardFields():
return $default(_that.plaintext,_that.ciphertext,_that.images,_that.hint,_that.extra,_that.question);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plaintext,  String ciphertext,  List<CardImage> images,  String? hint,  String? extra,  String? question)?  $default,) {final _that = this;
switch (_that) {
case _CardFields() when $default != null:
return $default(_that.plaintext,_that.ciphertext,_that.images,_that.hint,_that.extra,_that.question);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CardFields implements CardFields {
  const _CardFields({required this.plaintext, required this.ciphertext,  List<CardImage> images = const <CardImage>[], this.hint, this.extra, this.question}): _images = images;
  factory _CardFields.fromJson(Map<String, dynamic> json) => _$CardFieldsFromJson(json);

@override final  String plaintext;
@override final  String ciphertext;
 final  List<CardImage> _images;
@override@JsonKey() List<CardImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? hint;
@override final  String? extra;
@override final  String? question;

/// Create a copy of CardFields
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardFieldsCopyWith<_CardFields> get copyWith => __$CardFieldsCopyWithImpl<_CardFields>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardFieldsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardFields&&(identical(other.plaintext, plaintext) || other.plaintext == plaintext)&&(identical(other.ciphertext, ciphertext) || other.ciphertext == ciphertext)&&const DeepCollectionEquality().equals(other.images, _images)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.extra, extra) || other.extra == extra)&&(identical(other.question, question) || other.question == question));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,plaintext,ciphertext,const DeepCollectionEquality().hash(_images),hint,extra,question);
}

@override
String toString() {
    return 'CardFields(plaintext: $plaintext, ciphertext: $ciphertext, images: $images, hint: $hint, extra: $extra, question: $question)';
}


}

/// @nodoc
abstract mixin class _$CardFieldsCopyWith<$Res> implements $CardFieldsCopyWith<$Res> {
  factory _$CardFieldsCopyWith(_CardFields value, $Res Function(_CardFields) _then) = __$CardFieldsCopyWithImpl;
@override @useResult
$Res call({
 String plaintext, String ciphertext, List<CardImage> images, String? hint, String? extra, String? question
});




}
/// @nodoc
class __$CardFieldsCopyWithImpl<$Res>
    implements _$CardFieldsCopyWith<$Res> {
  __$CardFieldsCopyWithImpl(this._self, this._then);

  final _CardFields _self;
  final $Res Function(_CardFields) _then;

/// Create a copy of CardFields
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plaintext = null,Object? ciphertext = null,Object? images = null,Object? hint = freezed,Object? extra = freezed,Object? question = freezed,}) {
  return _then(_CardFields(
plaintext: null == plaintext ? _self.plaintext : plaintext // ignore: cast_nullable_to_non_nullable
as String,ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<CardImage>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,extra: freezed == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as String?,question: freezed == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Card {

 String get id; String get deckId; String get cardType; CardFields get fields; int get sortOrder;
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardCopyWith<Card> get copyWith => _$CardCopyWithImpl<Card>(this as Card, _$identity);

  /// Serializes this Card to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Card;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Card&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.cardType, _this.cardType) || other.cardType == _this.cardType)&&(identical(other.fields, _this.fields) || other.fields == _this.fields)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Card;
  return Object.hash(runtimeType,_this.id,_this.deckId,_this.cardType,_this.fields,_this.sortOrder);
}

@override
String toString() {
  final _this = this as Card;
  return 'Card(id: ${_this.id}, deckId: ${_this.deckId}, cardType: ${_this.cardType}, fields: ${_this.fields}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $CardCopyWith<$Res>  {
  factory $CardCopyWith(Card value, $Res Function(Card) _then) = _$CardCopyWithImpl;
@useResult
$Res call({
 String id, String deckId, String cardType, CardFields fields, int sortOrder
});


$CardFieldsCopyWith<$Res> get fields;

}
/// @nodoc
class _$CardCopyWithImpl<$Res>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._self, this._then);

  final Card _self;
  final $Res Function(Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deckId = null,Object? cardType = null,Object? fields = null,Object? sortOrder = null,}) {
  return _then(Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as CardFields,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardFieldsCopyWith<$Res> get fields {
  
  return $CardFieldsCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}
}


/// Adds pattern-matching-related methods to [Card].
extension CardPatterns on Card {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Card value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Card value)  $default,){
final _that = this;
switch (_that) {
case _Card():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Card value)?  $default,){
final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deckId,  String cardType,  CardFields fields,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.deckId,_that.cardType,_that.fields,_that.sortOrder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deckId,  String cardType,  CardFields fields,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Card():
return $default(_that.id,_that.deckId,_that.cardType,_that.fields,_that.sortOrder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deckId,  String cardType,  CardFields fields,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.id,_that.deckId,_that.cardType,_that.fields,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Card implements Card {
  const _Card({required this.id, required this.deckId, this.cardType = 'memory', required this.fields, this.sortOrder = 0});
  factory _Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);

@override final  String id;
@override final  String deckId;
@override@JsonKey() final  String cardType;
@override final  CardFields fields;
@override@JsonKey() final  int sortOrder;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardCopyWith<_Card> get copyWith => __$CardCopyWithImpl<_Card>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Card&&(identical(other.id, id) || other.id == id)&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.fields, fields) || other.fields == fields)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deckId,cardType,fields,sortOrder);
}

@override
String toString() {
    return 'Card(id: $id, deckId: $deckId, cardType: $cardType, fields: $fields, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CardCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$CardCopyWith(_Card value, $Res Function(_Card) _then) = __$CardCopyWithImpl;
@override @useResult
$Res call({
 String id, String deckId, String cardType, CardFields fields, int sortOrder
});


@override $CardFieldsCopyWith<$Res> get fields;

}
/// @nodoc
class __$CardCopyWithImpl<$Res>
    implements _$CardCopyWith<$Res> {
  __$CardCopyWithImpl(this._self, this._then);

  final _Card _self;
  final $Res Function(_Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deckId = null,Object? cardType = null,Object? fields = null,Object? sortOrder = null,}) {
  return _then(_Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as CardFields,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardFieldsCopyWith<$Res> get fields {
  
  return $CardFieldsCopyWith<$Res>(_self.fields, (value) {
    return _then(_self.copyWith(fields: value));
  });
}
}

// dart format on
