import 'package:colibri/core/extensions/context_exrensions.dart';
import 'package:colibri/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:colibri/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileListener {
  static Future<Null> success(dynamic state, BuildContext context) async {
    if (state == PROFILE_SUCCESS.PROFILE_BLOCKED) {
      context.popNTimes(3);
      await context.showSnackBar(message: 'User blocked successfully');
      BlocProvider.of<FeedCubit>(context).onRefresh();
    } else if (state == PROFILE_SUCCESS.PROFILE_UNBLOCKED) {
      context.popNTimes(3);
      await context.showSnackBar(message: 'User unblocked successfully');
      BlocProvider.of<FeedCubit>(context).onRefresh();
    }
  }

  static Null error(String error, BuildContext context) {
    context.showSnackBar(isError: true, message: error);
  }
}
