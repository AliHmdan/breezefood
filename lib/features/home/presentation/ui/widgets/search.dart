import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/cubit/home_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:breezefood/features/orders/add_order.dart';

/// بلوك: مطعم + قائمة وجباته (من HomeResponse)
class RestaurantSearchBlock {
  final RestaurantModel restaurant;
  final List<MenuItemModel> items;
  RestaurantSearchBlock({required this.restaurant, required this.items});
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _searchFieldKey = GlobalKey();

  late final HomeCubit cubit;

  final List<String> searchTags = [];
  final List<String> _history = ["Burger", "Shawarma", "Pizza"];

  final List<String> allSuggestions = const [
    "Syrian food",
    "Desserts",
    "Drinks",
  ];
  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  List<RestaurantSearchBlock> _results = [];

  @override
  void initState() {
    super.initState();
    cubit = getIt<HomeCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _filterSuggestions(_controller.text);
        setState(() => showSuggestions = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    // ✅ لا تعمل close لأنه غالباً Singleton من getIt
    super.dispose();
  }

  void _filterSuggestions(String input) {
    final q = input.trim().toLowerCase();
    final base = {..._history, ...allSuggestions}.toList();

    setState(() {
      showSuggestions = true;
      filteredSuggestions = base
          .where((s) => s.toLowerCase().contains(q) && !searchTags.contains(s))
          .toList();
    });
  }

  void _addTag(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    if (!searchTags.contains(t)) {
      setState(() => searchTags.add(t));
    }
  }

  void _removeTag(String tag) => setState(() => searchTags.remove(tag));

  void _applySuggestionToField(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() => showSuggestions = false);
  }

  /// ✅ البحث الحقيقي: فلترة بيانات HomeResponse
  void _performSearchOn(HomeResponse data) {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return;

    _addTag(q);
    setState(() => showSuggestions = false);
    _focusNode.unfocus();

    final allItems = <MenuItemModel>[...data.mostPopular, ...data.discounts];

    final filteredItems = allItems.where((it) {
      final name = (it.nameAr ?? "").toLowerCase();
      final en = (it.nameEn ?? "").toLowerCase();
      return name.contains(q) || en.contains(q);
    }).toList();

    // Group By restaurant_id
    final Map<int, List<MenuItemModel>> grouped = {};
    for (final item in filteredItems) {
      final rid = item.restaurant?.id ?? 0;
      if (rid == 0) continue;
      grouped.putIfAbsent(rid, () => []);
      grouped[rid]!.add(item);
    }

    // مطاعم من nearbyRestaurants
    final restaurantsById = {for (final r in data.nearbyRestaurants) r.id: r};

    final blocks = <RestaurantSearchBlock>[];
    grouped.forEach((rid, items) {
      final restaurant = restaurantsById[rid];
      if (restaurant == null) return;
      blocks.add(RestaurantSearchBlock(restaurant: restaurant, items: items));
    });

    setState(() => _results = blocks);
  }

  Widget _buildTagChip(String tag) {
    return Container(
      margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => _removeTag(tag),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(Icons.close, size: 18.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 4.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              tag,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontFamily: "Manrope",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String h) {
    return Container(
      margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              setState(() {
                _history.remove(h);
                _filterSuggestions(_controller.text);
              });
            },
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(Icons.close, size: 18.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: () {
              _applySuggestionToField(h);
              final st = cubit.state;
              st.maybeWhen(
                loaded: (data) => _performSearchOn(data),
                orElse: () {},
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                h,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontFamily: "Manrope",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ بلوك مطعم + items
  Widget _restaurantBlock(RestaurantSearchBlock block) {
    final r = block.restaurant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 10),
          child: Row(
            children: [
              ClipOval(child: _buildImage(r.logo ?? "")),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomSubTitle(
                  subtitle: r.name ?? "",
                  color: AppColor.white,
                  fontsize: 14.sp,
                ),
              ),
              Container(
                height: 25.h,
                width: 1,
                color: Colors.white24,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: AppColor.yellow, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    ((r.ratingAvg ?? 0).toDouble()).toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "${r.ratingCount ?? 0}+ Order",
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 8,
              right: 0.2,
            ),
            decoration: BoxDecoration(
              color: AppColor.LightActive,
              borderRadius: BorderRadius.circular(15),
            ),
            height: 200,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 2.3;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: block.items.length,
                  itemBuilder: (context, index) {
                    final item = block.items[index];

                    return Container(
                      width: itemWidth,
                      margin: EdgeInsets.only(right: 10.w),
                      child: GestureDetector(
                        onTap: () async {
                          // ✅ عند الضغط: افتح sheet مع extras الحقيقيين
                          await _openItemBottomSheet(context, item);
                        },
                        child: SearchPopularItemCard(
                          item: item,
                        ), // ✅ Card خاصة بالـ MenuItemModel
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Cache لنتائج restaurant-details حتى ما نطلب كل مرة
  final Map<int, RestaurantDetailsResponse> _restaurantDetailsCache = {};

  Future<void> _openItemBottomSheet(
    BuildContext context,
    MenuItemModel item,
  ) async {
    final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

    final restaurantId = item.restaurant?.id ?? 0; // ✅
    final menuItemId = item.id; // ✅

    if (restaurantId == 0 || menuItemId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن تحديد المطعم أو الوجبة")),
      );
      return;
    }

    List<MenuExtra> extras = const [];

    try {} catch (_) {
      extras = const [];
    }

    showAddOrderDialog(
      context,
      restaurantId: restaurantId, // ✅ جديد
      menuItemId: menuItemId, // ✅ جديد
      title: title,
      price: (item.priceAfter > 0 ? item.priceAfter : item.priceBefore),
      oldPrice: item.priceBefore,
      imagePathOrUrl:
          item.primaryImage?.imageUrl ?? "assets/images/shawarma_box.png",
      description: "",
      extraMeals: extras, // ✅ استخدم extras المحسوبة (حالياً فاضية)
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColor.Dark,
          body: Stack(
            key: _stackKey,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => showSuggestions = false);
                },
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomArrow(
                              onTap: () => Navigator.pop(context),
                              color: AppColor.black,
                              background: AppColor.white,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Container(
                                key: _searchFieldKey,
                                height: 40.h,
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: TextField(
                                  focusNode: _focusNode,
                                  controller: _controller,
                                  onTap: () =>
                                      _filterSuggestions(_controller.text),
                                  onChanged: _filterSuggestions,
                                  onSubmitted: (_) {
                                    state.maybeWhen(
                                      loaded: (data) => _performSearchOn(data),
                                      orElse: () {},
                                    );
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10.w),
                                    filled: true,
                                    fillColor: AppColor.white,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/search.svg',
                                        color: AppColor.gry,
                                        width: 20.w,
                                        height: 20.h,
                                      ),
                                    ),
                                    hintText:
                                        "Search food, stores, restaurants",
                                    hintStyle: TextStyle(
                                      color: AppColor.gry,
                                      fontSize: 14.sp,
                                      fontFamily: "Manrope",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        30.0.r,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () {
                                state.maybeWhen(
                                  loaded: (data) => _performSearchOn(data),
                                  orElse: () {},
                                );
                              },
                              borderRadius: BorderRadius.circular(50.0.r),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(50.0.r),
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/boxsearch.svg',
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (searchTags.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: searchTags.map(_buildTagChip).toList(),
                            ),
                          )
                        else if (_history.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _history
                                  .map(_buildHistoryChip)
                                  .toList(),
                            ),
                          ),

                        SizedBox(height: 12.h),

                        Expanded(
                          child: state.maybeWhen(
                            loading: () => Center(
                              child: CircularProgressIndicator(
                                color: AppColor.white,
                              ),
                            ),
                            error: (msg) => Center(
                              child: Text(
                                msg,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            loaded: (data) {
                              if (_results.isEmpty) {
                                return Center(
                                  child: Text(
                                    'اكتب كلمة واضغط بحث لإظهار نتائج حقيقية من most_popular + discounts',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: _results.length,
                                itemBuilder: (context, i) =>
                                    _restaurantBlock(_results[i]),
                              );
                            },
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showSuggestions) _suggestionsOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _suggestionsOverlay() {
    final fieldBox =
        _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;

    if (fieldBox == null || stackBox == null) return const SizedBox.shrink();

    final fieldGlobal = fieldBox.localToGlobal(Offset.zero);
    final stackGlobal = stackBox.localToGlobal(Offset.zero);
    final localTopLeft = fieldGlobal - stackGlobal;
    final fieldHeight = fieldBox.size.height;

    final computed = filteredSuggestions.length * 48.0.h;
    final maxHeight = computed > 300.0.h ? 300.0.h : computed;

    return Positioned(
      top: localTopLeft.dy + fieldHeight,
      left: 24.w,
      right: 24.w,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: filteredSuggestions.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text(
                      'No suggestions found',
                      style: TextStyle(color: AppColor.black, fontSize: 14.sp),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(10.w),
                  itemCount: filteredSuggestions.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColor.black, height: 1.h),
                  itemBuilder: (context, index) {
                    final suggestion = filteredSuggestions[index];
                    return InkWell(
                      onTap: () {
                        _applySuggestionToField(suggestion);
                        final st = cubit.state;
                        st.maybeWhen(
                          loaded: (data) => _performSearchOn(data),
                          orElse: () {},
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            color: AppColor.black,
                            fontSize: 15.sp,
                            fontFamily: "Manrope",
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// ✅ صورة: تقبل URL أو asset
  Widget _buildImage(String path) {
    final p = path.trim();

    final fallback = Container(
      height: 35.h,
      width: 35.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Icon(Icons.store, color: AppColor.gry, size: 20.sp),
      ),
    );

    if (p.isEmpty) return fallback;

    if (!p.startsWith("http") && p.startsWith("assets/")) {
      return Image.asset(
        p,
        height: 35.h,
        width: 35.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    final url = p.startsWith("http")
        ? p
        : "https://breezefood.cloud/${p.startsWith("/") ? p.substring(1) : p}";

    return Image.network(
      url,
      height: 35.h,
      width: 35.w,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class SearchPopularItemCard extends StatelessWidget {
  final MenuItemModel item;

  const SearchPopularItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;
    final price = (item.priceAfter > 0 ? item.priceAfter : item.priceBefore);

    final img = item.primaryImage?.imageUrl; // ✅ هذا الموجود عندك

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11.r),
        color: AppColor.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 85.h,
            child: (img == null || img.isEmpty)
                ? _imageFallback()
                : Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.white,
                fontSize: 12.sp,
                fontFamily: "Manrope",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 6.w, bottom: 6.h),
            child: Text(
              "$price ل.س",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 12.sp,
                fontFamily: "Inter",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 28),
    );
  }
}
