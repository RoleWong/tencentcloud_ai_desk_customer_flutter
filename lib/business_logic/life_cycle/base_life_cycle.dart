import 'package:flutter/cupertino.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_value_callback.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_class.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_callback.dart';

typedef MessageFunction = Future<V2TimMessage?> Function(V2TimMessage message);

typedef MessageFunctionNullCallback = Function(V2TimValueCallback<V2TimMessage> res);

typedef MessageFunctionOptional = Future<V2TimMessage?> Function(V2TimMessage message);

typedef MessageListFunction = Future<List<V2TimMessage>> Function(List<V2TimMessage> messageList);

typedef MessageListFunctionAsync = List<V2TimMessage> Function(List<V2TimMessage> messageList);

typedef FutureBool = Future<bool>;

typedef AddFriendFunction = Function(String userID, String? remark, String? friendGroup, String? addWording);

typedef ConversationListFunction = Future<List<V2TimConversation?>> Function(List<V2TimConversation?> conversationList);

typedef FriendListFunction = Future<List<V2TimFriendInfo>> Function(List<V2TimFriendInfo> friendList);

typedef FriendInfoFunction = Future<V2TimFriendInfo?> Function(V2TimFriendInfo? friendInfo);

/// Here is the default life cycle hooks implementation for all the hooks in TUIKit.
abstract class DefaultLifeCycle {
  static Future<List<V2TimConversation?>> defaultConversationListSolution(List<V2TimConversation?> list) async {
    return list;
  }

  static Future<List<V2TimFriendInfo>> defaultFriendListSolution(List<V2TimFriendInfo> list) async {
    return list;
  }

  static Future<V2TimMessage> defaultMessageSolution(V2TimMessage message) async {
    return message;
  }

  static Future<V2TimMessage> defaultTwoMessagesSolution(V2TimMessage message, [V2TimMessage? repliedMessage]) async {
    return message;
  }

  static Future<List<V2TimMessage>> defaultMessageListSolution(List<V2TimMessage> list) async {
    return list;
  }

  static List<V2TimMessage> defaultMessageListSolutionAsync(List<V2TimMessage> list) {
    return list;
  }

  static Future<bool> defaultAsyncBooleanSolution(dynamic) async {
    return true;
  }

  static bool defaultBooleanSolution(dynamic) {
    return true;
  }

  static defaultNullCallbackSolution(dynamic) {}

  static Future<bool> defaultAddFriend(String userID, String? remark, String? friendGroup, String? addWording,
      [BuildContext? context]) async {
    return true;
  }

  static Future<bool> defaultAddGroup(String groupID, String message, [BuildContext? context]) async {
    return true;
  }

  static Future<V2TimFriendInfo?> defaultFriendInfoSolution(V2TimFriendInfo? friendInfo) async {
    return friendInfo;
  }

  static Future<void> defaultPopBackRemind() async {
    // You have to implement the exact life cycle hook in this case.
    TIMUIKitClass.onTIMCallback(TIMCallback(type: TIMCallbackType.INFO, infoRecommendText: TDesk_t("请传入离开群组生命周期函数，提供返回首页或其他页面的导航方法。"), infoCode: 6661402));
    return;
  }
}
