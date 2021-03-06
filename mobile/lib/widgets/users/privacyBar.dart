import 'package:flutter/material.dart';

import 'package:discuzq/router/route.dart';
import 'package:discuzq/views/settings/privaciesDelegate.dart';
import 'package:discuzq/widgets/common/discuzLink.dart';
import 'package:discuzq/widgets/common/discuzText.dart';
import 'package:discuzq/utils/buildInfo.dart';
import 'package:discuzq/widgets/webview/webviewHelper.dart';

class PrivacyBar extends StatelessWidget {
  const PrivacyBar({Key key, this.showNotice = true}) : super(key: key);

  final bool showNotice;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showNotice
                ? const DiscuzText(
                    '如您继续代表您同意',
                  )
                : const SizedBox(),
            DiscuzLink(
              label: '隐私协议',
              onTap: () {
                if (BuildInfo().info().privacy != "") {
                  WebviewHelper.launchUrl(url: BuildInfo().info().privacy);
                  return;
                }

                DiscuzRoute.navigate(
                    context: context,
                    widget: const PrivaciesDelegate(
                      isPrivacy: true,
                    ));
              },
            ),
            const DiscuzText('和'),
            DiscuzLink(
              label: '用户协议',
              onTap: () {
                if (BuildInfo().info().policy != "") {
                  WebviewHelper.launchUrl(url: BuildInfo().info().policy);
                  return;
                }
                DiscuzRoute.navigate(
                    context: context,
                    widget: const PrivaciesDelegate(
                      isPrivacy: false,
                    ));
              },
            ),
          ],
        ),
      );
}
