import 'package:url_launcher/url_launcher_string.dart';

import '../../../../extensions.dart';
import '../../../../features/feed/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';

class SponsoredBodyWidget extends StatelessWidget {
  const SponsoredBodyWidget(this.advertisementEntity, {Key? key})
      : super(key: key);
  final AdvertisementEntity? advertisementEntity;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrlString(advertisementEntity!.onClickUrl!)) {
          await launchUrlString(advertisementEntity!.onClickUrl!);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: 60, right: 15),
        child: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              advertisementEntity!.adTitle.toCaption(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              5.toSizedBox,
              advertisementEntity!.adSubTitle!
                  .toCaption(fontWeight: FontWeight.w400),
            ],
          ).toPadding(8),
          5.toSizedBox,
          advertisementEntity!.adMediaUrl!.toNetWorkOrLocalImage(
            borderRadius: 0,
            width: context.getScreenWidth,
            height: 150,
          ),
          10.toSizedBox,
          Center(
            child: OutlinedButton(
              onPressed: () async {
                if (await canLaunchUrlString(
                    advertisementEntity!.onClickUrl!)) {
                  await launchUrlString(advertisementEntity!.onClickUrl!);
                }
              },
              child: 'Register Now'.toCaption(fontWeight: FontWeight.w500),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ).toPadding(6),
        ].toColumn().toContainer(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
            ),
      ),
    );
  }
}
