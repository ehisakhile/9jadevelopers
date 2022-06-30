import 'create_swift_circle.dart';
import '../../../../../extensions.dart';
import 'view_swift_circle.dart';
import 'package:flutter/material.dart';

class StoriesWidget extends StatelessWidget {
  const StoriesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: context.getScreenHeight * .1,
        color: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (_, index) {
            if (index == 0) return CreateSwiftCircle();
            return ViewSwiftCircle();
          },
        ),
      ),
    );
  }
}
