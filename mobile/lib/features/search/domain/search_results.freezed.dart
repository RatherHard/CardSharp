// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShelfSearchResults {

 SearchOutcome<DeckSearchHit> get decks; SearchOutcome<CardSearchHit> get cards;
/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfSearchResultsCopyWith<ShelfSearchResults> get copyWith => _$ShelfSearchResultsCopyWithImpl<ShelfSearchResults>(this as ShelfSearchResults, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ShelfSearchResults;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfSearchResults&&(identical(other.decks, _this.decks) || other.decks == _this.decks)&&(identical(other.cards, _this.cards) || other.cards == _this.cards));
}


@override
int get hashCode {
  final _this = this as ShelfSearchResults;
  return Object.hash(runtimeType,_this.decks,_this.cards);
}

@override
String toString() {
  final _this = this as ShelfSearchResults;
  return 'ShelfSearchResults(decks: ${_this.decks}, cards: ${_this.cards})';
}


}

/// @nodoc
abstract mixin class $ShelfSearchResultsCopyWith<$Res>  {
  factory $ShelfSearchResultsCopyWith(ShelfSearchResults value, $Res Function(ShelfSearchResults) _then) = _$ShelfSearchResultsCopyWithImpl;
@useResult
$Res call({
 SearchOutcome<DeckSearchHit> decks, SearchOutcome<CardSearchHit> cards
});


$SearchOutcomeCopyWith<DeckSearchHit, $Res> get decks;$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards;

}
/// @nodoc
class _$ShelfSearchResultsCopyWithImpl<$Res>
    implements $ShelfSearchResultsCopyWith<$Res> {
  _$ShelfSearchResultsCopyWithImpl(this._self, this._then);

  final ShelfSearchResults _self;
  final $Res Function(ShelfSearchResults) _then;

/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? decks = null,Object? cards = null,}) {
  return _then(ShelfSearchResults(
decks: null == decks ? _self.decks : decks // ignore: cast_nullable_to_non_nullable
as SearchOutcome<DeckSearchHit>,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as SearchOutcome<CardSearchHit>,
  ));
}
/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<DeckSearchHit, $Res> get decks {
  
  return $SearchOutcomeCopyWith<DeckSearchHit, $Res>(_self.decks, (value) {
    return _then(_self.copyWith(decks: value));
  });
}/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards {
  
  return $SearchOutcomeCopyWith<CardSearchHit, $Res>(_self.cards, (value) {
    return _then(_self.copyWith(cards: value));
  });
}
}


/// Adds pattern-matching-related methods to [ShelfSearchResults].
extension ShelfSearchResultsPatterns on ShelfSearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfSearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfSearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfSearchResults value)  $default,){
final _that = this;
switch (_that) {
case _ShelfSearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfSearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfSearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchOutcome<DeckSearchHit> decks,  SearchOutcome<CardSearchHit> cards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfSearchResults() when $default != null:
return $default(_that.decks,_that.cards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchOutcome<DeckSearchHit> decks,  SearchOutcome<CardSearchHit> cards)  $default,) {final _that = this;
switch (_that) {
case _ShelfSearchResults():
return $default(_that.decks,_that.cards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchOutcome<DeckSearchHit> decks,  SearchOutcome<CardSearchHit> cards)?  $default,) {final _that = this;
switch (_that) {
case _ShelfSearchResults() when $default != null:
return $default(_that.decks,_that.cards);case _:
  return null;

}
}

}

/// @nodoc


class _ShelfSearchResults extends ShelfSearchResults {
  const _ShelfSearchResults({required this.decks, required this.cards}): super._();
  

@override final  SearchOutcome<DeckSearchHit> decks;
@override final  SearchOutcome<CardSearchHit> cards;

/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfSearchResultsCopyWith<_ShelfSearchResults> get copyWith => __$ShelfSearchResultsCopyWithImpl<_ShelfSearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfSearchResults&&(identical(other.decks, decks) || other.decks == decks)&&(identical(other.cards, cards) || other.cards == cards));
}


@override
int get hashCode {
    return Object.hash(runtimeType,decks,cards);
}

@override
String toString() {
    return 'ShelfSearchResults(decks: $decks, cards: $cards)';
}


}

/// @nodoc
abstract mixin class _$ShelfSearchResultsCopyWith<$Res> implements $ShelfSearchResultsCopyWith<$Res> {
  factory _$ShelfSearchResultsCopyWith(_ShelfSearchResults value, $Res Function(_ShelfSearchResults) _then) = __$ShelfSearchResultsCopyWithImpl;
@override @useResult
$Res call({
 SearchOutcome<DeckSearchHit> decks, SearchOutcome<CardSearchHit> cards
});


@override $SearchOutcomeCopyWith<DeckSearchHit, $Res> get decks;@override $SearchOutcomeCopyWith<CardSearchHit, $Res> get cards;

}
/// @nodoc
class __$ShelfSearchResultsCopyWithImpl<$Res>
    implements _$ShelfSearchResultsCopyWith<$Res> {
  __$ShelfSearchResultsCopyWithImpl(this._self, this._then);

  final _ShelfSearchResults _self;
  final $Res Function(_ShelfSearchResults) _then;

/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? decks = null,Object? cards = null,}) {
  return _then(_ShelfSearchResults(
decks: null == decks ? _self.decks : decks // ignore: cast_nullable_to_non_nullable
as SearchOutcome<DeckSearchHit>,cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as SearchOutcome<CardSearchHit>,
  ));
}

/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<DeckSearchHit, $Res> get decks {
  
  return $SearchOutcomeCopyWith<DeckSearchHit, $Res>(_self.decks, (value) {
    return _then(_self.copyWith(decks: value));
  });
}/// Create a copy of ShelfSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards {
  
  return $SearchOutcomeCopyWith<CardSearchHit, $Res>(_self.cards, (value) {
    return _then(_self.copyWith(cards: value));
  });
}
}

/// @nodoc
mixin _$DeckSearchResults {

 SearchOutcome<CardSearchHit> get cards; DeckSearchHit? get deck;
/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckSearchResultsCopyWith<DeckSearchResults> get copyWith => _$DeckSearchResultsCopyWithImpl<DeckSearchResults>(this as DeckSearchResults, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeckSearchResults;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckSearchResults&&(identical(other.cards, _this.cards) || other.cards == _this.cards)&&(identical(other.deck, _this.deck) || other.deck == _this.deck));
}


@override
int get hashCode {
  final _this = this as DeckSearchResults;
  return Object.hash(runtimeType,_this.cards,_this.deck);
}

@override
String toString() {
  final _this = this as DeckSearchResults;
  return 'DeckSearchResults(cards: ${_this.cards}, deck: ${_this.deck})';
}


}

/// @nodoc
abstract mixin class $DeckSearchResultsCopyWith<$Res>  {
  factory $DeckSearchResultsCopyWith(DeckSearchResults value, $Res Function(DeckSearchResults) _then) = _$DeckSearchResultsCopyWithImpl;
@useResult
$Res call({
 SearchOutcome<CardSearchHit> cards, DeckSearchHit? deck
});


$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards;$DeckSearchHitCopyWith<$Res>? get deck;

}
/// @nodoc
class _$DeckSearchResultsCopyWithImpl<$Res>
    implements $DeckSearchResultsCopyWith<$Res> {
  _$DeckSearchResultsCopyWithImpl(this._self, this._then);

  final DeckSearchResults _self;
  final $Res Function(DeckSearchResults) _then;

/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cards = null,Object? deck = freezed,}) {
  return _then(DeckSearchResults(
cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as SearchOutcome<CardSearchHit>,deck: freezed == deck ? _self.deck : deck // ignore: cast_nullable_to_non_nullable
as DeckSearchHit?,
  ));
}
/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards {
  
  return $SearchOutcomeCopyWith<CardSearchHit, $Res>(_self.cards, (value) {
    return _then(_self.copyWith(cards: value));
  });
}/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeckSearchHitCopyWith<$Res>? get deck {
    if (_self.deck == null) {
    return null;
  }

  return $DeckSearchHitCopyWith<$Res>(_self.deck!, (value) {
    return _then(_self.copyWith(deck: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeckSearchResults].
extension DeckSearchResultsPatterns on DeckSearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckSearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckSearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckSearchResults value)  $default,){
final _that = this;
switch (_that) {
case _DeckSearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckSearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _DeckSearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchOutcome<CardSearchHit> cards,  DeckSearchHit? deck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckSearchResults() when $default != null:
return $default(_that.cards,_that.deck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchOutcome<CardSearchHit> cards,  DeckSearchHit? deck)  $default,) {final _that = this;
switch (_that) {
case _DeckSearchResults():
return $default(_that.cards,_that.deck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchOutcome<CardSearchHit> cards,  DeckSearchHit? deck)?  $default,) {final _that = this;
switch (_that) {
case _DeckSearchResults() when $default != null:
return $default(_that.cards,_that.deck);case _:
  return null;

}
}

}

/// @nodoc


class _DeckSearchResults extends DeckSearchResults {
  const _DeckSearchResults({required this.cards, this.deck}): super._();
  

@override final  SearchOutcome<CardSearchHit> cards;
@override final  DeckSearchHit? deck;

/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckSearchResultsCopyWith<_DeckSearchResults> get copyWith => __$DeckSearchResultsCopyWithImpl<_DeckSearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckSearchResults&&(identical(other.cards, cards) || other.cards == cards)&&(identical(other.deck, deck) || other.deck == deck));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cards,deck);
}

@override
String toString() {
    return 'DeckSearchResults(cards: $cards, deck: $deck)';
}


}

/// @nodoc
abstract mixin class _$DeckSearchResultsCopyWith<$Res> implements $DeckSearchResultsCopyWith<$Res> {
  factory _$DeckSearchResultsCopyWith(_DeckSearchResults value, $Res Function(_DeckSearchResults) _then) = __$DeckSearchResultsCopyWithImpl;
@override @useResult
$Res call({
 SearchOutcome<CardSearchHit> cards, DeckSearchHit? deck
});


@override $SearchOutcomeCopyWith<CardSearchHit, $Res> get cards;@override $DeckSearchHitCopyWith<$Res>? get deck;

}
/// @nodoc
class __$DeckSearchResultsCopyWithImpl<$Res>
    implements _$DeckSearchResultsCopyWith<$Res> {
  __$DeckSearchResultsCopyWithImpl(this._self, this._then);

  final _DeckSearchResults _self;
  final $Res Function(_DeckSearchResults) _then;

/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cards = null,Object? deck = freezed,}) {
  return _then(_DeckSearchResults(
cards: null == cards ? _self.cards : cards // ignore: cast_nullable_to_non_nullable
as SearchOutcome<CardSearchHit>,deck: freezed == deck ? _self.deck : deck // ignore: cast_nullable_to_non_nullable
as DeckSearchHit?,
  ));
}

/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<CardSearchHit, $Res> get cards {
  
  return $SearchOutcomeCopyWith<CardSearchHit, $Res>(_self.cards, (value) {
    return _then(_self.copyWith(cards: value));
  });
}/// Create a copy of DeckSearchResults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeckSearchHitCopyWith<$Res>? get deck {
    if (_self.deck == null) {
    return null;
  }

  return $DeckSearchHitCopyWith<$Res>(_self.deck!, (value) {
    return _then(_self.copyWith(deck: value));
  });
}
}

// dart format on
