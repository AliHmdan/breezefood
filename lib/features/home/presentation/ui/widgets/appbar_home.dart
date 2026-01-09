import 'package:breezefood/features/home/model/home_response.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_appbar_home.dart';
import 'package:breezefood/features/home/presentation/ui/widgets/custom_search.dart';
import 'package:breezefood/features/profile/presentation/ui/profile.dart';
import 'package:breezefood/features/search/presentation/ui/search_screen.dart';
import 'package:flutter/material.dart';

class AppbarHome extends StatelessWidget {
  final HomeResponse? home;
  const AppbarHome({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    final hasCoords = home?.hasCoordinates ?? false;
    final province = home?.provinceDetected;

    final title = hasCoords
        ? (province?.isNotEmpty == true ? province! : "موقعك الحالي")
        : "حدد موقعك";

    final subtitle = hasCoords ? "" : "لإظهار الأقرب إليك (مطاعم/سوبر ماركت)";

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          CustomAppbarHome(
            title: title,
            subtitle: subtitle,
            image: "assets/icons/location.svg",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile()),
              );
            },
            icon: Icons.keyboard_arrow_down,
          ),
          const SizedBox(height: 15),
          CustomSearch(
            hint: 'Search',
            readOnly: true,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => Search()));
            },
          ),
        ],
      ),
    );
  }
}
