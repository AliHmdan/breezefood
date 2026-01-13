// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResponseImpl _$$SearchResponseImplFromJson(Map<String, dynamic> json) =>
    _$SearchResponseImpl(
      success: json['success'] as bool,
      hasCoordinates: json['has_coordinates'] as bool,
      provinceDetected: json['province_detected'] as String?,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SearchBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SearchBlock>[],
    );

Map<String, dynamic> _$$SearchResponseImplToJson(
        _$SearchResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'has_coordinates': instance.hasCoordinates,
      'province_detected': instance.provinceDetected,
      'data': instance.data,
    };

_$SearchBlockImpl _$$SearchBlockImplFromJson(Map<String, dynamic> json) =>
    _$SearchBlockImpl(
      restaurant:
          SearchRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SearchItem>[],
    );

Map<String, dynamic> _$$SearchBlockImplToJson(_$SearchBlockImpl instance) =>
    <String, dynamic>{
      'restaurant': instance.restaurant,
      'items': instance.items,
    };

_$SearchRestaurantImpl _$$SearchRestaurantImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchRestaurantImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String?,
      rating: json['rating'] == null
          ? null
          : SearchRating.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SearchRestaurantImplToJson(
        _$SearchRestaurantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'rating': instance.rating,
    };

_$SearchRatingImpl _$$SearchRatingImplFromJson(Map<String, dynamic> json) =>
    _$SearchRatingImpl(
      avg: (json['avg'] as num?)?.toDouble(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SearchRatingImplToJson(_$SearchRatingImpl instance) =>
    <String, dynamic>{
      'avg': instance.avg,
      'count': instance.count,
    };

_$SearchItemImpl _$$SearchItemImplFromJson(Map<String, dynamic> json) =>
    _$SearchItemImpl(
      id: (json['id'] as num).toInt(),
      basePrice: json['base_price'] as String,
      names: SearchItemNames.fromJson(json['names'] as Map<String, dynamic>),
      ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$SearchItemImplToJson(_$SearchItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'base_price': instance.basePrice,
      'names': instance.names,
      'orders_count': instance.ordersCount,
      'image_url': instance.imageUrl,
    };

_$SearchItemNamesImpl _$$SearchItemNamesImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchItemNamesImpl(
      ar: json['ar'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );

Map<String, dynamic> _$$SearchItemNamesImplToJson(
        _$SearchItemNamesImpl instance) =>
    <String, dynamic>{
      'ar': instance.ar,
      'en': instance.en,
    };
