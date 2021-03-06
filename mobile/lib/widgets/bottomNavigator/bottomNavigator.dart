import 'dart:math' as math;
import 'package:discuzq/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:discuzq/utils/authHelper.dart';
import 'package:discuzq/widgets/common/discuzIcon.dart';
import 'package:discuzq/widgets/ui/ui.dart';
import 'package:discuzq/widgets/forum/forumAddButton.dart';
import 'package:discuzq/providers/userProvider.dart';

const double _kBottomNavigationElevation = 0;

const double _kPublishButtonSize = 38;

class DiscuzBottomNavigator extends StatefulWidget {
  final ValueChanged<int> onItemSelected;
  final List<NavigatorItem> items;

  DiscuzBottomNavigator({
    @required this.onItemSelected,
    @required this.items,
  }) {
    assert(onItemSelected != null);
  }

  @override
  _DiscuzBottomNavigatorState createState() =>
      _DiscuzBottomNavigatorState(onItemSelected: onItemSelected);
}

class _DiscuzBottomNavigatorState extends State<DiscuzBottomNavigator> {
  final ValueChanged<int> onItemSelected;
  final double height;

  int selectedIndex = 0;

  _DiscuzBottomNavigatorState(
      {@required this.onItemSelected, this.height = 40});
  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding =
        math.max(MediaQuery.of(context).padding.bottom - 12 / 2.0, 0.0);

    return Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider user, Widget child) =>
            Material(
              elevation: _kBottomNavigationElevation,
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight:
                        kBottomNavigationBarHeight + additionalBottomPadding),
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: DiscuzApp.themeOf(context).backgroundColor,
                  border: const Border(top: Global.border),
                  // borderRadius: const BorderRadius.only(
                  //     topLeft: Radius.circular(10),
                  //     topRight: Radius.circular(10))
                ),
                child: _buildItems(),
              ),
            ));
  }

  Widget _buildItems() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.items.map<Widget>((it) {
        if (it.isPublishButton) {
          return const _PublishButton();
        }

        final int index = widget.items.indexOf(it);

        return GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DiscuzIcon(it.icon,
                  size: it.size,
                  color: selectedIndex == index
                      ? Theme.of(context).primaryColor
                      : DiscuzApp.themeOf(context).textColor
                  //: const Color(0xFF657786),
                  ),
            ],
          ),
          onTap: () async {
            if (it.shouldLogin == true) {
              bool success =
                  await AuthHelper.requsetShouldLogin(context: context);
              if (!success) {
                return;
              }
            }

            onItemSelected(index);
            setState(() {
              selectedIndex = index;
            });
          },
        );
      }).toList());
}

class _PublishButton extends StatelessWidget {
  const _PublishButton();

  @override
  Widget build(BuildContext context) => Container(
        width: _kPublishButtonSize,
        height: _kPublishButtonSize,
        decoration: BoxDecoration(
            color: DiscuzApp.themeOf(context).textColor,
            borderRadius: const BorderRadius.all(const Radius.circular(50))),
        child: const ForumAddButton(
          padding: EdgeInsets.zero,
        ),
      );
}

class NavigatorItem {
  /// 图标
  final dynamic icon;

  /// 图标默认颜色
  final Color color;

  /// 是否需要登录才能查看
  final bool shouldLogin;

  /// 图标大小
  final double size;

  /// 是否是发布按钮
  final bool isPublishButton;

  const NavigatorItem(
      {this.icon,
      this.color,
      this.shouldLogin = false,
      this.size = 34,
      this.isPublishButton = false});
}
