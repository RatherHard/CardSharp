// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deck {

 String get id; String get title; String get description;/// 封面色，形如 `#RRGGBB`；空串表示用主题默认色。
/// 对应后端 `decks.color`（`docs/03` §4.2）——后端只有颜色，没有封面图片。
 String get color;/// 卡片类型，默认 `memory`（`docs/02` FR-2.2）。后续会有选择题等类型。
 String get cardType;/// 所属文件夹 id；null 表示未归类（`docs/02` FR-2.1）。
 String? get folderId;/// 卡片集配置，对应后端 `decks.config`（jsonb）。
/// 内部结构由后端定义（`docs/03` §4.3），客户端原样透传、不解析。
 Map<String, dynamic> get config;/// 后端 `decks.stats`（jsonb）。文档只说明是「冗余统计，异步更新」，
/// 未定义内部字段名，因此原样保留，等后端给出字段后再拆成结构化对象。
 Map<String, dynamic> get stats;/// 卡片数，仅用于界面展示。
///
/// **不参与序列化**：它必须由后端 `stats` 提供，客户端不能自己算，
/// 更不能把它发回服务端覆盖统计值。接后端后由 `stats` 映射填充。
@JsonKey(includeFromJson: false, includeToJson: false) int get cardCount;
/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckCopyWith<Deck> get copyWith => _$DeckCopyWithImpl<Deck>(this as Deck, _$identity);

  /// Serializes this Deck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Deck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deck&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.cardType, _this.cardType) || other.cardType == _this.cardType)&&(identical(other.folderId, _this.folderId) || other.folderId == _this.folderId)&&const DeepCollectionEquality().equals(other.config, _this.config)&&const DeepCollectionEquality().equals(other.stats, _this.stats)&&(identical(other.cardCount, _this.cardCount) || other.cardCount == _this.cardCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Deck;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.color,_this.cardType,_this.folderId,const DeepCollectionEquality().hash(_this.config),const DeepCollectionEquality().hash(_this.stats),_this.cardCount);
}

@override
String toString() {
  final _this = this as Deck;
  return 'Deck(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, color: ${_this.color}, cardType: ${_this.cardType}, folderId: ${_this.folderId}, config: ${_this.config}, stats: ${_this.stats}, cardCount: ${_this.cardCount})';
}


}

/// @nodoc
abstract mixin class $DeckCopyWith<$Res>  {
  factory $DeckCopyWith(Deck value, $Res Function(Deck) _then) = _$DeckCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String color, String cardType, String? folderId, Map<String, dynamic> config, Map<String, dynamic> stats,@JsonKey(includeFromJson: false, includeToJson: false) int cardCount
});




}
/// @nodoc
class _$DeckCopyWithImpl<$Res>
    implements $DeckCopyWith<$Res> {
  _$DeckCopyWithImpl(this._self, this._then);

  final Deck _self;
  final $Res Function(Deck) _then;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? color = null,Object? cardType = null,Object? folderId = freezed,Object? config = null,Object? stats = null,Object? cardCount = null,}) {
  return _then(Deck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Deck].
extension DeckPatterns on Deck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deck value)  $default,){
final _that = this;
switch (_that) {
case _Deck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deck value)?  $default,){
final _that = this;
switch (_that) {
case _Deck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String color,  String cardType,  String? folderId,  Map<String, dynamic> config,  Map<String, dynamic> stats, @JsonKey(includeFromJson: false, includeToJson: false)  int cardCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.color,_that.cardType,_that.folderId,_that.config,_that.stats,_that.cardCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String color,  String cardType,  String? folderId,  Map<String, dynamic> config,  Map<String, dynamic> stats, @JsonKey(includeFromJson: false, includeToJson: false)  int cardCount)  $default,) {final _that = this;
switch (_that) {
case _Deck():
return $default(_that.id,_that.title,_that.description,_that.color,_that.cardType,_that.folderId,_that.config,_that.stats,_that.cardCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String color,  String cardType,  String? folderId,  Map<String, dynamic> config,  Map<String, dynamic> stats, @JsonKey(includeFromJson: false, includeToJson: false)  int cardCount)?  $default,) {final _that = this;
switch (_that) {
case _Deck() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.color,_that.cardType,_that.folderId,_that.config,_that.stats,_that.cardCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Deck implements Deck {
  const _Deck({required this.id, required this.title, this.description = '', this.color = '', this.cardType = 'memory', this.folderId,  Map<String, dynamic> config = const <String, dynamic>{},  Map<String, dynamic> stats = const <String, dynamic>{}, @JsonKey(includeFromJson: false, includeToJson: false) this.cardCount = 0}): _config = config,_stats = stats;
  factory _Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
/// 封面色，形如 `#RRGGBB`；空串表示用主题默认色。
/// 对应后端 `decks.color`（`docs/03` §4.2）——后端只有颜色，没有封面图片。
@override@JsonKey() final  String color;
/// 卡片类型，默认 `memory`（`docs/02` FR-2.2）。后续会有选择题等类型。
@override@JsonKey() final  String cardType;
/// 所属文件夹 id；null 表示未归类（`docs/02` FR-2.1）。
@override final  String? folderId;
/// 卡片集配置，对应后端 `decks.config`（jsonb）。
/// 内部结构由后端定义（`docs/03` §4.3），客户端原样透传、不解析。
 final  Map<String, dynamic> _config;
/// 卡片集配置，对应后端 `decks.config`（jsonb）。
/// 内部结构由后端定义（`docs/03` §4.3），客户端原样透传、不解析。
@override@JsonKey() Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

/// 后端 `decks.stats`（jsonb）。文档只说明是「冗余统计，异步更新」，
/// 未定义内部字段名，因此原样保留，等后端给出字段后再拆成结构化对象。
 final  Map<String, dynamic> _stats;
/// 后端 `decks.stats`（jsonb）。文档只说明是「冗余统计，异步更新」，
/// 未定义内部字段名，因此原样保留，等后端给出字段后再拆成结构化对象。
@override@JsonKey() Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

/// 卡片数，仅用于界面展示。
///
/// **不参与序列化**：它必须由后端 `stats` 提供，客户端不能自己算，
/// 更不能把它发回服务端覆盖统计值。接后端后由 `stats` 映射填充。
@override@JsonKey(includeFromJson: false, includeToJson: false) final  int cardCount;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckCopyWith<_Deck> get copyWith => __$DeckCopyWithImpl<_Deck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deck&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.folderId, folderId) || other.folderId == folderId)&&const DeepCollectionEquality().equals(other.config, _config)&&const DeepCollectionEquality().equals(other.stats, _stats)&&(identical(other.cardCount, cardCount) || other.cardCount == cardCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,color,cardType,folderId,const DeepCollectionEquality().hash(_config),const DeepCollectionEquality().hash(_stats),cardCount);
}

@override
String toString() {
    return 'Deck(id: $id, title: $title, description: $description, color: $color, cardType: $cardType, folderId: $folderId, config: $config, stats: $stats, cardCount: $cardCount)';
}


}

/// @nodoc
abstract mixin class _$DeckCopyWith<$Res> implements $DeckCopyWith<$Res> {
  factory _$DeckCopyWith(_Deck value, $Res Function(_Deck) _then) = __$DeckCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String color, String cardType, String? folderId, Map<String, dynamic> config, Map<String, dynamic> stats,@JsonKey(includeFromJson: false, includeToJson: false) int cardCount
});




}
/// @nodoc
class __$DeckCopyWithImpl<$Res>
    implements _$DeckCopyWith<$Res> {
  __$DeckCopyWithImpl(this._self, this._then);

  final _Deck _self;
  final $Res Function(_Deck) _then;

/// Create a copy of Deck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? color = null,Object? cardType = null,Object? folderId = freezed,Object? config = null,Object? stats = null,Object? cardCount = null,}) {
  return _then(_Deck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,cardType: null == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,cardCount: null == cardCount ? _self.cardCount : cardCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
