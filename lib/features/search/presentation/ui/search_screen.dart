import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/core/services/money.dart';
import 'package:breezefood/core/services/pick_by_langu.dart';
import 'package:breezefood/core/services/price_formatter.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_arrow.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:breezefood/features/orders/add_order.dart';
import 'package:breezefood/features/search/data/models/search_response.dart';
import 'package:breezefood/features/search/presentation/cubit/search_cubit.dart';
import 'package:breezefood/features/search/presentation/cubit/search_state.dart';
import 'package:breezefood/features/stores/model/restaurant_details_model.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/restaurant_details/screens/restaurant_details_screen.dart';
import 'package:breezefood/features/stores/presentation/ui/screens/resturant_details.dart';
import 'package:easy_localization/easy_localization.dart';
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

    final base = {...history}.toList();

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
      margin: EdgeInsetsDirectional.only(end: 8.w, bottom: 8.h),
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
            child: CustomSubTitle(
              subtitle: tag,
              color: AppColor.white,
              fontsize: 14.sp,
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
          /// حذف من الـ UI فقط
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
              child: CustomSubTitle(
                subtitle: h,
                color: AppColor.white,
                fontsize: 14.sp,
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
    final isOpen = block.restaurant.isOpen;

    final ratingAvg = (r.rating?.avg ?? 0).toDouble();
    final ratingCount = r.rating?.count ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 10),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResturantDetails(restaurant_id: r.id),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(child: _buildImage(r.logo ?? "")),
                    SizedBox(width: 8.w),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200.w),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: CustomSubTitle(
                          subtitle: r.name,
                          color: AppColor.white,
                          fontsize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                height: 25.h,
                width: 0.5,
                color: AppColor.LightActive,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: AppColor.yellow, size: 16.sp),
                  SizedBox(width: 4.w),
                  CustomSubTitle(
                    subtitle: ratingAvg.toStringAsFixed(1),
                    color: AppColor.white,
                    fontsize: 14.sp,
                  ),
                  SizedBox(width: 6.w),
                  CustomSubTitle(
                    subtitle: "$ratingCount",
                    color: Colors.white70,
                    fontsize: 12.sp,
                  ),
                ],
              ),
            ],
          ),
        ),

        /// ================= Items =================
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: SizedBox(
            height: 150.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 2.3;
                final count = block.items.length;
                final gap = 10.w;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: count,
                  physics: count <= 2
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final it = block.items[index];

                    final title = context.pick(
                      ar: it.names.ar,
                      en: it.names.en,
                    );

                    final fullImg = _toFullUrl(it.imageUrl ?? "");

                    /// ✅ Discount extraction (Safe)
                    final hasDiscount = (it.hasDiscount ?? false) == true;
                    final before =
                        (it.priceBefore ?? double.tryParse(it.basePrice) ?? 0)
                            .toDouble();
                    final after = (it.priceAfter ?? before).toDouble();
                    final percent =
                        double.tryParse(it.discountValue ?? "0") ?? 0;

                    return Container(
                      width: itemWidth,
                      margin: EdgeInsetsDirectional.only(
                        end: index == count - 1 ? 0 : gap,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          showAddOrderDialog(
                            context,
                            restaurantId: r.id,
                            menuItemId: it.id,
                            title: title,
                            price: hasDiscount ? after : before,
                            oldPrice: before,
                            imagePathOrUrl: fullImg.isNotEmpty
                                ? fullImg
                                : "assets/images/shawarma_box.png",
                            description: "",
                            extraMeals: const <MenuExtra>[],
                            isRestaurantOpen: isOpen,
                            extraGroups: const <ExtraGrouped>[], // ✅ من الداتا
                          );
                        },
                        child: _SearchApiItemCard(
                          title: title,
                          imageUrl: fullImg,
                          hasDiscount: hasDiscount,
                          priceBefore: before,
                          priceAfter: after,
                          discountPercent: percent,
                        ),
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
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.sp,
                                    fontFamily: context.isAr
                                        ? 'Cairo'
                                        : 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    hintText: "search.hint".tr(),
                                    hintStyle: TextStyle(
                                      color: AppColor.gry,
                                      fontSize: 14.sp,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.r),
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
                              "${'search.province'.tr()}: ${s.provinceDetected!}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontFamily: context.isAr ? 'Cairo' : 'Inter',
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
                                  child: CustomSubTitle(
                                    subtitle: s.error!,
                                    color: AppColor.red,
                                    fontsize: 14,
                                  ),
                                )
                              : (_controller.text.trim().isEmpty)
                              ? Center(
                                  child: Text(
                                    "search.start_hint".tr(),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                      fontFamily: context.isAr
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : (s.results.isEmpty)
                              ? Center(
                                  child: CustomSubTitle(
                                    subtitle: "search.no_results".tr(),
                                    color: Colors.white70,
                                    fontsize: 14.sp,
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
            ],
          ),
        );
      },
    );
  }

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
  final String imageUrl;

  final bool hasDiscount;
  final double priceBefore;
  final double priceAfter;
  final double discountPercent;

  const _SearchApiItemCard({
    required this.title,
    required this.imageUrl,
    required this.hasDiscount,
    required this.priceBefore,
    required this.priceAfter,
    required this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    final beforeTxt = context.money(priceBefore, decimals: 0);
    final afterTxt = context.money(priceAfter, decimals: 0);

    final showDiscount =
        hasDiscount && discountPercent > 0 && priceAfter < priceBefore;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= Image =================
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 90.h,
                child: imageUrl.isEmpty
                    ? _fallback()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      ),
              ),

              /// ✅ Discount Badge (مباشرة داخل Stack بدون Padding خارجي)
              if (showDiscount)
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "-${discountPercent.toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// ================= Title =================
          Padding(
            padding: EdgeInsetsDirectional.only(start: 8.w, end: 8.w, top: 6.h),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: context.isAr ? 'Cairo' : 'Inter',
              ),
            ),
          ),

          /// ================= Price =================
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 8.w,
              end: 8.w,
              top: 2.h,
              bottom: 8.h,
            ),
            child: showDiscount
                ? Row(
                    children: [
                      /// قبل (مشطوب) — Flexible حتى ما يعمل overflow
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            beforeTxt,
                            style: TextStyle(
                              color: AppColor.LightActive,
                              fontSize: 11.sp,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),

                      /// بعد (أحمر)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            afterTxt,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: context.isAr ? 'Cairo' : 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      beforeTxt,
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: context.isAr ? 'Cairo' : 'Inter',
                      ),
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
