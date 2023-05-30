
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/common/storage_keys.dart';
import 'package:remind/data/auth/models/supervised.dart';
import 'package:remind/data/auth/models/user_model.dart';

import '../../data/auth/manage_supervised/solicitud.dart';
import '../../domain/auth/repo/user_repo.dart';
import '../styles/app_colors.dart';
import '../styles/app_images.dart';
import '../styles/sizes.dart';
import '../widgets/cached_network_image_circular.dart';
import '../widgets/custom_text.dart';
import 'components/select_supervised_component.dart';

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
                  'Nombre: ${supervised.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2,),
                CustomText.h6(
                  context,
                  'email: ${supervised.email}',
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
