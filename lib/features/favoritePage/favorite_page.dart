import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favoritePage/data/model/favorites_response.dart';
import 'package:breezefood/features/favoritePage/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  late final FavoritesCubit cubit;

  bool _removingNow = false;
  bool _firstLoadDone = false; // ✅ أول مرة بس

  @override
  void initState() {
    super.initState();
    cubit = context.read<FavoritesCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.load();
      _firstLoadDone = true;
    });
  }

  Future<void> _handleRefresh() async {
    // ✅ Pull-to-refresh عادي (إذا بدك بدون EasyLoading خليه هيك)
    await cubit.load();
  }

  Future<void> _deleteFavorite(FavoriteItem item) async {
    _removingNow = true;
    EasyLoading.show(status: "Removing...");
    await cubit.remove(item);
  }

  Widget _buildOrderCard(FavoriteItem item) {
    final imageUrl = UrlHelper.toFullUrl(item.image);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (context) => _deleteFavorite(item),
              backgroundColor: AppColor.red,
              borderRadius: BorderRadius.circular(15.r),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/delete.svg",
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  width: 30.w,
                  height: 30.h,
                ),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 10),
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: (imageUrl ?? "").trim().isEmpty
                      ? Container(
                          width: 120.w,
                          height: 100.h,
                          color: AppColor.Dark,
                          child: Center(
                            child: Icon(
                              Icons.fastfood,
                              color: AppColor.white,
                              size: 30.sp,
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          width: 120.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 111.w,
                            height: 100.h,
                            color: AppColor.Dark,
                            child: Center(
                              child: Icon(
                                Icons.fastfood,
                                color: AppColor.white,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSubTitle(
                        subtitle: item.nameAr,
                        color: AppColor.white,
                        fontsize: 14.sp,
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: item.restaurantName,
                        color: AppColor.white,
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Price : ",
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: "Manrope",
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: context.syp(item.price),
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,
      body: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          state.maybeWhen(
            loading: () {
              // ✅ لا تعرض Loading بالـ UI إلا أول مرة (لأن silent refresh ما بيعمل loading أصلاً)
              if (_firstLoadDone) return;
            },
            loaded: (_) {
              EasyLoading.dismiss();

              if (_removingNow) {
                _removingNow = false;
                EasyLoading.showSuccess("Removed");
              }
            },
            error: (msg) {
              _removingNow = false;
              EasyLoading.dismiss();
              EasyLoading.showError(msg);
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final items = state.maybeWhen(
              loaded: (items) => items,
              orElse: () => const <FavoriteItem>[],
            );

            // ✅ لا نعرض spinner إلا لو فعلاً state=loading (وهذا بيصير فقط بالـ load العادي)
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 30,
                  bottom: 8,
                ),
                child: Column(
                  children: [
                    const CustomAppbarHome(title: "Favorite"),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.favorite_border,
                                    color: AppColor.white,
                                    size: 50,
                                  ),
                                  SizedBox(height: 10.h),
                                  const Text(
                                    "لا توجد عناصر في المفضلة",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                for (final f in items) _buildOrderCard(f),
                                const SizedBox(height: 40),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
