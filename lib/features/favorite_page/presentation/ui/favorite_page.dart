import 'package:breezefood/core/component/url_helper.dart';
import 'package:breezefood/core/prices_helper.dart';
import 'package:breezefood/features/favorite_page/data/model/favorites_response.dart';
import 'package:breezefood/features/favorite_page/presentation/cubit/favorites_cubit.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../profile/presentation/widget/custom_appbar_profile.dart';

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
    EasyLoading.show(status: "favorites.removing".tr());

    await cubit.remove(item);
  }

  Widget _buildOrderCard(FavoriteItem item) {
    final imageUrl = UrlHelper.toFullUrl(item.image);
    final colorScheme = Theme.of(context).colorScheme;

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
              backgroundColor: colorScheme.error,
              borderRadius: BorderRadius.circular(15.r),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/delete.svg",
                  colorFilter: ColorFilter.mode(
                    colorScheme.onError,
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
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Container(
            padding: const EdgeInsetsDirectional.only(start: 1, end: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd: Radius.circular(40),
                    bottomEnd: Radius.circular(40),
                  ),
                  child: (imageUrl ?? "").trim().isEmpty
                      ? Container(
                          width: 120.w,
                          height: 100.h,
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.fastfood,
                              color: colorScheme.onSurface,
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
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.fastfood,
                                color: colorScheme.onSurface,
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
                        color: colorScheme.onSurface,
                        fontsize: 14.sp,
                      ),
                      const SizedBox(height: 4),
                      CustomSubTitle(
                        subtitle: item.restaurantName,
                        color: colorScheme.onSurface.withOpacity(0.75),
                        fontsize: 12.sp,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "favorites.price".tr(),

                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontFamily:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar'
                                    ? 'Cairo'
                                    : 'Inter',
                                fontSize: 12.sp,
                              ),
                            ),
                            TextSpan(
                              text: context.syp(item.price),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontFamily:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ar'
                                    ? 'Cairo'
                                    : 'Inter',
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                EasyLoading.showSuccess("favorites.removed".tr());
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    CustomAppbarProfile(
                      ontap: () {},
                      title: "favorites.title".tr(),
                    ),

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: colorScheme.onSurface,
                                    size: 50,
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    "favorites.empty".tr(),
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                      fontFamily:
                                          Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? 'Cairo'
                                          : 'Inter',
                                    ),
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
