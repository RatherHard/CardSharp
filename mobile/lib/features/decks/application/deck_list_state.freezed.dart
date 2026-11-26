// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeckListState {

 List<Deck> get decks; String? get nextCursor; bool get loadingMore;
/// Create a copy of DeckListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckListStateCopyWith<DeckListState> get copyWith => _$DeckListStateCopyWithImpl<DeckListState>(this as DeckListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeckListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckListState&&const DeepCollectionEquality().equals(other.decks, _this.decks)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.loadingMore, _this.loadingMore) || other.loadingMore == _this.loadingMore));
}


@override
int get hashCode {
  final _this = this as DeckListState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.decks),_this.nextCursor,_this.loadingMore);
}

@override
String toString() {
  final _this = this as DeckListState;
  return 'DeckListState(decks: ${_this.decks}, nextCursor: ${_this.nextCursor}, loadingMore: ${_this.loadingMore})';
}


}

/// @nodoc
abstract mixin class $DeckListStateCopyWith<$Res>  {
  factory $DeckListStateCopyWith(DeckListState value, $Res Function(DeckListState) _then) = _$DeckListStateCopyWithImpl;
@useResult
$Res call({
 List<Deck> decks, String? nextCursor, bool loadingMore
});




}
/// @nodoc
class _$DeckListStateCopyWithImpl<$Res>
    implements $DeckListStateCopyWith<$Res> {
  _$DeckListStateCopyWithImpl(this._self, this._then);

  final DeckListState _self;
  final $Res Function(DeckListState) _then;

/// Create a copy of DeckListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? decks = null,Object? nextCursor = freezed,Object? loadingMore = null,}) {
  return _then(DeckListState(
decks: null == decks ? _self.decks : decks // ignore: cast_nullable_to_non_nullable
as List<Deck>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckListState].
extension DeckListStatePatterns on DeckListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckListState value)  $default,){
final _that = this;
switch (_that) {
case _DeckListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckListState value)?  $default,){
final _that = this;
switch (_that) {
case _DeckListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Deck> decks,  String? nextCursor,  bool loadingMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckListState() when $default != null:
return $default(_that.decks,_that.nextCursor,_that.loadingMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Deck> decks,  String? nextCursor,  bool loadingMore)  $default,) {final _that = this;
switch (_that) {
case _DeckListState():
return $default(_that.decks,_that.nextCursor,_that.loadingMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Deck> decks,  String? nextCursor,  bool loadingMore)?  $default,) {final _that = this;
switch (_that) {
case _DeckListState() when $default != null:
return $default(_that.decks,_that.nextCursor,_that.loadingMore);case _:
  return null;

}
}

}

/// @nodoc


class _DeckListState extends DeckListState {
  const _DeckListState({required  List<Deck> decks, this.nextCursor, this.loadingMore = false}): _decks = decks,super._();
  

 final  List<Deck> _decks;
@override List<Deck> get decks {
  if (_decks is EqualUnmodifiableListView) return _decks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decks);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool loadingMore;

/// Create a copy of DeckListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckListStateCopyWith<_DeckListState> get copyWith => __$DeckListStateCopyWithImpl<_DeckListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckListState&&const DeepCollectionEquality().equals(other.decks, _decks)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_decks),nextCursor,loadingMore);
}

@override
String toString() {
    return 'DeckListState(decks: $decks, nextCursor: $nextCursor, loadingMore: $loadingMore)';
}


}

/// @nodoc
abstract mixin class _$DeckListStateCopyWith<$Res> implements $DeckListStateCopyWith<$Res> {
  factory _$DeckListStateCopyWith(_DeckListState value, $Res Function(_DeckListState) _then) = __$DeckListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Deck> decks, String? nextCursor, bool loadingMore
});




}
/// @nodoc
class __$DeckListStateCopyWithImpl<$Res>
    implements _$DeckListStateCopyWith<$Res> {
  __$DeckListStateCopyWithImpl(this._self, this._then);

  final _DeckListState _self;
  final $Res Function(_DeckListState) _then;

/// Create a copy of DeckListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? decks = null,Object? nextCursor = freezed,Object? loadingMore = null,}) {
  return _then(_DeckListState(
decks: null == decks ? _self._decks : decks // ignore: cast_nullable_to_non_nullable
as List<Deck>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
