import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/ui/utils/common_utils.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_state.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_show_panel.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';

class TIMUIKitMessageReactionWrapper extends StatefulWidget {
  final Widget child;
  final V2TimMessage message;
  final Color? backgroundColor;
  final bool isFromSelf;
  final BorderRadius? borderRadius;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final bool isShowMessageReaction;
  final TUIChatSeparateViewModel chatModel;

  const TIMUIKitMessageReactionWrapper(
      {Key? key,
      required this.isShowJump,
      this.clearJump,
      required this.isFromSelf,
      this.backgroundColor,
      required this.chatModel,
      required this.message,
      this.borderRadius,
      required this.child,
      this.isShowMessageReaction = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitMessageReactionWrapperState();
}

class _TIMUIKitMessageReactionWrapperState extends TIMUIKitState<TIMUIKitMessageReactionWrapper> {
  bool isShowJumpState = false;
  bool isShining = false;
  bool isShowBorder = false;

  _showJumpColor() {
    if ((widget.chatModel.jumpMsgID != widget.message.msgID) && (widget.message.msgID?.isNotEmpty ?? true)) {
      return;
    }
    isShining = true;
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
      isShowBorder = true;
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
          isShowBorder = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        isShining = false;
        timer.cancel();
      }
      shineAmount--;
    });
    if (widget.clearJump != null) {
      widget.clearJump!();
    }
  }

  bool isHaveMessageReaction() {
    Map<String, dynamic> messageReaction = {};
    CloudCustomData messageCloudCustomData;
    try {
      messageCloudCustomData = CloudCustomData.fromJson(json.decode(
          TencentDeskUtils.checkString(widget.message.cloudCustomData) != null
              ? widget.message.cloudCustomData!
              : "{}"));
    } catch (e) {
      messageCloudCustomData = CloudCustomData();
    }

    if (messageCloudCustomData.messageReaction != null && messageCloudCustomData.messageReaction!.isNotEmpty) {
      messageReaction = messageCloudCustomData.messageReaction!;
    } else {
      return false;
    }

    final List<int> messageReactionStickerList = [];

    messageReaction.forEach((key, value) {
      messageReactionStickerList.add(int.parse(key));
    });

    final filteredMessageReactionStickerList = messageReactionStickerList.where((sticker) {
      if (messageReaction[sticker.toString()] == null ||
          messageReaction[sticker.toString()] is! List ||
          messageReaction[sticker.toString()].length == 0) {
        return false;
      }
      return true;
    });

    if (filteredMessageReactionStickerList.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
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

    if (widget.isShowJump) {
      if (!isShining) {
        Future.delayed(Duration.zero, () {
          _showJumpColor();
        });
      } else {
        if ((widget.chatModel.jumpMsgID == widget.message.msgID) && (widget.message.msgID?.isNotEmpty ?? false)) {
          if (widget.clearJump != null) {
            widget.clearJump!();
          }
        }
      }
    }

    final defaultStyle = widget.isFromSelf ? theme.lightPrimaryMaterialColor.shade50 : theme.weakBackgroundColor;
    final backgroundColor =
        isShowJumpState ? const Color.fromRGBO(245, 166, 35, 1) : (widget.backgroundColor ?? defaultStyle);

    if (!widget.isShowMessageReaction || !isHaveMessageReaction()) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Color.fromRGBO(245, 166, 35, (isShowBorder ? 1 : 0)), width: 2)),
        child: widget.child,
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: widget.borderRadius ?? borderRadius,
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Color.fromRGBO(245, 166, 35, (isShowBorder ? 1 : 0)), width: 2)),
            child: widget.child,
          ),
          if (widget.isShowMessageReaction) TIMUIKitMessageReactionShowPanel(message: widget.message)
        ],
      ),
    );
  }
}
