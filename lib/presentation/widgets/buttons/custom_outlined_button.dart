import 'package:flutter/material.dart';

import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../custom_text.dart';

class CustomOutlinedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? minHeight;
  final Widget? child;
  final String? text;
  final VoidCallback? onPressed;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final double? elevation;
  final Color? buttonColor;
  final Color? splashColor;
  final Color? shadowColor;
  final Gradient? gradientColor;
  final BorderRadiusGeometry? gradientBorderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onLongPress;

  const CustomOutlinedButton({
    this.height,
    this.width,
    this.minHeight,
    this.child,
    this.text,
    required this.onPressed,
    this.shape,
    this.side,
    this.elevation,
    this.buttonColor,
    this.splashColor,
    this.shadowColor,
    this.gradientColor,
    this.gradientBorderRadius,
    this.padding,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: splashColor, shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Sizes.roundedButtonDefaultRadius(context),
              ),
            ),
        side: side,
        elevation: elevation ?? 0,
        backgroundColor: buttonColor,
        shadowColor: shadowColor,
        padding: padding ??
            EdgeInsets.zero, //Not necessary if you added height and width.
      ),
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: Container(
        height: height ?? Sizes.roundedButtonDefaultHeight(context),
        width: width ?? Sizes.roundedButtonDefaultWidth(context),
        constraints: BoxConstraints(
          minHeight: minHeight ?? Sizes.roundedButtonMinHeight(context),
        ),
        decoration: buttonColor == null
            ? BoxDecoration(
                borderRadius: gradientBorderRadius ??
                    BorderRadius.circular(
                        Sizes.roundedButtonDefaultRadius(context)),
                gradient: LinearGradient(colors:
                  [Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondary]
                ),
              )
            : null,
        child: child ??
            CustomText.h4(
              context,
              text!,
              color: buttonColor == null ? const Color(0xffffffff) : null,
              weight: FontStyles.fontWeightMedium,
              alignment: Alignment.center,
            ),
      ),
    );
  }
}
