import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../domain/services/localization_service.dart';
import '../../styles/sizes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';

class RegisterSupervisedTextFieldsSection extends StatelessWidget {
  const RegisterSupervisedTextFieldsSection({
    required this.emailControllerSupervised,
    required this.passwordControllerSupervised,
    required this.onFieldSubmitted,
    Key? key,
  }) : super(key: key);

  final TextEditingController emailControllerSupervised;
  final TextEditingController passwordControllerSupervised;

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
            SizedBox(height: Sizes.textFieldVMarginDefault(context)),
          ],
        );
      },
    );
  }

  _sharedItemComponent(BuildContext context) {
    return [
      CustomText.h3(context, tr(context).askDates),

      SizedBox(height: Sizes.textFieldVMarginDefault(context)),

      CustomTextField(
        context,
        key: const ValueKey('login_emailS'),
        hintText: tr(context).email,
        controller: emailControllerSupervised,
        validator: Validators.instance.validateEmail(context),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        suffixIcon: Icon(PlatformIcons(context).mail),
      ),

      CustomTextField(
        context,
        key:  const ValueKey('login_passwordS'),
        hintText: tr(context).password,
        controller: passwordControllerSupervised,
        validator: Validators.instance.validateLoginPassword(context),
        textInputAction: TextInputAction.go,
        obscureText: true,
        suffixIcon: const Icon(Icons.password),
        onFieldSubmitted: onFieldSubmitted,
      ),

    ];

  }

}
