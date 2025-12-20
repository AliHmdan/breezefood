import 'package:breezefood/view/HomePage/widgets/custom_appbar_home.dart';
import 'package:breezefood/view/HomePage/widgets/custom_search.dart';
import 'package:breezefood/view/HomePage/widgets/search.dart';
import 'package:breezefood/view/profile/profile.dart';

import 'package:flutter/material.dart';

class AppbarHome extends StatelessWidget {
  const AppbarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          CustomAppbarHome(
            title: "Your Address Now",
            subtitle: "",
            image: "assets/icons/location.svg",
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
            icon: Icons.keyboard_arrow_down,
          ),
          const SizedBox(height: 15),
          CustomSearch(
            hint: 'Search',
            readOnly: true,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Search();
              },));
            },
          ),
        ],
      ),
    );
  }
}
