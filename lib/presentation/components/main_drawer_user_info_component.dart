
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth/repo/user_repo.dart';
import '../widgets/cached_network_image_circular.dart';
import '../widgets/custom_text.dart';
import '../styles/app_images.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';

class MainDrawerUserInfoComponent extends ConsumerWidget {
  //menu de la izquierda
  const MainDrawerUserInfoComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final userModel = ref.watch(userRepoProvider).userModel!;

    return Column(
      children: [
        //foto de perfil
        (userModel.image == '')
            ? CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: Sizes.userImageMediumRadius(context),
          child:  Image.asset(
            AppImages.profileCat,
            fit: BoxFit.cover, ),
        )
            : CachedNetworkImageCircular(
          imageUrl: userModel.image,
          radius: Sizes.userImageMediumRadius(context),
        ),
        SizedBox(
          height: Sizes.vMarginComment(context),
        ),
        //nombre
        CustomText.h3(
          context,
          userModel.name!.isEmpty
              ? 'User${userModel.uId.substring(0, 6)}'
              : userModel.name!,
          weight: FontStyles.fontWeightMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          alignment: Alignment.center,
        ),
        SizedBox(
          height: Sizes.vMarginDot(context),
        ),

        //email
        /*CustomText.h5(
          context,
          userModel.email,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          alignment: Alignment.center,
        ),*/
      ],
    );
  }
}
