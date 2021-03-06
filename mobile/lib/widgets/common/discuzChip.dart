import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/widgets/ui/ui.dart';
import 'package:flutter/material.dart';

const double _kDefaultChipWidth = 40;
const double _kDefaultChipHeight = 25;

class DiscuzChip extends StatelessWidget {
  
  const DiscuzChip({this.label = '标签', this.color, this.width});

  ///
  /// label 标签
  ///
  final String label;

  ///
  /// color
  final Color color;

  ///
  /// width
  final double width;

  @override
  Widget build(BuildContext context) {
    final Color blendedColor =
        color != null ? color : DiscuzApp.themeOf(context).primaryColor;

    return Container(
      width: width ?? _kDefaultChipWidth,
      height: _kDefaultChipHeight,
      padding: const EdgeInsets.only(left: 6, right: 6),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(const Radius.circular(50)),
        color: blendedColor.withOpacity(.24),
      ),
      alignment: Alignment.center,
      child: DiscuzText(
        label,
        color: blendedColor,
      ),
    );
  }
}
