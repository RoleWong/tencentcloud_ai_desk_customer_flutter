import 'package:flutter/material.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_statelesswidget.dart';

import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';

import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tencentcloud_ai_desk_customer/theme/color.dart';
import 'package:tencentcloud_ai_desk_customer/theme/tui_theme.dart';

class TIMUIKitTongueItem extends TIMUIKitStatelessWidget {
  /// the callback after clicking
  final VoidCallback onClick;

  /// the value type currently
  final MessageListTongueType valueType;

  /// unread amount currently
  final int unreadCount;

  /// total amount of messages at me
  final String atNum;

  final int previousCount;

  TIMUIKitTongueItem({
    Key? key,
    required this.onClick,
    required this.valueType,
    required this.previousCount,
    required this.unreadCount,
    required this.atNum,
  }) : super(key: key);

  Map<MessageListTongueType, String> textType(BuildContext context) {
    final option1 = unreadCount.toString();
    final option2 = atNum.toString();
    // final option3 = previousCount.toString();
    final String atMeString = option2 != ""
        ? TDesk_t_para("有{{option2}}条@我消息", "有$option2条@我消息")(option2: option2)
        : TDesk_t("有人@我");

    return {
      // MessageListTongueType.showPrevious:
      //     TDesk_t_para("{{option3}}条未读消息", "$option3条未读消息")(option3: option3),
      MessageListTongueType.toLatest: TDesk_t("回到最新位置"),
      MessageListTongueType.showUnread:
          TDesk_t_para("{{option1}}条新消息", "$option1条新消息")(option1: option1),
      MessageListTongueType.atMe: atMeString,
      MessageListTongueType.atAll: TDesk_t("@所有人"),
    };
  }

  final Map<MessageListTongueType, IconData> iconType = {
    MessageListTongueType.toLatest: Icons.arrow_downward_outlined,
    MessageListTongueType.showUnread: Icons.arrow_downward_outlined,
    MessageListTongueType.atMe: Icons.arrow_upward_outlined,
    MessageListTongueType.atAll: Icons.arrow_upward_outlined,
    MessageListTongueType.showPrevious: Icons.arrow_upward_outlined,
  };

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    return GestureDetector(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: hexToColor("E5E5E5"), width: 1),
          boxShadow: [
            BoxShadow(
                color: theme.weakDividerColor ?? hexToColor("E6E9EB"),
                offset: const Offset(0.0, 0.0),
                blurRadius: 10,
                spreadRadius: 2),
          ],
        ),
        padding: const EdgeInsets.all(10),
        // width: 112,
        // height: 37,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 6),
              child: Icon(
                iconType[valueType],
                color: theme.primaryColor,
                size: 12,
              ),
            ),
            Text(
              textType(context)[valueType] ?? "",
              style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
