import 'package:flutter/material.dart';

class DiscuzDivider extends StatelessWidget {
  final double padding;

  const DiscuzDivider({Key key, this.padding = 45}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.only(left: padding),
      child: const Divider(
        height: .56,
        color: const Color(0x1F000000)
      ),
    );
  }
}
