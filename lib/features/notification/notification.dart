import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/notification/widget/notification_card.dart';
import 'package:breezefood/features/profile/presentation/widget/custom_appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


// --------------------------------------------------
// 🧩 Notification Model (حل مشكلة التعريف)
// --------------------------------------------------
class NotificationModel {
  final String title;
  final String subtitle;
  final String time;

  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

// --------------------------------------------------
// 🏠 Notification Page
// --------------------------------------------------
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int selectedIndex = -1; // ✅ لا يوجد عنصر محدد افتراضيًا

  final List<NotificationModel> notifications = [
    NotificationModel(
      title: "Title",
      subtitle:
      "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam.",
      time: "Now",
    ),
    NotificationModel(
      title: "Title",
      subtitle:
      "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam.",
      time: "08:20 PM",
    ),
    NotificationModel(
      title: "Title",
      subtitle:
      "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam.",
      time: "Yesterday",
    ),
    NotificationModel(
      title: "Title",
      subtitle:
      "Lorem ipsum dolor sit amet consectetur. Placerat hendrerit justo ultricies etiam.",
      time: "Wed",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Dark,

      // ✅ AppBar نظيف ومتوافق
      appBar: AppBar(
        backgroundColor: AppColor.Dark,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70.h,
        title: CustomAppbarProfile(
          title: "Notification",
          icon: Icons.arrow_back_ios,
          ontap: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: notifications.isEmpty
        // ================= Empty State =================
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none,
                  color: AppColor.white, size: 60.sp),
              SizedBox(height: 10.h),
              Text(
                "No notifications yet",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        )
        // ================= List =================
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: notificationCard(
                title: item.title,
                subtitle: item.subtitle,
                time: item.time,
                isActive: selectedIndex == index,
              ),
            );
          },
        ),
      ),
    );
  }
}
