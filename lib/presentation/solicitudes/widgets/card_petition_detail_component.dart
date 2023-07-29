import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/domain/services/localization_service.dart';

import '../../styles/app_colors.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

class CardPetitionDetailsComponent extends StatelessWidget {
  final Solicitud solicitud;

  const CardPetitionDetailsComponent({
    required this.solicitud,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String rol = GetStorage().read('rol') ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        //Icon(PlatformIcons(context).book),
        ClipOval(
          child: SizedBox.fromSize(
            size: Size.fromRadius(28), // Image radius
            child: Image.asset(
                Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                    ? AppImages.petition
                    : AppImages.petition,
                fit: BoxFit.cover
            ),
          ),
        ),

        SizedBox(
          width: Sizes.hMarginSmallest(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (rol == 'supervisor')
              ? CustomText.h3(
                context,
                '${tr(context).peti_send_to} a ${solicitud.emailSup} ',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
             : CustomText.h3(
                context,
                tr(context).wants_super.replaceAll("%emailBoss", solicitud.emailBoss),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2,),
              CustomText.h3(
                context,
                '${tr(context).state}: ${solicitud.estado}',
                color: (solicitud.estado == 'rechazada')
                    ? AppColors.red
                    :null,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
