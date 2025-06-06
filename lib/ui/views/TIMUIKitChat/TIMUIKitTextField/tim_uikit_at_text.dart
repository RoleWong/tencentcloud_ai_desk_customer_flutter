import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_state.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/ui/utils/screen_utils.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/group_member_list.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/theme/tui_theme.dart';

class AtText extends StatefulWidget {
  final String? groupID;
  final V2TimGroupInfo? groupInfo;
  final List<V2TimGroupMemberFullInfo?>? groupMemberList;
  final VoidCallback? closeFunc;
  final Function(List<V2TimGroupMemberFullInfo> memberInfo)? onChooseMember;
  final bool canAtAll;

  // some Group type cant @all
  final String? groupType;

  const AtText({
    this.groupID,
    this.groupType,
    Key? key,
    this.groupInfo,
    this.groupMemberList,
    this.closeFunc,
    this.onChooseMember,
    this.canAtAll = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AtTextState();
}

class _AtTextState extends TIMUIKitState<AtText> {
  final TCustomerSelfInfoViewModel _selfInfoViewModel = serviceLocator<TCustomerSelfInfoViewModel>();

  List<V2TimGroupMemberFullInfo?>? groupMemberList;
  List<V2TimGroupMemberFullInfo?>? searchMemberList;

  List<V2TimGroupMemberFullInfo> selectedGroupMemberList = [];

  @override
  void initState() {
    groupMemberList = widget.groupMemberList;
    searchMemberList = groupMemberList;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _submitAtMemberList() {
    if (widget.closeFunc != null) {
      widget.closeFunc!();
    }

    if (widget.onChooseMember != null) {
      widget.onChooseMember!(selectedGroupMemberList);
    } else {
      Navigator.pop(context, selectedGroupMemberList);
    }
  }

  bool isSearchTextExist(String? searchText) {
    return searchText != null && searchText != "";
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    V2TimUserFullInfo? loginUserInfo = _selfInfoViewModel.loginInfo;
    if (loginUserInfo != null) {
      searchMemberList?.removeWhere((memberInfo) {
        return memberInfo?.userID == loginUserInfo.userID;
      });
    }

    Widget mentionedMembersBody() {
      return GroupProfileMemberList(
          groupType: widget.groupType ?? "",
          memberList: searchMemberList ?? [],
          canAtAll: widget.canAtAll,
          canSelectMember: true,
          canSlideDelete: false,
          onSelectedMemberChange: (selectedMemberList) {
            selectedGroupMemberList = selectedMemberList;
            bool isAtAllSelected = selectedGroupMemberList.where((element) {
              return element.userID == GroupProfileMemberList.AT_ALL_USER_ID;
            }).isNotEmpty;

            if (isAtAllSelected) {
              _submitAtMemberList();
            }
          },
          touchBottomCallBack: () {
            // Get all by once, unnecessary to load more
          },
          customTopArea: null);
    }

    return TUIKitScreenUtils.getDeviceWidget(
        context: context,
        desktopWidget: mentionedMembersBody(),
        defaultWidget: Scaffold(
            appBar: AppBar(
              shadowColor: theme.weakBackgroundColor,
              iconTheme: IconThemeData(
                color: theme.appbarTextColor,
              ),
              backgroundColor: theme.appbarBgColor ?? theme.primaryColor,
              leading: Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(left: 16),
                    constraints: const BoxConstraints(),
                    icon: Image.asset(
                      'images/arrow_back.png',
                      package: 'tencentcloud_ai_desk_customer',
                      height: 34,
                      width: 34,
                      color: theme.appbarTextColor,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              centerTitle: true,
              leadingWidth: 100,
              title: Text(
                TDesk_t("选择提醒人"),
                style: TextStyle(
                  color: theme.appbarTextColor,
                  fontSize: 17,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _submitAtMemberList();
                  },
                  child: Text(
                   TDesk_t("确定"),
                    style: TextStyle(
                      color: theme.appbarTextColor,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
            body: mentionedMembersBody()));
  }
}
