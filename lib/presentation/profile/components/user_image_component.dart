import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../components/image_pick_component.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../widgets/cached_network_image_circular.dart';
import '../providers/profile_provider.dart';

class UserImageComponent extends ConsumerWidget {
  const UserImageComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final userModel = ref.watch(userRepoProvider).userModel!;
    final profileVM = ref.watch(profileProvider.notifier);
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        (userModel.image == '')
            ? CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Sizes.userImageHighRadius(context),
              child:  Image.asset(
                AppImages.profileCat,
                fit: BoxFit.cover, ),
            )
            : CachedNetworkImageCircular(
          imageUrl: userModel.image,
          radius: Sizes.userImageHighRadius(context),
        ),
        Padding(
          padding: EdgeInsets.only(right: Sizes.hPaddingTiny(context)),
          child: ImagePickComponent(
            pickFromCameraFunction: () {
              profileVM.updateProfileImage(context, fromCamera: true);
            },
            pickFromGalleryFunction: () {
              profileVM.updateProfileImage(context, fromCamera: false);
            },
          ),
        ),
      ],
    );
  }
}
