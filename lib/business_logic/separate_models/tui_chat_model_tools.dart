import 'dart:io';

import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services_implements.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';

class TCustomerChatModelTools {
  final TCustomerChatGlobalModel globalModel = serviceLocator<TCustomerChatGlobalModel>();
  final TCustomerCoreServicesImpl _coreServices = serviceLocator<TCustomerCoreServicesImpl>();

  OfflinePushInfo buildMessagePushInfo(V2TimMessage message, String convID, ConvType convType) {
    String createJSON(String convID) {
      return "{\"conversationID\": \"$convID\"}";
    }

    if (globalModel.chatConfig.offlinePushInfo != null) {
      final customData = globalModel.chatConfig.offlinePushInfo!(message, convID, convType);
      if (customData != null) {
        return customData;
      }
    }

    String title = globalModel.chatConfig.notificationTitle;

    // If user provides null, use default ext.
    String ext = globalModel.chatConfig.notificationExt != null
        ? globalModel.chatConfig.notificationExt!(message, convID, convType) ??
            (convType == ConvType.c2c ? createJSON("c2c_${message.sender}") : createJSON("group_$convID"))
        : (convType == ConvType.c2c ? createJSON("c2c_${message.sender}") : createJSON("group_$convID"));

    String desc = message.userID ?? message.groupID ?? "";
    String messageSummary = "";
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        messageSummary = TDesk_t("自定义消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        messageSummary = TDesk_t("表情消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        messageSummary = TDesk_t("文件消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        messageSummary = TDesk_t("群提示消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        messageSummary = TDesk_t("图片消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        messageSummary = TDesk_t("位置消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        messageSummary = TDesk_t("合并转发消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        messageSummary = TDesk_t("语音消息");
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        messageSummary = message.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        messageSummary = TDesk_t("视频消息");
        break;
    }

    if (globalModel.chatConfig.notificationBody != null) {
      desc = globalModel.chatConfig.notificationBody!(message, convID, convType) ?? messageSummary;
    } else {
      desc = messageSummary;
    }

    return OfflinePushInfo(
      title: title,
      desc: desc,
      disablePush: false,
      ext: ext,
      iOSSound: globalModel.chatConfig.notificationIOSSound,
      androidSound: globalModel.chatConfig.notificationAndroidSound,
      ignoreIOSBadge: false,
      androidOPPOChannelID: globalModel.chatConfig.notificationOPPOChannelID,
      androidVIVOClassification: 1,
    );
  }

  V2TimMessage setUserInfoForMessage(V2TimMessage messageInfo, String? id) {
    final loginUserInfo = _coreServices.loginUserInfo;
    if (loginUserInfo != null) {
      messageInfo.faceUrl = loginUserInfo.faceUrl;
      messageInfo.nickName = loginUserInfo.nickName;
      messageInfo.sender = loginUserInfo.userID;
    }
    messageInfo.timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).ceil();
    messageInfo.isSelf = true;
    messageInfo.id = id;

    return messageInfo;
  }

  String getMessageSummary(V2TimMessage message, String? Function(V2TimMessage message)? abstractMessageBuilder) {
    final String? customAbstractMessage = abstractMessageBuilder != null ? abstractMessageBuilder(message) : null;
    if (customAbstractMessage != null) {
      return customAbstractMessage;
    }

    final elemType = message.elemType;
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return "[表情消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return "[自定义消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return "[文件消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return "[群消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return "[图片消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return "[位置消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return "[合并消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        return "[没有元素]";
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return "[语音消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem?.text ?? "[文本消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return "[视频消息]";
      default:
        return "";
    }
  }

  String getMessageAbstract(V2TimMessage message,
      String? Function(V2TimMessage message)? abstractMessageBuilder) {
    // final messageAbstract = RepliedMessageAbstract(
    //     summary: TDesk_t(getMessageSummary(message, abstractMessageBuilder)),
    //     elemType: message.elemType,
    //     msgID: message.msgID,
    //     timestamp: message.timestamp,
    //     seq: message.seq);
    return TDesk_t(getMessageSummary(message, abstractMessageBuilder));
  }

  Future<V2TimMessage?> getExistingMessageByID(
      {required String msgID, required String conversationID, required ConvType conversationType}) async {
    final currentHistoryMsgList = globalModel.messageListMap[conversationID] ?? [];
    final int? targetIndex = currentHistoryMsgList.indexWhere((item) {
      return item.msgID == msgID;
    });

    if (targetIndex != null && targetIndex > -1 && currentHistoryMsgList.isNotEmpty) {
      return currentHistoryMsgList[targetIndex];
    } else {
      return null;
    }
  }

  Future<bool> hasZeroSize(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();
      return fileSize == 0;
    } catch (e) {
      return false;
    }
  }
}
