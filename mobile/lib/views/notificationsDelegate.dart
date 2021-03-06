import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'package:provider/provider.dart';

import 'package:discuzq/widgets/appbar/appbarExt.dart';
import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/widgets/common/discuzListTile.dart';
import 'package:discuzq/widgets/ui/ui.dart';
import 'package:discuzq/utils/authHelper.dart';
import 'package:discuzq/widgets/common/discuzToast.dart';
import 'package:discuzq/router/route.dart';
import 'package:discuzq/widgets/common/discuzRefresh.dart';
import 'package:discuzq/widgets/common/discuzIcon.dart';
import 'package:discuzq/models/typeUnreadNotificationsModel.dart';
import 'package:discuzq/utils/buildInfo.dart';
import 'package:discuzq/views/nofitications/notificationListDelegate.dart';
import 'package:discuzq/providers/userProvider.dart';

class NotificationsDelegate extends StatefulWidget {
  const NotificationsDelegate({Key key}) : super(key: key);
  @override
  _NotificationsDelegateState createState() => _NotificationsDelegateState();
}

class _NotificationsDelegateState extends State<NotificationsDelegate> {
  ///
  /// _controller refresh
  ///
  final RefreshController _controller = RefreshController();

  final CancelToken _cancelToken = CancelToken();

  ///
  /// 未读消息
  TypeUnreadNotificationsModel _typeUnreadNotifications =
      const TypeUnreadNotificationsModel();

  @override
  void setState(fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    ///
    /// 窗体准备完毕后，过几秒为用户刷新信息啦
    /// 这种不会从接口刷新，仅从状态刷新，如果用户要刷新还是得下拉
    /// 或者其他交互逻辑涉及调用 Authhelper.refreshUser 也会自动刷新的
    ///
    Future.delayed(Duration.zero)
        .then((_) => _refreshMessageList(context: context));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cancelToken.cancel();

    /// do not forget to dispose _controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: DiscuzAppBar(
          title: '消息通知',
        ),
        body: DiscuzRefresh(
          enablePullDown: true,
          enablePullUp: false,
          // header: WaterDropHeader(),
          controller: _controller,
          onRefresh: () async {
            await _refreshMessageList(context: context);
            _controller.finishRefresh();
          },
          child: Container(
              decoration: BoxDecoration(
                  color: DiscuzApp.themeOf(context).backgroundColor,
                  borderRadius: BorderRadius.circular(5)),
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Column(
                    children: <Widget>[
                      ///
                      /// @我的
                      ///
                      _notificationsSelection(
                        item: _NotificationMenuItem(
                            label: '提及我的',
                            icon: CupertinoIcons.at,
                            child: const NotificationListDelegate(
                                type: NotificationTypes.related),
                            badges: _typeUnreadNotifications.replied),
                      ),

                      ///
                      /// 回复我的
                      ///
                      _notificationsSelection(
                        item: _NotificationMenuItem(
                            label: '回复我的',
                            icon: 0xe624,
                            child: const NotificationListDelegate(
                                type: NotificationTypes.replies),
                            badges: _typeUnreadNotifications.replied),
                      ),

                      ///
                      /// 金融相关功能
                      /// 打赏通知
                      ///
                      BuildInfo().info().financial
                          ? _notificationsSelection(
                              item: _NotificationMenuItem(
                                  label: '财务通知',
                                  icon: CupertinoIcons.money_yen_circle,
                                  child: const NotificationListDelegate(
                                      type: NotificationTypes.rewarded),
                                  badges: _typeUnreadNotifications.rewarded),
                            )
                          : const SizedBox(),

                      ///
                      /// 点赞我的
                      _notificationsSelection(
                        item: _NotificationMenuItem(
                            label: '点赞我的',
                            icon: CupertinoIcons.heart,
                            child: const NotificationListDelegate(
                                type: NotificationTypes.liked),
                            badges: _typeUnreadNotifications.liked),
                      ),

                      ///
                      /// 系统通知
                      _notificationsSelection(
                        item: _NotificationMenuItem(
                            label: '系统通知',
                            child: const NotificationListDelegate(
                                type: NotificationTypes.system),
                            icon: CupertinoIcons.bell,
                            badges: _typeUnreadNotifications.system),
                      )
                    ],
                  ))),
        ),
      );

  ///
  /// 生成通知列表
  /// 通知列表的具体数据，根据 _menus 生成
  /// 具体的更新逻辑，参考 _refreshMessageList
  ///
  Widget _notificationsSelection({_NotificationMenuItem item}) => Container(
        decoration:
            BoxDecoration(color: DiscuzApp.themeOf(context).backgroundColor),
        child: Column(
          children: <Widget>[
            DiscuzListTile(
              leading: DiscuzIcon(item.icon),
              title: DiscuzText(item.label),

              ///
              /// 点击查看消息
              ///
              onTap: () => item.child == null
                  ? DiscuzToast.failed(context: context, message: '暂不支持')
                  : DiscuzRoute.navigate(context: context, widget: item.child),
              trailing: item.badges != null && item.badges > 0
                  ? Badge(
                      /// 显示消息条目长度
                      badgeContent: DiscuzText(
                        item.badges.toString(),
                        color: Colors.white,
                      ),
                      animationType: BadgeAnimationType.slide,
                      elevation: 0,
                    )
                  : const DiscuzListTileTrailing(),
            ),
          ],
        ),
      );

  ///
  /// 下拉刷新列表
  /// 刷新列表的时候，要更新用户信息
  /// 其实这个信息不需要重构，直接从用户信息下取就可以了
  /// unreadNotifications	int		未读消息数
  /// typeUnreadNotifications	array		未读消息数明细
  /// typeUnreadNotifications.replied	array		未读回复消息数
  /// typeUnreadNotifications.liked	array		未读点赞消息数
  /// typeUnreadNotifications.rewarded	array		未读打赏消息数
  /// typeUnreadNotifications.system	array		未读系统消息数
  /// #返回示例
  ///
  Future<void> _refreshMessageList({BuildContext context}) async {
    final bool refreshed = await AuthHelper.refreshUser(
        context: context, cancelToken: _cancelToken);
    if (!refreshed) {
      DiscuzToast.failed(context: context, message: '刷新失败');
      return;
    }

    _refreshStateOnly(context: context);
  }

  ///
  /// 仅刷新状态
  /// 页面initState 和 _refreshMessageList 都会刷新状态
  void _refreshStateOnly({BuildContext context}) {
    ///
    /// 刷新列表
    /// 数据为空则不要继续
    ///
    if (context.read<UserProvider>().user.attributes.typeUnreadNotifications ==
        null) {
      return;
    }

    final TypeUnreadNotificationsModel notifications =
        context.read<UserProvider>().user.attributes.typeUnreadNotifications;
    if (notifications == null || !mounted) {
      return;
    }

    ///
    /// 刷新状态
    /// 消息数目就会自动刷新
    /// 要处理null，因为有时候可能没有对应的数据
    /// 就是那么懒
    /// todo:增加消息查看组件
    setState(() {
      _typeUnreadNotifications =
          context.read<UserProvider>().user.attributes.typeUnreadNotifications;
    });
  }
}

///
/// 菜单条目
class _NotificationMenuItem {
  /// 选项名称
  final String label;

  /// badges 数量
  final int badges;

  /// child 用于查看消息的组件
  final Widget child;

  /// icon
  final dynamic icon;

  const _NotificationMenuItem({
    @required this.label,
    this.badges,
    this.icon,
    this.child,
  });
}
