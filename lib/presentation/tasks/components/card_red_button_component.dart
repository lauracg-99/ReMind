import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_outlined_button.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import 'card_red_button_component.dart';


class CardRedButtonComponent extends StatelessWidget {
  final String title;
  final bool isColored;
  final VoidCallback? onPressed;

  const CardRedButtonComponent({
    required this.title,
    required this.isColored,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomOutlinedButton(
      height: Sizes.roundedButtonMediumHeight(context),
      width: Sizes.roundedButtonMediumWidth(context),
      side: isColored ? null : const BorderSide(color: AppColors.carbonic),
      buttonColor: isColored ? null : Colors.red,
      splashColor: isColored ? null : AppColors.lightThemePrimary,
      onPressed: onPressed,
      child: CustomText.h5(
        context,
        title,
        color: isColored
            ? Theme.of(context).textTheme.headline4!.color
            : AppColors.white,
        weight: FontStyles.fontWeightBold,
        alignment: Alignment.center,
      ),
    );
  }
}
