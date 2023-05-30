import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';


class NameTaskTextFieldsSection extends StatelessWidget {
  const NameTaskTextFieldsSection({
    required this.nameController,
    required this.onFieldSubmitted,
    Key? key,
  }) : super(key: key);

  final TextEditingController nameController;
  final Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) {
        return Column(
          children: _sharedItemComponent(context),
        );
      },
      cupertino: (_, __) {
        return Column(
          children: [
            CupertinoFormSection.insetGrouped(
              backgroundColor: Colors.transparent,
              margin: EdgeInsets.zero,
              children: _sharedItemComponent(context),
            ),
            //SizedBox(height: Sizes.textFieldVMarginDefault(context)),
          ],
        );
      },
    );
  }

  _sharedItemComponent(BuildContext context) {
    return [
      CustomTextField(
        context,
        key: const ValueKey('task_name'),
        hintText: tr(context).taskName,
        controller: nameController,
        validator: Validators.instance.validateName(context),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        suffixIcon: Icon(PlatformIcons(context).folderOpen),
        onFieldSubmitted: onFieldSubmitted
      ),


    ];
  }
}
