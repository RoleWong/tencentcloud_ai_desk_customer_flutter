import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_state.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/components/message-form/message-formInput-mobile.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/components/message-form/message-formInput.dart';


class MessageForm extends StatefulWidget {
  final dynamic payload;
  final Function({V2TimMessage? messageInfo}) onClickItem;
  const MessageForm(
      {super.key, required this.payload, required this.onClickItem});
  @override
  State<StatefulWidget> createState() => _MessageFormState();
}

class _MessageFormState extends TIMState<MessageForm> {
  bool showForm = false;

  Widget displayForm() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return MessageFormInputMobile(
          payload: widget.payload, onSubmitForm: widget.onClickItem);
    }
    return MessageFormInput(
        payload: widget.payload, onSubmitForm: widget.onClickItem);
  }

  @override
  Widget timBuild(BuildContext context) {
    return Container(child: displayForm());
  }
}
