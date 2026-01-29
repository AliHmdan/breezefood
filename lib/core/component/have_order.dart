import 'package:breezefood/core/di/di.dart';
import 'package:breezefood/features/orders/data/repo/orders_repository.dart';
import 'package:breezefood/features/orders/order_traking_map.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders/orders_tracking_state.dart';
import 'package:breezefood/features/orders/presentation/cubit/orders_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void openHaveOrderTracking(BuildContext context, int orderId) {
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<OrdersDetailsCubit>()),
        BlocProvider(create: (_) => getIt<OrdersTrackingCubit>()), // ✅ جديد
      ],
      child: OrderTrackingScreen(orderId: orderId),
    ),
  ),
);

}
