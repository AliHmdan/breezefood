import 'package:breezefood/core/component/color.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  final int count;
  final bool isLoading;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const CounterWidget({
    super.key,
    required this.count,
    required this.isLoading,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric( vertical: 6),
      decoration: BoxDecoration(
        // color: AppColor.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: (isLoading || count <= 1) ? null : onDec,
            child: const CircleAvatar(
              backgroundColor: AppColor.backfilter,
              radius: 16,
              child: Icon(Icons.remove, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          CustomSubTitle(
            subtitle: "$count",
            color: AppColor.white,
            fontsize: 18,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? null : onInc,
            child: const CircleAvatar(
              backgroundColor: AppColor.primaryColor,
              radius: 16,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}