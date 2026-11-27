// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MatchRange {

 int get start; int get end;
/// Create a copy of MatchRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchRangeCopyWith<MatchRange> get copyWith => _$MatchRangeCopyWithImpl<MatchRange>(this as MatchRange, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchRange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchRange&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end));
}


@override
int get hashCode {
  final _this = this as MatchRange;
  return Object.hash(runtimeType,_this.start,_this.end);
}

@override
String toString() {
  final _this = this as MatchRange;
  return 'MatchRange(start: ${_this.start}, end: ${_this.end})';
}


}

/// @nodoc
abstract mixin class $MatchRangeCopyWith<$Res>  {
  factory $MatchRangeCopyWith(MatchRange value, $Res Function(MatchRange) _then) = _$MatchRangeCopyWithImpl;
@useResult
$Res call({
 int start, int end
});




}
/// @nodoc
class _$MatchRangeCopyWithImpl<$Res>
    implements $MatchRangeCopyWith<$Res> {
  _$MatchRangeCopyWithImpl(this._self, this._then);

  final MatchRange _self;
  final $Res Function(MatchRange) _then;

/// Create a copy of MatchRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,}) {
  return _then(MatchRange(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchRange].
extension MatchRangePatterns on MatchRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchRange value)  $default,){
final _that = this;
switch (_that) {
case _MatchRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchRange value)?  $default,){
final _that = this;
switch (_that) {
case _MatchRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int start,  int end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchRange() when $default != null:
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int start,  int end)  $default,) {final _that = this;
switch (_that) {
case _MatchRange():
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int start,  int end)?  $default,) {final _that = this;
switch (_that) {
case _MatchRange() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc


class _MatchRange implements MatchRange {
  const _MatchRange({required this.start, required this.end});
  

@override final  int start;
@override final  int end;

/// Create a copy of MatchRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchRangeCopyWith<_MatchRange> get copyWith => __$MatchRangeCopyWithImpl<_MatchRange>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchRange&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,end);
}

@override
String toString() {
    return 'MatchRange(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$MatchRangeCopyWith<$Res> implements $MatchRangeCopyWith<$Res> {
  factory _$MatchRangeCopyWith(_MatchRange value, $Res Function(_MatchRange) _then) = __$MatchRangeCopyWithImpl;
@override @useResult
$Res call({
 int start, int end
});




}
/// @nodoc
class __$MatchRangeCopyWithImpl<$Res>
    implements _$MatchRangeCopyWith<$Res> {
  __$MatchRangeCopyWithImpl(this._self, this._then);

  final _MatchRange _self;
  final $Res Function(_MatchRange) _then;

/// Create a copy of MatchRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,}) {
  return _then(_MatchRange(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CardSearchHit {

 String get deckId; String get deckTitle; String get cardId;/// 卡片在列表里显示的名字（明文，或卡片页用的名字字段）。
 String get cardName;/// 命中所在的字段。
 CardMatchField get field;/// 用于展示的文本（命中所在的完整文本，可能被截断显示）。
 String get text;/// [text] 内的命中区间。
 List<MatchRange> get ranges;
/// Create a copy of CardSearchHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSearchHitCopyWith<CardSearchHit> get copyWith => _$CardSearchHitCopyWithImpl<CardSearchHit>(this as CardSearchHit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardSearchHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSearchHit&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.deckTitle, _this.deckTitle) || other.deckTitle == _this.deckTitle)&&(identical(other.cardId, _this.cardId) || other.cardId == _this.cardId)&&(identical(other.cardName, _this.cardName) || other.cardName == _this.cardName)&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.ranges, _this.ranges));
}


@override
int get hashCode {
  final _this = this as CardSearchHit;
  return Object.hash(runtimeType,_this.deckId,_this.deckTitle,_this.cardId,_this.cardName,_this.field,_this.text,const DeepCollectionEquality().hash(_this.ranges));
}

@override
String toString() {
  final _this = this as CardSearchHit;
  return 'CardSearchHit(deckId: ${_this.deckId}, deckTitle: ${_this.deckTitle}, cardId: ${_this.cardId}, cardName: ${_this.cardName}, field: ${_this.field}, text: ${_this.text}, ranges: ${_this.ranges})';
}


}

/// @nodoc
abstract mixin class $CardSearchHitCopyWith<$Res>  {
  factory $CardSearchHitCopyWith(CardSearchHit value, $Res Function(CardSearchHit) _then) = _$CardSearchHitCopyWithImpl;
@useResult
$Res call({
 String deckId, String deckTitle, String cardId, String cardName, CardMatchField field, String text, List<MatchRange> ranges
});




}
/// @nodoc
class _$CardSearchHitCopyWithImpl<$Res>
    implements $CardSearchHitCopyWith<$Res> {
  _$CardSearchHitCopyWithImpl(this._self, this._then);

  final CardSearchHit _self;
  final $Res Function(CardSearchHit) _then;

/// Create a copy of CardSearchHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deckId = null,Object? deckTitle = null,Object? cardId = null,Object? cardName = null,Object? field = null,Object? text = null,Object? ranges = null,}) {
  return _then(CardSearchHit(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,deckTitle: null == deckTitle ? _self.deckTitle : deckTitle // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,cardName: null == cardName ? _self.cardName : cardName // ignore: cast_nullable_to_non_nullable
as String,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as CardMatchField,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,ranges: null == ranges ? _self.ranges : ranges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,
  ));
}

}


/// Adds pattern-matching-related methods to [CardSearchHit].
extension CardSearchHitPatterns on CardSearchHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardSearchHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardSearchHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardSearchHit value)  $default,){
final _that = this;
switch (_that) {
case _CardSearchHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardSearchHit value)?  $default,){
final _that = this;
switch (_that) {
case _CardSearchHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deckId,  String deckTitle,  String cardId,  String cardName,  CardMatchField field,  String text,  List<MatchRange> ranges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardSearchHit() when $default != null:
return $default(_that.deckId,_that.deckTitle,_that.cardId,_that.cardName,_that.field,_that.text,_that.ranges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deckId,  String deckTitle,  String cardId,  String cardName,  CardMatchField field,  String text,  List<MatchRange> ranges)  $default,) {final _that = this;
switch (_that) {
case _CardSearchHit():
return $default(_that.deckId,_that.deckTitle,_that.cardId,_that.cardName,_that.field,_that.text,_that.ranges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deckId,  String deckTitle,  String cardId,  String cardName,  CardMatchField field,  String text,  List<MatchRange> ranges)?  $default,) {final _that = this;
switch (_that) {
case _CardSearchHit() when $default != null:
return $default(_that.deckId,_that.deckTitle,_that.cardId,_that.cardName,_that.field,_that.text,_that.ranges);case _:
  return null;

}
}

}

/// @nodoc


class _CardSearchHit implements CardSearchHit {
  const _CardSearchHit({required this.deckId, required this.deckTitle, required this.cardId, required this.cardName, required this.field, required this.text, required  List<MatchRange> ranges}): _ranges = ranges;
  

@override final  String deckId;
@override final  String deckTitle;
@override final  String cardId;
/// 卡片在列表里显示的名字（明文，或卡片页用的名字字段）。
@override final  String cardName;
/// 命中所在的字段。
@override final  CardMatchField field;
/// 用于展示的文本（命中所在的完整文本，可能被截断显示）。
@override final  String text;
/// [text] 内的命中区间。
 final  List<MatchRange> _ranges;
/// [text] 内的命中区间。
@override List<MatchRange> get ranges {
  if (_ranges is EqualUnmodifiableListView) return _ranges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranges);
}


/// Create a copy of CardSearchHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardSearchHitCopyWith<_CardSearchHit> get copyWith => __$CardSearchHitCopyWithImpl<_CardSearchHit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSearchHit&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.deckTitle, deckTitle) || other.deckTitle == deckTitle)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.cardName, cardName) || other.cardName == cardName)&&(identical(other.field, field) || other.field == field)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.ranges, _ranges));
}


@override
int get hashCode {
    return Object.hash(runtimeType,deckId,deckTitle,cardId,cardName,field,text,const DeepCollectionEquality().hash(_ranges));
}

@override
String toString() {
    return 'CardSearchHit(deckId: $deckId, deckTitle: $deckTitle, cardId: $cardId, cardName: $cardName, field: $field, text: $text, ranges: $ranges)';
}


}

/// @nodoc
abstract mixin class _$CardSearchHitCopyWith<$Res> implements $CardSearchHitCopyWith<$Res> {
  factory _$CardSearchHitCopyWith(_CardSearchHit value, $Res Function(_CardSearchHit) _then) = __$CardSearchHitCopyWithImpl;
@override @useResult
$Res call({
 String deckId, String deckTitle, String cardId, String cardName, CardMatchField field, String text, List<MatchRange> ranges
});




}
/// @nodoc
class __$CardSearchHitCopyWithImpl<$Res>
    implements _$CardSearchHitCopyWith<$Res> {
  __$CardSearchHitCopyWithImpl(this._self, this._then);

  final _CardSearchHit _self;
  final $Res Function(_CardSearchHit) _then;

/// Create a copy of CardSearchHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deckId = null,Object? deckTitle = null,Object? cardId = null,Object? cardName = null,Object? field = null,Object? text = null,Object? ranges = null,}) {
  return _then(_CardSearchHit(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,deckTitle: null == deckTitle ? _self.deckTitle : deckTitle // ignore: cast_nullable_to_non_nullable
as String,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,cardName: null == cardName ? _self.cardName : cardName // ignore: cast_nullable_to_non_nullable
as String,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as CardMatchField,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,ranges: null == ranges ? _self._ranges : ranges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,
  ));
}


}

/// @nodoc
mixin _$DeckSearchHit {

 String get deckId; String get title; String get description;/// 名称内的命中区间。
 List<MatchRange> get titleRanges;/// 简介内的命中区间。
 List<MatchRange> get descriptionRanges;/// 卡片数，用于和书架卡片保持一致。
 int get cardCount;/// 卡片集颜色，用于结果里的封面着色。
 String get color;
/// Create a copy of DeckSearchHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckSearchHitCopyWith<DeckSearchHit> get copyWith => _$DeckSearchHitCopyWithImpl<DeckSearchHit>(this as DeckSearchHit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeckSearchHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckSearchHit&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.titleRanges, _this.titleRanges)&&const DeepCollectionEquality().equals(other.descriptionRanges, _this.descriptionRanges)&&(identical(other.cardCount, _this.cardCount) || other.cardCount == _this.cardCount)&&(identical(other.color, _this.color) || other.color == _this.color));
}


@override
int get hashCode {
  final _this = this as DeckSearchHit;
  return Object.hash(runtimeType,_this.deckId,_this.title,_this.description,const DeepCollectionEquality().hash(_this.titleRanges),const DeepCollectionEquality().hash(_this.descriptionRanges),_this.cardCount,_this.color);
}

@override
String toString() {
  final _this = this as DeckSearchHit;
  return 'DeckSearchHit(deckId: ${_this.deckId}, title: ${_this.title}, description: ${_this.description}, titleRanges: ${_this.titleRanges}, descriptionRanges: ${_this.descriptionRanges}, cardCount: ${_this.cardCount}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $DeckSearchHitCopyWith<$Res>  {
  factory $DeckSearchHitCopyWith(DeckSearchHit value, $Res Function(DeckSearchHit) _then) = _$DeckSearchHitCopyWithImpl;
@useResult
$Res call({
 String deckId, String title, String description, List<MatchRange> titleRanges, List<MatchRange> descriptionRanges, int cardCount, String color
});




}
/// @nodoc
class _$DeckSearchHitCopyWithImpl<$Res>
    implements $DeckSearchHitCopyWith<$Res> {
  _$DeckSearchHitCopyWithImpl(this._self, this._then);

  final DeckSearchHit _self;
  final $Res Function(DeckSearchHit) _then;

/// Create a copy of DeckSearchHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deckId = null,Object? title = null,Object? description = null,Object? titleRanges = null,Object? descriptionRanges = null,Object? cardCount = null,Object? color = null,}) {
  return _then(DeckSearchHit(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,titleRanges: null == titleRanges ? _self.titleRanges : titleRanges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,descriptionRanges: null == descriptionRanges ? _self.descriptionRanges : descriptionRanges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckSearchHit].
extension DeckSearchHitPatterns on DeckSearchHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckSearchHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckSearchHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckSearchHit value)  $default,){
final _that = this;
switch (_that) {
case _DeckSearchHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckSearchHit value)?  $default,){
final _that = this;
switch (_that) {
case _DeckSearchHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deckId,  String title,  String description,  List<MatchRange> titleRanges,  List<MatchRange> descriptionRanges,  int cardCount,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckSearchHit() when $default != null:
return $default(_that.deckId,_that.title,_that.description,_that.titleRanges,_that.descriptionRanges,_that.cardCount,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deckId,  String title,  String description,  List<MatchRange> titleRanges,  List<MatchRange> descriptionRanges,  int cardCount,  String color)  $default,) {final _that = this;
switch (_that) {
case _DeckSearchHit():
return $default(_that.deckId,_that.title,_that.description,_that.titleRanges,_that.descriptionRanges,_that.cardCount,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deckId,  String title,  String description,  List<MatchRange> titleRanges,  List<MatchRange> descriptionRanges,  int cardCount,  String color)?  $default,) {final _that = this;
switch (_that) {
case _DeckSearchHit() when $default != null:
return $default(_that.deckId,_that.title,_that.description,_that.titleRanges,_that.descriptionRanges,_that.cardCount,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _DeckSearchHit implements DeckSearchHit {
  const _DeckSearchHit({required this.deckId, required this.title, required this.description, required  List<MatchRange> titleRanges, required  List<MatchRange> descriptionRanges, required this.cardCount, this.color = ''}): _titleRanges = titleRanges,_descriptionRanges = descriptionRanges;
  

@override final  String deckId;
@override final  String title;
@override final  String description;
/// 名称内的命中区间。
 final  List<MatchRange> _titleRanges;
/// 名称内的命中区间。
@override List<MatchRange> get titleRanges {
  if (_titleRanges is EqualUnmodifiableListView) return _titleRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_titleRanges);
}

/// 简介内的命中区间。
 final  List<MatchRange> _descriptionRanges;
/// 简介内的命中区间。
@override List<MatchRange> get descriptionRanges {
  if (_descriptionRanges is EqualUnmodifiableListView) return _descriptionRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_descriptionRanges);
}

/// 卡片数，用于和书架卡片保持一致。
@override final  int cardCount;
/// 卡片集颜色，用于结果里的封面着色。
@override@JsonKey() final  String color;

/// Create a copy of DeckSearchHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckSearchHitCopyWith<_DeckSearchHit> get copyWith => __$DeckSearchHitCopyWithImpl<_DeckSearchHit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckSearchHit&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.titleRanges, _titleRanges)&&const DeepCollectionEquality().equals(other.descriptionRanges, _descriptionRanges)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode {
    return Object.hash(runtimeType,deckId,title,description,const DeepCollectionEquality().hash(_titleRanges),const DeepCollectionEquality().hash(_descriptionRanges),cardCount,color);
}

@override
String toString() {
    return 'DeckSearchHit(deckId: $deckId, title: $title, description: $description, titleRanges: $titleRanges, descriptionRanges: $descriptionRanges, cardCount: $cardCount, color: $color)';
}


}

/// @nodoc
abstract mixin class _$DeckSearchHitCopyWith<$Res> implements $DeckSearchHitCopyWith<$Res> {
  factory _$DeckSearchHitCopyWith(_DeckSearchHit value, $Res Function(_DeckSearchHit) _then) = __$DeckSearchHitCopyWithImpl;
@override @useResult
$Res call({
 String deckId, String title, String description, List<MatchRange> titleRanges, List<MatchRange> descriptionRanges, int cardCount, String color
});




}
/// @nodoc
class __$DeckSearchHitCopyWithImpl<$Res>
    implements _$DeckSearchHitCopyWith<$Res> {
  __$DeckSearchHitCopyWithImpl(this._self, this._then);

  final _DeckSearchHit _self;
  final $Res Function(_DeckSearchHit) _then;

/// Create a copy of DeckSearchHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deckId = null,Object? title = null,Object? description = null,Object? titleRanges = null,Object? descriptionRanges = null,Object? cardCount = null,Object? color = null,}) {
  return _then(_DeckSearchHit(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,titleRanges: null == titleRanges ? _self._titleRanges : titleRanges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,descriptionRanges: null == descriptionRanges ? _self._descriptionRanges : descriptionRanges // ignore: cast_nullable_to_non_nullable
as List<MatchRange>,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SearchOutcome<T> {

 List<T> get hits; int get totalMatches; bool get scanLimitReached; int get scannedCount;
/// Create a copy of SearchOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchOutcomeCopyWith<T, SearchOutcome<T>> get copyWith => _$SearchOutcomeCopyWithImpl<T, SearchOutcome<T>>(this as SearchOutcome<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchOutcome<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchOutcome<T>&&const DeepCollectionEquality().equals(other.hits, _this.hits)&&(identical(other.totalMatches, _this.totalMatches) || other.totalMatches == _this.totalMatches)&&(identical(other.scanLimitReached, _this.scanLimitReached) || other.scanLimitReached == _this.scanLimitReached)&&(identical(other.scannedCount, _this.scannedCount) || other.scannedCount == _this.scannedCount));
}


@override
int get hashCode {
  final _this = this as SearchOutcome<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.hits),_this.totalMatches,_this.scanLimitReached,_this.scannedCount);
}

@override
String toString() {
  final _this = this as SearchOutcome<T>;
  return 'SearchOutcome<$T>(hits: ${_this.hits}, totalMatches: ${_this.totalMatches}, scanLimitReached: ${_this.scanLimitReached}, scannedCount: ${_this.scannedCount})';
}


}

/// @nodoc
abstract mixin class $SearchOutcomeCopyWith<T,$Res>  {
  factory $SearchOutcomeCopyWith(SearchOutcome<T> value, $Res Function(SearchOutcome<T>) _then) = _$SearchOutcomeCopyWithImpl;
@useResult
$Res call({
 List<T> hits, int totalMatches, bool scanLimitReached, int scannedCount
});




}
/// @nodoc
class _$SearchOutcomeCopyWithImpl<T,$Res>
    implements $SearchOutcomeCopyWith<T, $Res> {
  _$SearchOutcomeCopyWithImpl(this._self, this._then);

  final SearchOutcome<T> _self;
  final $Res Function(SearchOutcome<T>) _then;

/// Create a copy of SearchOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hits = null,Object? totalMatches = null,Object? scanLimitReached = null,Object? scannedCount = null,}) {
  return _then(SearchOutcome(
hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<T>,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,scanLimitReached: null == scanLimitReached ? _self.scanLimitReached : scanLimitReached // ignore: cast_nullable_to_non_nullable
as bool,scannedCount: null == scannedCount ? _self.scannedCount : scannedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchOutcome].
extension SearchOutcomePatterns<T> on SearchOutcome<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchOutcome<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchOutcome<T> value)  $default,){
final _that = this;
switch (_that) {
case _SearchOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchOutcome<T> value)?  $default,){
final _that = this;
switch (_that) {
case _SearchOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> hits,  int totalMatches,  bool scanLimitReached,  int scannedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchOutcome() when $default != null:
return $default(_that.hits,_that.totalMatches,_that.scanLimitReached,_that.scannedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> hits,  int totalMatches,  bool scanLimitReached,  int scannedCount)  $default,) {final _that = this;
switch (_that) {
case _SearchOutcome():
return $default(_that.hits,_that.totalMatches,_that.scanLimitReached,_that.scannedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> hits,  int totalMatches,  bool scanLimitReached,  int scannedCount)?  $default,) {final _that = this;
switch (_that) {
case _SearchOutcome() when $default != null:
return $default(_that.hits,_that.totalMatches,_that.scanLimitReached,_that.scannedCount);case _:
  return null;

}
}

}

/// @nodoc


class _SearchOutcome<T> extends SearchOutcome<T> {
  const _SearchOutcome({required  List<T> hits, required this.totalMatches, this.scanLimitReached = false, this.scannedCount = 0}): _hits = hits,super._();
  

 final  List<T> _hits;
@override List<T> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}

@override final  int totalMatches;
@override@JsonKey() final  bool scanLimitReached;
@override@JsonKey() final  int scannedCount;

/// Create a copy of SearchOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchOutcomeCopyWith<T, _SearchOutcome<T>> get copyWith => __$SearchOutcomeCopyWithImpl<T, _SearchOutcome<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchOutcome<T>&&const DeepCollectionEquality().equals(other.hits, _hits)&&(identical(other.totalMatches, totalMatches) || other.totalMatches == totalMatches)&&(identical(other.scanLimitReached, scanLimitReached) || other.scanLimitReached == scanLimitReached)&&(identical(other.scannedCount, scannedCount) || other.scannedCount == scannedCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_hits),totalMatches,scanLimitReached,scannedCount);
}

@override
String toString() {
    return 'SearchOutcome<$T>(hits: $hits, totalMatches: $totalMatches, scanLimitReached: $scanLimitReached, scannedCount: $scannedCount)';
}


}

/// @nodoc
abstract mixin class _$SearchOutcomeCopyWith<T,$Res> implements $SearchOutcomeCopyWith<T, $Res> {
  factory _$SearchOutcomeCopyWith(_SearchOutcome<T> value, $Res Function(_SearchOutcome<T>) _then) = __$SearchOutcomeCopyWithImpl;
@override @useResult
$Res call({
 List<T> hits, int totalMatches, bool scanLimitReached, int scannedCount
});




}
/// @nodoc
class __$SearchOutcomeCopyWithImpl<T,$Res>
    implements _$SearchOutcomeCopyWith<T, $Res> {
  __$SearchOutcomeCopyWithImpl(this._self, this._then);

  final _SearchOutcome<T> _self;
  final $Res Function(_SearchOutcome<T>) _then;

/// Create a copy of SearchOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hits = null,Object? totalMatches = null,Object? scanLimitReached = null,Object? scannedCount = null,}) {
  return _then(_SearchOutcome<T>(
hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<T>,totalMatches: null == totalMatches ? _self.totalMatches : totalMatches // ignore: cast_nullable_to_non_nullable
as int,scanLimitReached: null == scanLimitReached ? _self.scanLimitReached : scanLimitReached // ignore: cast_nullable_to_non_nullable
as bool,scannedCount: null == scannedCount ? _self.scannedCount : scannedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
