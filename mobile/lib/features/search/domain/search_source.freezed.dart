// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeckSource {

 String get id; String get title; String get description; int get cardCount; String get color;
/// Create a copy of DeckSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckSourceCopyWith<DeckSource> get copyWith => _$DeckSourceCopyWithImpl<DeckSource>(this as DeckSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeckSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckSource&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.cardCount, _this.cardCount) || other.cardCount == _this.cardCount)&&(identical(other.color, _this.color) || other.color == _this.color));
}


@override
int get hashCode {
  final _this = this as DeckSource;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.cardCount,_this.color);
}

@override
String toString() {
  final _this = this as DeckSource;
  return 'DeckSource(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, cardCount: ${_this.cardCount}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $DeckSourceCopyWith<$Res>  {
  factory $DeckSourceCopyWith(DeckSource value, $Res Function(DeckSource) _then) = _$DeckSourceCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int cardCount, String color
});




}
/// @nodoc
class _$DeckSourceCopyWithImpl<$Res>
    implements $DeckSourceCopyWith<$Res> {
  _$DeckSourceCopyWithImpl(this._self, this._then);

  final DeckSource _self;
  final $Res Function(DeckSource) _then;

/// Create a copy of DeckSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? cardCount = null,Object? color = null,}) {
  return _then(DeckSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckSource].
extension DeckSourcePatterns on DeckSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckSource value)  $default,){
final _that = this;
switch (_that) {
case _DeckSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckSource value)?  $default,){
final _that = this;
switch (_that) {
case _DeckSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int cardCount,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckSource() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.cardCount,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int cardCount,  String color)  $default,) {final _that = this;
switch (_that) {
case _DeckSource():
return $default(_that.id,_that.title,_that.description,_that.cardCount,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int cardCount,  String color)?  $default,) {final _that = this;
switch (_that) {
case _DeckSource() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.cardCount,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _DeckSource implements DeckSource {
  const _DeckSource({required this.id, required this.title, required this.description, required this.cardCount, this.color = ''});
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  int cardCount;
@override@JsonKey() final  String color;

/// Create a copy of DeckSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckSourceCopyWith<_DeckSource> get copyWith => __$DeckSourceCopyWithImpl<_DeckSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckSource&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,cardCount,color);
}

@override
String toString() {
    return 'DeckSource(id: $id, title: $title, description: $description, cardCount: $cardCount, color: $color)';
}


}

/// @nodoc
abstract mixin class _$DeckSourceCopyWith<$Res> implements $DeckSourceCopyWith<$Res> {
  factory _$DeckSourceCopyWith(_DeckSource value, $Res Function(_DeckSource) _then) = __$DeckSourceCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int cardCount, String color
});




}
/// @nodoc
class __$DeckSourceCopyWithImpl<$Res>
    implements _$DeckSourceCopyWith<$Res> {
  __$DeckSourceCopyWithImpl(this._self, this._then);

  final _DeckSource _self;
  final $Res Function(_DeckSource) _then;

/// Create a copy of DeckSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? cardCount = null,Object? color = null,}) {
  return _then(_DeckSource(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CardSource {

 String get deckId; String get deckTitle; List<CardSourceCard> get cards;
/// Create a copy of CardSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSourceCopyWith<CardSource> get copyWith => _$CardSourceCopyWithImpl<CardSource>(this as CardSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSource&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.deckTitle, _this.deckTitle) || other.deckTitle == _this.deckTitle)&&const DeepCollectionEquality().equals(other.cards, _this.cards));
}


@override
int get hashCode {
  final _this = this as CardSource;
  return Object.hash(runtimeType,_this.deckId,_this.deckTitle,const DeepCollectionEquality().hash(_this.cards));
}

@override
String toString() {
  final _this = this as CardSource;
  return 'CardSource(deckId: ${_this.deckId}, deckTitle: ${_this.deckTitle}, cards: ${_this.cards})';
}


}

/// @nodoc
abstract mixin class $CardSourceCopyWith<$Res>  {
  factory $CardSourceCopyWith(CardSource value, $Res Function(CardSource) _then) = _$CardSourceCopyWithImpl;
@useResult
$Res call({
 String deckId, String deckTitle, List<CardSourceCard> cards
});




}
/// @nodoc
class _$CardSourceCopyWithImpl<$Res>
    implements $CardSourceCopyWith<$Res> {
  _$CardSourceCopyWithImpl(this._self, this._then);

  final CardSource _self;
  final $Res Function(CardSource) _then;

/// Create a copy of CardSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deckId = null,Object? deckTitle = null,Object? cards = null,}) {
  return _then(CardSource(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,deckTitle: null == deckTitle ? _self.deckTitle : deckTitle // ignore: cast_nullable_to_non_nullable
as String,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as List<CardSourceCard>,
  ));
}

}


/// Adds pattern-matching-related methods to [CardSource].
extension CardSourcePatterns on CardSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardSource value)  $default,){
final _that = this;
switch (_that) {
case _CardSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardSource value)?  $default,){
final _that = this;
switch (_that) {
case _CardSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deckId,  String deckTitle,  List<CardSourceCard> cards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardSource() when $default != null:
return $default(_that.deckId,_that.deckTitle,_that.cards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deckId,  String deckTitle,  List<CardSourceCard> cards)  $default,) {final _that = this;
switch (_that) {
case _CardSource():
return $default(_that.deckId,_that.deckTitle,_that.cards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deckId,  String deckTitle,  List<CardSourceCard> cards)?  $default,) {final _that = this;
switch (_that) {
case _CardSource() when $default != null:
return $default(_that.deckId,_that.deckTitle,_that.cards);case _:
  return null;

}
}

}

/// @nodoc


class _CardSource implements CardSource {
  const _CardSource({required this.deckId, required this.deckTitle, required  List<CardSourceCard> cards}): _cards = cards;
  

@override final  String deckId;
@override final  String deckTitle;
 final  List<CardSourceCard> _cards;
@override List<CardSourceCard> get cards {
  if (_cards is EqualUnmodifiableListView) return _cards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cards);
}


/// Create a copy of CardSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardSourceCopyWith<_CardSource> get copyWith => __$CardSourceCopyWithImpl<_CardSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSource&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.deckTitle, deckTitle) || other.deckTitle == deckTitle)&&const DeepCollectionEquality().equals(other.cards, _cards));
}


@override
int get hashCode {
    return Object.hash(runtimeType,deckId,deckTitle,const DeepCollectionEquality().hash(_cards));
}

@override
String toString() {
    return 'CardSource(deckId: $deckId, deckTitle: $deckTitle, cards: $cards)';
}


}

/// @nodoc
abstract mixin class _$CardSourceCopyWith<$Res> implements $CardSourceCopyWith<$Res> {
  factory _$CardSourceCopyWith(_CardSource value, $Res Function(_CardSource) _then) = __$CardSourceCopyWithImpl;
@override @useResult
$Res call({
 String deckId, String deckTitle, List<CardSourceCard> cards
});




}
/// @nodoc
class __$CardSourceCopyWithImpl<$Res>
    implements _$CardSourceCopyWith<$Res> {
  __$CardSourceCopyWithImpl(this._self, this._then);

  final _CardSource _self;
  final $Res Function(_CardSource) _then;

/// Create a copy of CardSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deckId = null,Object? deckTitle = null,Object? cards = null,}) {
  return _then(_CardSource(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,deckTitle: null == deckTitle ? _self.deckTitle : deckTitle // ignore: cast_nullable_to_non_nullable
as String,cards: null == cards ? _self._cards : cards // ignore: cast_nullable_to_non_nullable
as List<CardSourceCard>,
  ));
}


}

/// @nodoc
mixin _$CardSourceCard {

 String get id; String get name; String get plaintext; String get ciphertext;
/// Create a copy of CardSourceCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSourceCardCopyWith<CardSourceCard> get copyWith => _$CardSourceCardCopyWithImpl<CardSourceCard>(this as CardSourceCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardSourceCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSourceCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.plaintext, _this.plaintext) || other.plaintext == _this.plaintext)&&(identical(other.ciphertext, _this.ciphertext) || other.ciphertext == _this.ciphertext));
}


@override
int get hashCode {
  final _this = this as CardSourceCard;
  return Object.hash(runtimeType,_this.id,_this.name,_this.plaintext,_this.ciphertext);
}

@override
String toString() {
  final _this = this as CardSourceCard;
  return 'CardSourceCard(id: ${_this.id}, name: ${_this.name}, plaintext: ${_this.plaintext}, ciphertext: ${_this.ciphertext})';
}


}

/// @nodoc
abstract mixin class $CardSourceCardCopyWith<$Res>  {
  factory $CardSourceCardCopyWith(CardSourceCard value, $Res Function(CardSourceCard) _then) = _$CardSourceCardCopyWithImpl;
@useResult
$Res call({
 String id, String name, String plaintext, String ciphertext
});




}
/// @nodoc
class _$CardSourceCardCopyWithImpl<$Res>
    implements $CardSourceCardCopyWith<$Res> {
  _$CardSourceCardCopyWithImpl(this._self, this._then);

  final CardSourceCard _self;
  final $Res Function(CardSourceCard) _then;

/// Create a copy of CardSourceCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? plaintext = null,Object? ciphertext = null,}) {
  return _then(CardSourceCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plaintext: null == plaintext ? _self.plaintext : plaintext // ignore: cast_nullable_to_non_nullable
as String,ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardSourceCard].
extension CardSourceCardPatterns on CardSourceCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardSourceCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardSourceCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardSourceCard value)  $default,){
final _that = this;
switch (_that) {
case _CardSourceCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardSourceCard value)?  $default,){
final _that = this;
switch (_that) {
case _CardSourceCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String plaintext,  String ciphertext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardSourceCard() when $default != null:
return $default(_that.id,_that.name,_that.plaintext,_that.ciphertext);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String plaintext,  String ciphertext)  $default,) {final _that = this;
switch (_that) {
case _CardSourceCard():
return $default(_that.id,_that.name,_that.plaintext,_that.ciphertext);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String plaintext,  String ciphertext)?  $default,) {final _that = this;
switch (_that) {
case _CardSourceCard() when $default != null:
return $default(_that.id,_that.name,_that.plaintext,_that.ciphertext);case _:
  return null;

}
}

}

/// @nodoc


class _CardSourceCard implements CardSourceCard {
  const _CardSourceCard({required this.id, required this.name, required this.plaintext, required this.ciphertext});
  

@override final  String id;
@override final  String name;
@override final  String plaintext;
@override final  String ciphertext;

/// Create a copy of CardSourceCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardSourceCardCopyWith<_CardSourceCard> get copyWith => __$CardSourceCardCopyWithImpl<_CardSourceCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSourceCard&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.plaintext, plaintext) || other.plaintext == plaintext)&&(identical(other.ciphertext, ciphertext) || other.ciphertext == ciphertext));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,plaintext,ciphertext);
}

@override
String toString() {
    return 'CardSourceCard(id: $id, name: $name, plaintext: $plaintext, ciphertext: $ciphertext)';
}


}

/// @nodoc
abstract mixin class _$CardSourceCardCopyWith<$Res> implements $CardSourceCardCopyWith<$Res> {
  factory _$CardSourceCardCopyWith(_CardSourceCard value, $Res Function(_CardSourceCard) _then) = __$CardSourceCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String plaintext, String ciphertext
});




}
/// @nodoc
class __$CardSourceCardCopyWithImpl<$Res>
    implements _$CardSourceCardCopyWith<$Res> {
  __$CardSourceCardCopyWithImpl(this._self, this._then);

  final _CardSourceCard _self;
  final $Res Function(_CardSourceCard) _then;

/// Create a copy of CardSourceCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? plaintext = null,Object? ciphertext = null,}) {
  return _then(_CardSourceCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plaintext: null == plaintext ? _self.plaintext : plaintext // ignore: cast_nullable_to_non_nullable
as String,ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
