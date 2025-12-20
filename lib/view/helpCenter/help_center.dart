
import 'package:breezefood/component/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpCenter extends StatelessWidget {
  final List<Message> messages = [
    Message(
      text: " HI ",
      time: "10:30 AM",
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    Message(
      text: "Hello Mr.Ibrahim how I can help you?",
      time: "10:32 AM",
      isSentByMe: false,
      status: MessageStatus.delivered,
    ),
    Message(
      text: "Are you coming?",
      time: "10:33 AM",
      isSentByMe: true,
      status: MessageStatus.read,
    ),
    Message(
      text: "I’m coming just wait",
      time: "10:33 AM",
      isSentByMe: false,
      status: MessageStatus.read,
    ),
  ];

  HelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColor.Dark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// الأيقونة داخل دائرة
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  
                  padding: EdgeInsets.all(4), // يحدد حجم الدائرة الداخلية
                  decoration: BoxDecoration(
                    color: AppColor.black, // لون الخلفية
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.LightActive, // لون الـ border
                      width: 2, // سماكة الـ border
                    ),
                  ),
                  child: Center(
                    // 👈 يضمن أن الأيقونة في الوسط تماماً
                    child: Icon(
                      Icons.close,
                      color: AppColor.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
              Spacer(),

              /// العنوان دايماً يظهر
              Text(
                "Help center",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.white,
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          children: [
            /// خط مع التوقيت
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Divider(color: AppColor.white, thickness: 0.5)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    "8:00 AM",
                    style: TextStyle(color: AppColor.white, fontSize: 12.sp),
                  ),
                ),
                Expanded(child: Divider(color: AppColor.white, thickness: 0.5)),
              ],
            ),
            SizedBox(height: 10.h),

            /// الرسائل
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10.w),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  return Column(
                    crossAxisAlignment: msg.isSentByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: msg.isSentByMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!msg.isSentByMe) ...[
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: AssetImage(
                                "assets/images/person.jpg",
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                /// LTR → إشارة الصح يسار الفقاعة
                                if (msg.isSentByMe && !isRtl) ...[
                                  _buildStatusIcon(msg.status),
                                  SizedBox(width: 4.w),
                                ],

                                /// فقاعة الرسالة
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: msg.isSentByMe
                                          ? AppColor.primaryColor
                                          : AppColor.black,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: AppColor.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),

                                /// RTL → إشارة الصح يمين الفقاعة
                                if (msg.isSentByMe && isRtl) ...[
                                  SizedBox(width: 4.w),
                                  _buildStatusIcon(msg.status),
                                ],
                              ],
                            ),
                          ),
                          if (msg.isSentByMe) ...[
                            SizedBox(width: 6.w),
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: AssetImage(
                                "assets/images/person.jpg",
                              ),
                            ),
                          ],
                        ],
                      ),

                      /// التوقيت تحت الفقاعة
                      Padding(
                        padding: EdgeInsets.only(
                          top: 2.h,
                          left: msg.isSentByMe ? 0 : 40.w,
                          right: msg.isSentByMe ? 40.w : 0,
                        ),
                        child: Text(
                          msg.time,
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// شريط الكتابة
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// أيقونة حالة الرسالة
  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(Icons.check, size: 16.sp, color: AppColor.primaryColor);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 16.sp, color: AppColor.primaryColor);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16.sp, color: Colors.blueAccent);
    }
  }

  /// شريط إدخال النص
  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: TextField(
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Icon(
              Icons.arrow_circle_up_sharp,
              size: 28.sp,
              color: AppColor.primaryColor,
            ),
          ),
          hintText: "Message here...",
          hintStyle: TextStyle(color: AppColor.LightActive, fontSize: 13.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}

/// موديل الرسائل
class Message {
  final String text;
  final String time;
  final bool isSentByMe;
  final MessageStatus status;

  Message({
    required this.text,
    required this.time,
    required this.isSentByMe,
    required this.status,
  });
}

/// حالات الرسالة
enum MessageStatus { sent, delivered, read }
