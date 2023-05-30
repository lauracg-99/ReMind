import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../../data/auth/providers/checkbox_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';
import 'customCheckbox_component.dart';

class RegisterTextFieldsSection extends StatelessWidget {
  const RegisterTextFieldsSection({
    required this.nameController,
    required this.emailController,
    required this.emailController2,
    required this.passwordController,
    required this.passwordController2,
    required this.iconButton,
    required this.see,
    required this.iconButton2,
    required this.see2,
    Key? key,
  }) : super(key: key);

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController emailController2;
  final TextEditingController passwordController;
  final TextEditingController passwordController2;
  final IconButton iconButton;
  final bool see;

  final IconButton iconButton2;
  final bool see2;

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
      CustomTextField(
        context,
        key: const ValueKey('register_name'),
        hintText: tr(context).name,
        controller: nameController,
        validator: Validators.instance.validateName(context),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        suffixIcon: Icon(PlatformIcons(context).accountCircle),
      ),
      CustomTextField(
        context,
        key: const ValueKey('register_email'),
        hintText: tr(context).email,
        controller: emailController,
        validator: Validators.instance.validateEmail(context),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        suffixIcon: Icon(PlatformIcons(context).mail),
      ),
      CustomTextField(
        context,
        key: const ValueKey('register_email2'),
        hintText: tr(context).email2,
        controller: emailController2,
        validator: Validators.instance.validateEmail2(context,emailController2.text, emailController.text),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        suffixIcon: Icon(PlatformIcons(context).mail),
      ),

      CustomTextField(
        context,
        key:  const ValueKey('register_password'),
        hintText: tr(context).password,
        controller: passwordController,
        validator: Validators.instance.validateLoginPassword(context),
        textInputAction: TextInputAction.next,
        obscureText: see,
        suffixIcon: iconButton,
      ),

      CustomTextField(
        context,
        key:  const ValueKey('register_password2'),
        hintText: tr(context).password2,
        controller: passwordController2,
        validator: Validators.instance.validateRegisterPassword2(context, passwordController2.text, passwordController.text),
        textInputAction: TextInputAction.next,
        obscureText: see2,
        suffixIcon: iconButton2,
      ),

      CustomCheckBoxComponent()

    ];
  }
}
