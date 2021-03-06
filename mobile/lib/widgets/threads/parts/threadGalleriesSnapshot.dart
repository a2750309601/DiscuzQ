import 'package:discuzq/widgets/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';

import 'package:discuzq/widgets/threads/threadsCacher.dart';
import 'package:discuzq/models/postModel.dart';
import 'package:discuzq/models/attachmentsModel.dart';
import 'package:discuzq/models/threadModel.dart';
import 'package:discuzq/widgets/common/discuzImage.dart';
import 'package:discuzq/views/gallery/discuzGalleryDelegate.dart';
import 'package:discuzq/router/route.dart';

///
/// 帖子9宫格图片预览组件
///
class ThreadGalleriesSnapshot extends StatelessWidget {
  ///------------------------------
  /// threadsCacher 是用于缓存当前页面的故事数据的对象
  /// 当数据更新的时候，数据会存储到 threadsCacher
  /// threadsCacher 在页面销毁的时候，务必清空 .clear()
  ///
  final ThreadsCacher threadsCacher;

  ///
  /// 第一条post
  final PostModel firstPost;

  ///
  /// 关联的故事
  final ThreadModel thread;

  ThreadGalleriesSnapshot(
      {@required this.threadsCacher,
      @required this.firstPost,
      @required this.thread});

  @override
  Widget build(BuildContext context) {
    ///
    /// 一个图片都没有，直接返回，能省事就省事
    if (threadsCacher.attachments.length == 0) {
      return const SizedBox();
    }

    final List<dynamic> getPostImages = firstPost.relationships.images;

    /// 如果没有关联的图片，那还不是返回，不渲染
    if (getPostImages.length == 0) {
      return const SizedBox();
    }

    /// 将relationships中的数据和attachments对应，并生成attachmentsModel的数组
    final List<AttachmentsModel> attachmentsModels = [];
    getPostImages.forEach((e) {
      final int id = int.tryParse(e['id']);
      final AttachmentsModel attachment = threadsCacher.attachments
          .where((AttachmentsModel find) => find.id == id)
          .toList()[0];
      if (attachment != null) {
        attachmentsModels.add(attachment);
      }
    });

    /// 可能出现找不到 对应图片的问题
    if (attachmentsModels == null || attachmentsModels.length == 0) {
      return const SizedBox();
    }

    ///
    /// 原图所有图片Url 图集
    final List<String> originalImageUrls = attachmentsModels
        .map((e) => e.attributes.url)
        .toList()
        .take(9)
        .toList();

    return Container(
      width: double.infinity,
      height: 300,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DiscuzImage(
                attachment: attachmentsModels[index],
                enbleShare: true,
                thread: thread,
                borderRadius: BorderRadius.zero,
                fit: BoxFit.fitWidth,
                onWantOriginalImage: (String targetUrl) {
                  /// 显示原图图集
                  /// targetUrl是用户点击到的要查看的图片
                  /// 调整数组，将targetUrl置于第一个，然后传入图集组件
                  originalImageUrls.remove(targetUrl);
                  originalImageUrls.insert(0, targetUrl);
                  return DiscuzRoute.navigate(
                      context: context,
                      widget:
                          DiscuzGalleryDelegate(gallery: originalImageUrls));
                }),
          );
        },
        itemCount: originalImageUrls.length,
        pagination: const SwiperPagination(
            margin: EdgeInsets.zero,
            builder: const DotSwiperPaginationBuilder()),
      ),
    );
  }
}

class DotSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color color;

  ///Size of the dot when activate
  final double activeSize;

  ///Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key key;

  const DotSwiperPaginationBuilder(
      {this.activeColor,
      this.color,
      this.key,
      this.size: 5.0,
      this.activeSize: 7.0,
      this.space: 3.0});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    if (config.itemCount > 20) {
      print(
          "The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this sitituation");
    }
    Color activeColor = this.activeColor;
    Color color = this.color;

    if (activeColor == null || color == null) {
      activeColor = this.activeColor ?? DiscuzApp.themeOf(context).primaryColor;
      color = this.color ?? DiscuzApp.themeOf(context).greyTextColor;
    }

    if (config.indicatorLayout != PageIndicatorLayout.NONE &&
        config.layout == SwiperLayout.DEFAULT) {
      return new PageIndicator(
        count: config.itemCount,
        controller: config.pageController,
        layout: config.indicatorLayout,
        size: size,
        activeColor: activeColor,
        color: color,
        space: space,
      );
    }

    List<Widget> list = [];

    int itemCount = config.itemCount;
    int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      list.add(Container(
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
        child: ClipOval(
          child: Container(
            color: active ? activeColor : color,
            width: active ? activeSize : size,
            height: active ? activeSize : size,
          ),
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return new Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    } else {
      return new Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    }
  }
}
