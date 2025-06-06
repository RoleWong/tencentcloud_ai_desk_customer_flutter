import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message_receipt.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/tim_uikit_wide_modal_operation_key.dart';
import 'package:tencentcloud_ai_desk_customer/ui/utils/screen_utils.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/message_read_receipt.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/theme/tui_theme.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/wide_popup.dart';

class TIMUIKitMessageReadReceipt extends TIMUIKitStatelessWidget {
  final V2TimMessage messageItem;
  final void Function(String, TapDownDetails tapDetails)? onTapAvatar;

  TIMUIKitMessageReadReceipt({Key? key, this.onTapAvatar, required this.messageItem}) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final TUIChatSeparateViewModel model = Provider.of<TUIChatSeparateViewModel>(context, listen: false);
    final isDesktopScreen = TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;

    return Selector<TCustomerChatGlobalModel, V2TimMessageReceipt?>(
      builder: (context, value, child) {
        if (model.conversationType == ConvType.c2c) {
          bool isPeerRead = false;
          if (value != null) {
            isPeerRead = value.isPeerRead ?? false;
          }
          return Container(
            padding: const EdgeInsets.only(bottom: 3),
            margin: const EdgeInsets.only(right: 6),
            child: Text(
              isPeerRead ? TDesk_t("已读") : TDesk_t("未读"),
              style: TextStyle(color: theme.chatMessageItemUnreadStatusTextColor, fontSize: 12),
            ),
          );
        } else {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if ((value?.readCount ?? 0) > 0) {
                if (isDesktopScreen) {
                  TUIKitWidePopup.showPopupWindow(
                      operationKey: TUIKitWideModalOperationKey.messageReadDetails,
                      context: context,
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.8,
                      title: TDesk_t("消息详情"),
                      child: (onClose) => MessageReadReceipt(
                          model: model,
                          onTapAvatar: onTapAvatar,
                          messageItem: messageItem,
                          unreadCount: value?.unreadCount ?? 0,
                          readCount: value?.readCount ?? 0));
                } else {
                  if (value?.unreadCount == 0) {
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessageReadReceipt(
                              model: model,
                              onTapAvatar: onTapAvatar,
                              messageItem: messageItem,
                              unreadCount: value?.unreadCount ?? 0,
                              readCount: value?.readCount ?? 0)));
                }
              }
            },
            child: Container(
              padding: EdgeInsets.only(bottom: 3, right: 6, left: 6, top: isDesktopScreen ? 2 : 6),
              child: ((value?.unreadCount ?? 0) == 0 && (value?.readCount ?? 0) > 0)
                  ? Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: theme.weakTextColor,
                    )
                  : Container(
                      width: 14,
                      height: 14,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1.3,
                              color: (value?.readCount ?? 0) > 0 ? theme.primaryColor! : theme.weakTextColor!)),
                      child: (value?.readCount ?? 0) > 0
                          ? Text(
                              '${value?.readCount ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 8, color: theme.primaryColor),
                            )
                          : null,
                    ),
            ),
          );
        }
      },
      selector: (c, model) {
        return model.getMessageReadReceipt(messageItem.msgID ?? "");
      },
    );
  }
}
