import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:discuzq/widgets/common/discuzIcon.dart';
import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/widgets/ui/ui.dart';

class DiscuzButton extends StatelessWidget {
  final Function onPressed;
  final String label;
  final Color color;
  final Color labelColor;
  final double width;
  final double height;
  final DiscuzIcon icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const DiscuzButton(
      {@required this.onPressed,
      this.label = 'Button',
      this.labelColor = Colors.white,
      this.height = 45,
      this.icon,
      this.fontSize,
      this.borderRadius = const BorderRadius.all(const Radius.circular(50)),
      this.padding,
      this.width = double.infinity,
      this.color});

  @override
  Widget build(BuildContext context) {
    return _buildCupertinoButton(context: context);
  }

  Widget _buildCupertinoButton({BuildContext context}) {
    return SizedBox(
      width: width,
      height: height,
      child: FlatButton(
        padding: padding ??
            const EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 10),
        color: color ?? DiscuzApp.themeOf(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            icon == null
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(right: 10), child: icon),
            DiscuzText(
              label,
              color: labelColor,
              fontSize: fontSize,
            )
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
