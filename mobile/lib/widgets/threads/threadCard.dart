import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:discuzq/models/threadModel.dart';
import 'package:discuzq/models/userModel.dart';
import 'package:discuzq/models/postModel.dart';
import 'package:discuzq/widgets/ui/ui.dart';
import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/widgets/threads/threadsCacher.dart';
import 'package:discuzq/widgets/threads/parts/threadHeaderCard.dart';
import 'package:discuzq/widgets/threads/parts/threadPostSnapshot.dart';
import 'package:discuzq/router/route.dart';
import 'package:discuzq/views/threads/threadDetailDelegate.dart';
import 'package:discuzq/widgets/htmRender/htmlRender.dart';
import 'package:discuzq/widgets/threads/parts/threadGalleriesSnapshot.dart';
import 'package:discuzq/widgets/threads/parts/threadVideoSnapshot.dart';
import 'package:discuzq/widgets/threads/parts/threadCardQuickActions.dart';
import 'package:discuzq/utils/global.dart';
import 'package:discuzq/providers/appConfigProvider.dart';

///
/// flat title length to substr
const int _kFlatTitleLength = 15;

///
/// 故事卡片
/// 用于展示一个故事的快照，但不是详情
class ThreadCard extends StatefulWidget {
  ThreadCard(
      {this.thread,
      @required this.threadsCacher,
      this.onDelete,
      this.initiallyExpanded = false});

  ///
  /// thread
  /// 故事
  ///
  final ThreadModel thread;

  ///------------------------------
  /// threadsCacher 是用于缓存当前页面的故事数据的对象
  final ThreadsCacher threadsCacher;

  ///
  /// ------
  /// 当卡片被删除，注意，因为该组件存在threadsCacher，所以删除threadsCacher来影响UIbuild的过程在该组件内
  /// 其次，注意，该回调仅用于其他处理，不用在处理删除显示当前故事
  final Function onDelete;

  ///
  /// ----
  /// initiallyExpanded
  /// 默认是否展开(为置顶的故事默认展开)
  final bool initiallyExpanded;

  @override
  _ThreadCardState createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard>
    with AutomaticKeepAliveClientMixin {
  /// 当前帖子的作者
  UserModel _author = const UserModel();

  /// firstPost 指定的是故事第一个帖子，其他的是回复
  PostModel _firstPost = const PostModel();

  ///
  /// 是否需要支付才能查看
  bool get _requiredPaymentToPlay => widget.thread.attributes.paid ||
          double.tryParse(widget.thread.attributes.price) == 0
      ? false
      : true;

  @override
  void initState() {
    super.initState();
    _author = widget.threadsCacher.users.lastWhere((UserModel it) =>
            it.id ==
            int.tryParse(widget.thread.relationships.user['data']['id'])) ??
        const UserModel();

    /// 查找firstPost
    _firstPost = widget.threadsCacher.posts.lastWhere((PostModel it) =>
            it.id ==
            int.tryParse(
                widget.thread.relationships.firstPost['data']['id'])) ??
        const PostModel();

    /// 查找附件图片
  }

  @override
  bool get wantKeepAlive => true;

  ///
  /// Build 卡片的的过程中需要注意的是，如果故事顶置，则需要支持收起
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AppConfigProvider>(
        builder: (BuildContext context, AppConfigProvider conf, Widget child) =>
            RepaintBoundary(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => DiscuzRoute.navigate(
                    context: context,
                    widget: ThreadDetailDelegate(
                      author: _author,
                      thread: widget.thread,
                    )),
                child: _buildCard(conf: conf, context: context),
              ),
            ));
  }

  ///
  /// 生成内容
  /// 实际上，我们会收起顶置的帖子
  /// 其次，如果用户设置了收起付费的帖子，他们也会被折叠，但用不同的颜色提示
  Widget _buildCard({BuildContext context, dynamic conf}) {
    if (widget.thread.attributes.isSticky && !widget.initiallyExpanded) {
      return _buildStickyThreadTitle(context);
    }

    return conf.appConf['hideContentRequirePayments'] && _requiredPaymentToPlay
        ? const SizedBox()
        : _buildThreadCard(context);
  }

  ///
  /// 生成简单的标题，取固定值
  ///
  String get _flatTitle => widget.thread.attributes.title != ''
      ? widget.thread.attributes.title
      : _firstPost.attributes.content.length <= _kFlatTitleLength
          ? _firstPost.attributes.content
          : "${_firstPost.attributes.content.substring(0, _kFlatTitleLength)}...";

  // /
  // / 可收起的故事
  // /
  Widget _buildStickyThreadTitle(BuildContext context) {
    final Widget stickyIcon = SizedBox(
      width: 60,
      height: 25,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10),
        decoration: const BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(4)),
          color: Global.scaffoldBackgroundColorLight,
        ),
        child: const DiscuzText('置顶', color: Colors.black),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: kMarginAllContent,
        decoration: BoxDecoration(
          color: DiscuzApp.themeOf(context).backgroundColor,
          border: const Border(bottom: Global.border),
        ),
        child: Row(
          children: <Widget>[
            stickyIcon,
            DiscuzText(
              _flatTitle,
            )
          ],
        ),
      ),
      onTap: () => DiscuzRoute.navigate(
          context: context,
          shouldLogin: true,
          widget: ThreadDetailDelegate(
            author: _author,
            thread: widget.thread,
          )),
    );
  }

  ///
  /// 构建帖子卡片
  ///
  Widget _buildThreadCard(BuildContext context) => Container(
        padding: const EdgeInsets.only(
          top: 10,
        ),
        decoration: BoxDecoration(
            color: DiscuzApp.themeOf(context).backgroundColor,
            borderRadius: BorderRadius.circular(5)),
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ///
            /// 故事顶部的用户信息
            ThreadHeaderCard(
              thread: widget.thread,
              author: _author,
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  /// 显示故事的title
                  _buildContentTitle,

                  /// 故事的内容
                  widget.thread.attributes.title != ''
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(
                              right: 5, left: 5, bottom: 5),
                          child: HtmlRender(
                            html: _firstPost.attributes.contentHtml,
                          ),
                        ),

                  /// 渲染九宫格图片
                  ///
                  ///
                  ThreadGalleriesSnapshot(
                    firstPost: _firstPost,
                    threadsCacher: widget.threadsCacher,
                    thread: widget.thread,
                  ),

                  ///
                  /// 用于渲染小视频
                  ///
                  widget.thread.relationships.threadVideo == null
                      ? const SizedBox()
                      : ThreadVideoSnapshot(
                          threadsCacher: widget.threadsCacher,
                          thread: widget.thread,
                          post: _firstPost,
                        ),
                ],
              ),
            ),

            ///
            /// 梯子快捷操��工具栏
            ThreadCardQuickActions(
                firstPost: _firstPost, thread: widget.thread, author: _author),

            /// 楼层评论
            ThreadPostSnapshot(
              replyCounts: widget.thread.attributes.postCount,
              lastThreePosts: widget.thread.relationships.lastThreePosts,
              firstPost: _firstPost,
              threadsCacher: widget.threadsCacher,
              thread: widget.thread,
              author: _author,
            ),
          ],
        ),
      );

  Widget get _buildContentTitle => Builder(builder: (BuildContext context) {
        bool isLongContent = true;

        String title = widget.thread.attributes.title.trim();

        if (title.isEmpty) {
          title = _firstPost.attributes.summaryText;
          isLongContent = false;
        }

        return GestureDetector(
          onTap: () => DiscuzRoute.navigate(
              context: context,
              shouldLogin: true,
              widget: ThreadDetailDelegate(
                author: _author,
                thread: widget.thread,
              )),
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            //decoration: const BoxDecoration(border: Border(top: Global.border)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DiscuzText(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w500,
                    color: DiscuzApp.themeOf(context).textColor,
                  ),
                )
              ],
            ),
          ),
        );
      });
}
