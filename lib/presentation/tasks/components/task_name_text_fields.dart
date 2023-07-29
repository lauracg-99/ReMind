import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../../domain/services/localization_service.dart';
import '../../utils/validators.dart';
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
