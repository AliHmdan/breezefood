import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/search/data/models/search_response.dart';
import 'package:breezefood/features/search/presentation/cubit/search_cubit.dart';
import 'package:breezefood/features/search/presentation/cubit/search_state.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class Search extends StatefulWidget {
  final int? restaurantId;
  const Search({Key? key, this.restaurantId}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _searchFieldKey = GlobalKey();

  late final SearchCubit searchCubit;

  final List<String> searchTags = [];
  final List<String> allSuggestions = const [
    "Syrian food",
    "Desserts",
    "Drinks",
  ];

  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    searchCubit = getIt<SearchCubit>();
    searchCubit.setRestaurantId(widget.restaurantId); // ✅ مهم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchCubit.loadHistory();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => showSuggestions = true);
        _filterSuggestions(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterSuggestions(String input) {
    final q = input.trim().toLowerCase();
    final history = searchCubit.state.history;

    final base = {...history, ...allSuggestions}.toList();

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
    if (!searchTags.contains(t)) setState(() => searchTags.add(t));
  }

  void _removeTag(String tag) => setState(() => searchTags.remove(tag));

  void _applySuggestionToField(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() => showSuggestions = false);
  }

  void _doSearchNow() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    _addTag(q);
    setState(() => showSuggestions = false);
    _focusNode.unfocus();

    searchCubit.search(q);
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
          // حذف من الـ UI فقط (إذا بدك delete API خبرني)
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              final cur = List<String>.from(searchCubit.state.history);
              cur.remove(h);
              searchCubit.emit(searchCubit.state.copyWith(history: cur));
              _filterSuggestions(_controller.text);
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
              _doSearchNow();
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

  /// ✅ بلوك مطعم + items (من API)
  Widget _apiRestaurantBlock(SearchBlock block) {
    final r = block.restaurant;
    final ratingAvg = (r.rating?.avg ?? 0).toDouble();
    final ratingCount = r.rating?.count ?? 0;

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
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResturantDetails(restaurant_id: r.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: CustomSubTitle(
                      subtitle: r.name,
                      color: AppColor.white,
                      fontsize: 14.sp,
                    ),
                  ),
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
                    ratingAvg.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "$ratingCount",
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
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
                  final it = block.items[index];

                  final title = context.pick(ar: it.names.ar, en: it.names.en);

                  final fullImg = _toFullUrl(it.imageUrl ?? "");

                  return Container(
                    width: itemWidth,
                    margin: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () {
                        // ✅ فتح نفس Dialog تبع Add Order
                        showAddOrderDialog(
                          context,
                          restaurantId: r.id,
                          menuItemId: it.id,
                          title: title,
                          price: double.tryParse(it.basePrice) ?? 0,
                          oldPrice: double.tryParse(it.basePrice) ?? 0,
                          imagePathOrUrl: fullImg.isNotEmpty
                              ? fullImg
                              : "assets/images/shawarma_box.png",
                          description: "",
                          extraMeals: const [], // search api ما بيرجع extras
                        );
                      },
                      child: _SearchApiItemCard(
                        title: title,
                        price: it.basePrice,
                        imageUrl: fullImg,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _toFullUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return "";
    if (v.startsWith("http")) return v;
    return "https://breezefood.cloud/${v.startsWith("/") ? v.substring(1) : v}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      bloc: searchCubit,
      builder: (context, s) {
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
                        // =================== Search Bar ===================
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
                                  onChanged: (v) {
                                    _filterSuggestions(v);
                                    searchCubit.searchDebounced(v);
                                  },
                                  onSubmitted: (_) => _doSearchNow(),
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
                              onTap: _doSearchNow,
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

                        // =================== Chips ===================
                        if (searchTags.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: searchTags.map(_buildTagChip).toList(),
                            ),
                          )
                        else if (s.history.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: s.history
                                  .map(_buildHistoryChip)
                                  .toList(),
                            ),
                          ),

                        SizedBox(height: 12.h),

                        if (s.provinceDetected != null &&
                            s.provinceDetected!.trim().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              "Province: ${s.provinceDetected!}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),

                        // =================== Results ===================
                        Expanded(
                          child: s.loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.white,
                                  ),
                                )
                              : (s.error != null)
                              ? Center(
                                  child: Text(
                                    s.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              : (_controller.text.trim().isEmpty)
                              ? Center(
                                  child: Text(
                                    "ابدأ بالبحث عن وجبة أو مطعم",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : (s.results.isEmpty)
                              ? Center(
                                  child: Text(
                                    "لا توجد نتائج",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: s.results.length,
                                  itemBuilder: (context, i) =>
                                      _apiRestaurantBlock(s.results[i]),
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
                        _doSearchNow();
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

  /// ✅ صورة: تقبل URL أو path
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

class _SearchApiItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;

  const _SearchApiItemCard({
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
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
            child: imageUrl.isEmpty
                ? _fallback()
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
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
              "$price \$",
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

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, color: Colors.white70, size: 28),
    );
  }
}
