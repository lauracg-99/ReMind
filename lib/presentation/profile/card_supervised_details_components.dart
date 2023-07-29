
import 'package:flutter/material.dart';
import 'package:remind/data/auth/models/supervised.dart';

import '../styles/app_images.dart';
import '../styles/sizes.dart';
import '../widgets/cached_network_image_circular.dart';
import '../widgets/custom_text.dart';

class CardSupervisedDetailsComponent extends StatelessWidget {

  final Supervised supervised;

  const CardSupervisedDetailsComponent(
      this.supervised, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return
      Column(
        children: [ Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         (supervised.image == '')
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: Sizes.userImageSmallRadius(context),
                child:  Image.asset(
                  AppImages.profileCat,
                  fit: BoxFit.cover, ),
              )
            : CachedNetworkImageCircular(
              imageUrl: supervised.image,
              radius: Sizes.userImageMediumRadius(context),
            ),
          SizedBox(
            width: Sizes.hMarginSmallest(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.h6(
                  context,
                  'Nombre: ${supervised.name}', //TODO: tr
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2,),
                CustomText.h6(
                  context,
                  'email: ${supervised.email}', //TODO: tr
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),


      ])
        ],);
  }

}
