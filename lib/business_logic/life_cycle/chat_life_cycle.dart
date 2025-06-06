import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/life_cycle/base_life_cycle.dart';

class ChatLifeCycle {
  /// Before a new message will be added to historical message list from long connection.
  /// You may not render this message by return null.
  MessageFunctionOptional newMessageWillMount;

  /// Before a modified message updated to historical message list UI.
  MessageFunction modifiedMessageWillMount;

  /// Before a new message will be sent.
  /// Returns null can block the message from sending.
  // Future<V2TimMessage?> Function(V2TimMessage message, [V2TimMessage? repliedMessage]) messageWillSend;

  /// After a new message been sent.
  MessageFunctionNullCallback messageDidSend;

  /// After getting the latest message list from API,
  /// and before historical message list will be rendered.
  /// You may add or delete some messages here.
  MessageListFunction didGetHistoricalMessageList;

  /// Before deleting a message from historical message list,
  /// `true` means can delete continually, while `false` will not delete.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String msgID) shouldDeleteMessage;

  /// Before clearing the historical message list,
  /// `true` means can clear continually, while `false` will not clear.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String conversationID) shouldClearHistoricalMessageList;

  /// Before rendering a message to message list.
  bool Function(V2TimMessage msg) messageShouldMount;

  /// Before all message will be rendered on the message list.
  /// You may add or delete some messages here.
  MessageListFunctionAsync messageListShouldMount;

  ChatLifeCycle({
    this.shouldClearHistoricalMessageList = DefaultLifeCycle.defaultAsyncBooleanSolution,
    this.shouldDeleteMessage = DefaultLifeCycle.defaultAsyncBooleanSolution,
    this.messageDidSend = DefaultLifeCycle.defaultNullCallbackSolution,
    this.didGetHistoricalMessageList = DefaultLifeCycle.defaultMessageListSolution,
    // this.messageWillSend = DefaultLifeCycle.defaultTwoMessagesSolution,
    this.modifiedMessageWillMount = DefaultLifeCycle.defaultMessageSolution,
    this.newMessageWillMount = DefaultLifeCycle.defaultMessageSolution,
    this.messageShouldMount = DefaultLifeCycle.defaultBooleanSolution,
    this.messageListShouldMount = DefaultLifeCycle.defaultMessageListSolutionAsync,
  });
}
