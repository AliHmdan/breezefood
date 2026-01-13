// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchHistoryResponseImpl _$$SearchHistoryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchHistoryResponseImpl(
      history: (json['history'] as List<dynamic>?)
              ?.map(
                  (e) => SearchHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SearchHistoryItem>[],
    );

Map<String, dynamic> _$$SearchHistoryResponseImplToJson(
        _$SearchHistoryResponseImpl instance) =>
    <String, dynamic>{
      'history': instance.history,
    };

_$SearchHistoryItemImpl _$$SearchHistoryItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchHistoryItemImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      query: json['query'] as String,
      searchedAt: json['searched_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$SearchHistoryItemImplToJson(
        _$SearchHistoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'query': instance.query,
      'searched_at': instance.searchedAt,
      'deleted_at': instance.deletedAt,
    };
