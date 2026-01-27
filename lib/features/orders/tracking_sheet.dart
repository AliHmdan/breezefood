import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/orders/model/active_orders_response.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackingSheet extends StatelessWidget {
  final int orderId;
  final ScrollController scrollController;

  const TrackingSheet({
    super.key,
    required this.orderId,
    required this.scrollController,
  });

  // ================= Helpers =================

  String absUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    const base = "https://breezefood.cloud/";
    if (path.startsWith("/")) return "$base${path.substring(1)}";
    return "$base$path";
  }

  String _cleanPhone(String s) {
    // خلي + وأرقام فقط
    final cleaned = s.replaceAll(RegExp(r"[^0-9+]"), "");
    return cleaned;
  }

  Future<void> _callPhone(String phone) async {
    final p = _cleanPhone(phone);
    if (p.isEmpty) return;

    final uri = Uri(scheme: "tel", path: p);

    final ok = await canLaunchUrl(uri);
    if (!ok) return;

    // يفتح تطبيق الهاتف / dialer
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool _isStepCompleted(String stepKey, String currentStatus) {
    const order = ["pending", "preparing", "inway", "delivered"];
    final a = order.indexOf(stepKey);
    final b = order.indexOf(currentStatus);
    if (a == -1 || b == -1) return false;
    return a <= b;
  }

  String _timeFor(List timeline, String key) {
    for (final e in timeline) {
      try {
        if (e is OrderTimelineStep) {
          if (e.key == key) return (e.time ?? "").toString();
        }
        if (e is Map) {
          final k = (e["key"] ?? "").toString();
          if (k == key) return (e["time"] ?? "").toString();
        }
      } catch (_) {}
    }
    return "";
  }

  String _stepTitle(String key) => "order_status.$key".tr();

  Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Container(height: 1, color: Colors.white12),
      );

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _v(String? s) => (s == null || s.trim().isEmpty) ? "—" : s.trim();

  String _num(num? n) {
    if (n == null) return "—";
    // إذا بدك 0 يظهر، خليه، وإذا بدك يعتبره فاضي شيل الشرط
    return n.toString();
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            v.isEmpty ? "—" : v,
            style: TextStyle(
              color: AppColor.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCircle({required IconData icon, required VoidCallback? onTap}) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Opacity(
          opacity: disabled ? 0.45 : 1,
          child: Ink(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.white, size: 20.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIcon(bool isCompleted) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: isCompleted ? AppColor.primaryColor : AppColor.LightActive,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.circle_outlined,
        color: AppColor.white,
        size: 16.sp,
      ),
    );
  }

  Widget _buildStep(String title, String time, bool isCompleted, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStepIcon(isCompleted),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColor.primaryColor
                        : AppColor.LightActive,
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColor.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    time.trim().isEmpty ? "—" : time,
                    style: TextStyle(color: AppColor.gry, fontSize: 12.sp),
                  ),
                  SizedBox(height: isLast ? 0 : 18.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    const stepKeys = ["pending", "preparing", "inway", "delivered"];

    return BlocBuilder<OrdersDetailsCubit, OrdersDetailsState>(
      builder: (context, state) {
        final details = state.maybeWhen(success: (d) => d, orElse: () => null);

        final driverName = _v(details?.driver.name);
        final driverPhoneRaw = (details?.driver.phone ?? "").toString();
        final driverPhone = _cleanPhone(driverPhoneRaw);
        final driverImg = absUrl(details?.driver.profileImage ?? "");

        final restaurantName = _v(details?.restaurant.name);
        final restLogo = absUrl(details?.restaurant.logo ?? "");

        final order = details?.order;
        final status = (order?.status ?? "").toString();
        final createdAt = (order?.createdAt ?? "").toString();

        final itemsTotal = order?.itemsTotal;
        final deliveryFee = order?.deliveryFee;
        final total = order?.totalPrice;

        final codeInt = order?.orderCustomerCode;
        final code = (codeInt == null) ? "" : codeInt.toString();
        final codeDigits =
            code.isEmpty ? ["-", "-", "-", "-"] : code.padLeft(4, "0").split("");

        final timeline = details?.timeline ?? const [];
        final items = details?.items ?? const [];

        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.Dark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.r),
                topRight: Radius.circular(25.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 18,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // handle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
                      child: Center(
                        child: Container(
                          width: 44.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          // driver avatar
                          Container(
                            width: 56.w,
                            height: 56.w,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.LightActive,
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: driverImg.isEmpty
                                ? const Icon(Icons.person, color: AppColor.white)
                                : Image.network(
                                    driverImg,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: AppColor.white,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driverName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                Row(
                                  children: [
                                    if (restLogo.isNotEmpty)
                                      Container(
                                        width: 18.w,
                                        height: 18.w,
                                        margin: EdgeInsets.only(right: 6.w),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: AppColor.LightActive,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Image.network(
                                          restLogo,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        restaurantName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColor.gry,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (driverPhone.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    driverPhone,
                                    style: TextStyle(
                                      color: AppColor.gry,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          _actionCircle(
                            icon: Icons.call,
                            onTap: driverPhone.isEmpty ? null : () => _callPhone(driverPhone),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // loading/error
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                      child: state.maybeWhen(
                        loading: () => const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (message) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.tr(), style: TextStyle(color: AppColor.gry)),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => context.read<OrdersDetailsCubit>().load(orderId),
                              child: Text(
                                "common.retry".tr(),
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // body
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _divider(),

                        // Customer code
                        _sectionTitle("tracking.customer_code_title".tr()),
                        Text(
                          "tracking.show_code_hint".tr(),
                          style: TextStyle(color: AppColor.gry, fontSize: 13.sp),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: AppColor.LightActive,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              4,
                              (i) => Text(
                                codeDigits[i],
                                style: TextStyle(
                                  color: AppColor.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),

                        _divider(),

                        // Order details
                        _sectionTitle("tracking.order_details".tr()),
                        _kv("tracking.status".tr(), _v(status)),
                        _kv("tracking.created_at".tr(), _v(createdAt)),
                        _kv("tracking.items_total".tr(), _num(itemsTotal)),
                        _kv("tracking.delivery_fee".tr(), _num(deliveryFee)),
                        _kv("tracking.total".tr(), _num(total)),

                        _divider(),

                        // Timeline
                        _sectionTitle("tracking.timeline".tr()),
                        ...List.generate(stepKeys.length, (i) {
                          final k = stepKeys[i];
                          final t = _timeFor(timeline, k);
                          return _buildStep(
                            _stepTitle(k),
                            t,
                            _isStepCompleted(k, status),
                            i == stepKeys.length - 1,
                          );
                        }),

                        _divider(),

                        // Items
                        _sectionTitle("tracking.items".tr()),
                        if (items.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text("common.empty".tr(),
                                style: TextStyle(color: AppColor.gry)),
                          )
                        else
                          ...items.map((it) {
                            final img = absUrl(it.image);
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColor.LightActive,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52.w,
                                    height: 52.w,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      color: AppColor.Dark,
                                    ),
                                    child: img.isEmpty
                                        ? const Icon(Icons.fastfood, color: AppColor.white)
                                        : Image.network(
                                            img,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.fastfood, color: AppColor.white),
                                          ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          "${"tracking.qty".tr(args: ["${it.quantity}"])} • "
                                          "${"tracking.item_price".tr(args: ["${it.totalPrice}"])} • "
                                          "${"tracking.delivery_time".tr(args: ["${it.deliveryTime}"])}",
                                          style: TextStyle(
                                            color: AppColor.gry,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        if (it.withSpicy)
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.h),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                              decoration: BoxDecoration(
                                                color: AppColor.Dark,
                                                borderRadius: BorderRadius.circular(999),
                                                border: Border.all(color: Colors.white12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.local_fire_department,
                                                      color: AppColor.white, size: 16.sp),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    "tracking.spicy".tr(),
                                                    style: TextStyle(
                                                      color: AppColor.white,
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
