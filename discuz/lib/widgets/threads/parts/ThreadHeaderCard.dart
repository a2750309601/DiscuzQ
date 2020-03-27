import 'package:discuzq/utils/dateUtil.dart';
import 'package:flutter/material.dart';

import 'package:discuzq/widgets/common/discuzAvatar.dart';
import 'package:discuzq/models/threadModel.dart';
import 'package:discuzq/models/userModel.dart';
import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/widgets/ui/ui.dart';
import 'package:discuzq/router/route.dart';
import 'package:discuzq/views/users/userHomeDelegate.dart';
import 'package:discuzq/widgets/common/discuzIcon.dart';
import 'package:discuzq/widgets/threads/parts/ThreadPopmenu.dart';

///
/// ThreadHeaderCard
/// 主题的顶部信息显示
class ThreadHeaderCard extends StatelessWidget {
  ///
  /// 作者
  final UserModel author;

  ///
  /// 主题
  final ThreadModel thread;

  ///
  /// 是否显示更多操作
  final bool showOperations;

  const ThreadHeaderCard(
      {@required this.author,
      @required this.thread,
      this.showOperations = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          ///
          /// user avatar
          GestureDetector(
            onTap: () => DiscuzRoute.open(
                context: context,
                shouldLogin: true,
                widget: UserHomeDelegate(
                  user: author,
                )),
            child: DiscuzAvatar(
              size: 35,
              url: author.avatarUrl,
            ),
          ),

          /// userinfo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DiscuzText(
                    author.username,
                    fontWeight: FontWeight.bold,
                  ),
                  DiscuzText(
                    ///
                    /// 格式化时间
                    DateUtil.formatDate(
                        DateTime.parse(thread.attributes.createdAt),
                        format: "yyyy-MM-dd HH:mm"),
                    color: DiscuzApp.themeOf(context).greyTextColor,
                    fontSize: DiscuzApp.themeOf(context).smallTextSize,
                  )
                ],
              ),

              /// pop menu
            ),
          ),

          /// isSticky
          thread.attributes.isSticky
              ? const DiscuzIcon(0xe60c)
              : const SizedBox(),

          /// popmenu
          showOperations == true
              ? ThreadPopMenu(
                  thread: thread,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
