import 'dart:async';
import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/theme/color.dart';
import 'package:tencentcloud_ai_desk_customer/ui/utils/screen_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_state.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/tencentcloud_ai_desk_customer.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKitTextField/special_text/DefaultSpecialTextSpanBuilder.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/link_preview/link_preview_entry.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/link_preview/models/link_preview_content.dart';

class TIMUIKitTextTranslationElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isFromSelf;
  final bool isShowJump;
  final VoidCallback clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;
  final TUIChatSeparateViewModel chatModel;
  final bool? isShowMessageReaction;
  final List<CustomEmojiFaceData> customEmojiStickerList;

  const TIMUIKitTextTranslationElem(
      {Key? key,
      required this.message,
      required this.isFromSelf,
      required this.isShowJump,
      required this.clearJump,
      this.fontStyle,
      this.borderRadius,
      this.isShowMessageReaction,
      this.backgroundColor,
      this.textPadding,
      required this.chatModel,
      this.customEmojiStickerList = const []})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitTextTranslationElemState();
}

class _TIMUIKitTextTranslationElemState extends TIMUIKitState<TIMUIKitTextTranslationElem> {
  bool isShowJumpState = false;
  bool isShining = false;

  _showJumpColor() {
    if ((widget.chatModel.jumpMsgID != widget.message.msgID) && (widget.message.msgID?.isNotEmpty ?? true)) {
      return;
    }
    isShining = true;
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        isShining = false;
        timer.cancel();
      }
      shineAmount--;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump();
    });
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final isDesktopScreen = TUIKitScreenUtils.getFormFactor(context) == DeviceType.Desktop;
    final borderRadius = widget.isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    if ((widget.chatModel.jumpMsgID == widget.message.msgID)) {}
    if (widget.isShowJump) {
      if (!isShining) {
        Future.delayed(Duration.zero, () {
          _showJumpColor();
        });
      } else {
        if ((widget.chatModel.jumpMsgID == widget.message.msgID) && (widget.message.msgID?.isNotEmpty ?? false)) {
          widget.clearJump();
        }
      }
    }

    final defaultStyle = widget.isFromSelf
        ? (theme.chatMessageItemFromSelfBgColor ??
        theme.lightPrimaryMaterialColor.shade50)
        : (Colors.white);

    final backgroundColor =
        isShowJumpState ? const Color.fromRGBO(245, 166, 35, 1) : (defaultStyle);

    final LocalCustomDataModel localCustomData =
        LocalCustomDataModel.fromMap(json.decode(TencentDeskUtils.checkString(widget.message.localCustomData) ?? "{}"));
    final String? translateText = localCustomData.translatedText;

    final textWithLink = LinkPreviewEntry.getHyperlinksText(
        translateText ?? "", widget.chatModel.chatConfig.isSupportMarkdownForTextMessage,
        onLinkTap: widget.chatModel.chatConfig.onTapLink,
        isUseQQPackage: widget.chatModel.chatConfig.stickerPanelConfig?.useQQStickerPackage ?? true,
        isUseTencentCloudChatPackage:
            widget.chatModel.chatConfig.stickerPanelConfig?.useTencentCloudChatStickerPackage ?? true,
        isUseTencentCloudChatPackageOldKeys:
            widget.chatModel.chatConfig.stickerPanelConfig?.useTencentCloudChatStickerPackageOldKeys ?? false,
        customEmojiStickerList: widget.customEmojiStickerList,
        isEnableTextSelection: widget.chatModel.chatConfig.isEnableTextSelection ?? false);

    return TencentDeskUtils.checkString(translateText) != null
        ? Container(
            margin: const EdgeInsets.only(top: 6),
            padding:
                widget.textPadding ?? EdgeInsets.all(isDesktopScreen ? 12 : 11),
            decoration: BoxDecoration(
              color: (widget.isFromSelf && !isShowJumpState) ? null : backgroundColor,
              gradient: (widget.isFromSelf && !isShowJumpState) ? LinearGradient(
                colors: [hexToColor("009FEF"), hexToColor("006EE1")],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ) : null,
              borderRadius: widget.borderRadius ?? borderRadius,
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If the [elemType] is text message, it will not be null here.
                // You can render the widget from extension directly, with a [TextStyle] optionally.
                widget.chatModel.chatConfig.urlPreviewType != UrlPreviewType.none
                    ? textWithLink!(
                        style: widget.fontStyle ??
                            TextStyle(
                                color: widget.isFromSelf ? Colors.white : null,
                                fontSize: isDesktopScreen ? 14 : 15,
                                textBaseline: TextBaseline.ideographic,
                                height: widget.chatModel.chatConfig.textHeight))
                    : ExtendedText(translateText!,
                        softWrap: true,
                        style: widget.fontStyle ??
                            TextStyle(
                                color: widget.isFromSelf ? Colors.white : null,
                                fontSize: isDesktopScreen ? 14 : 15,
                                height: widget.chatModel.chatConfig.textHeight),
                        specialTextSpanBuilder: DefaultSpecialTextSpanBuilder(
                          isUseQQPackage: widget.chatModel.chatConfig.stickerPanelConfig?.useQQStickerPackage ?? true,
                          isUseTencentCloudChatPackage:
                              widget.chatModel.chatConfig.stickerPanelConfig?.useTencentCloudChatStickerPackage ?? true,
                          isUseTencentCloudChatPackageOldKeys: widget
                                  .chatModel.chatConfig.stickerPanelConfig?.useTencentCloudChatStickerPackageOldKeys ??
                              false,
                          customEmojiStickerList: widget.customEmojiStickerList,
                          showAtBackground: true,
                        )),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0x72282c34),
                      size: 12,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      TDesk_t("翻译完成"),
                      style: const TextStyle(color: Color(0x72282c34), fontSize: 10),
                    )
                  ],
                )
              ],
            ),
          )
        : const SizedBox(width: 0, height: 0);
  }
}
