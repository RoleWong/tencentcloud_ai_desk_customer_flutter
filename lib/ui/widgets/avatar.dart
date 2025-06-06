import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart'
    if (dart.library.html) 'package:tencent_cloud_chat_sdk/web/compatible_models/v2_tim_user_status.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/ui/utils/common_utils.dart';
import 'package:tencentcloud_ai_desk_customer/ui/widgets/image_screen.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services_implements.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/theme/tui_theme.dart';

class Avatar extends TIMUIKitStatelessWidget {
  final String faceUrl;
  final String showName;
  final bool isFromLocalAsset;
  final TCustomerCoreServicesImpl coreService = serviceLocator<TCustomerCoreServicesImpl>();
  final BorderRadius? borderRadius;
  final V2TimUserStatus? onlineStatus;
  final int? type; // 1 c2c 2 group
  final bool isShowBigWhenClick;
  final TCustomerSelfInfoViewModel selfInfoViewModel =
      serviceLocator<TCustomerSelfInfoViewModel>();

  Avatar(
      {Key? key,
      required this.faceUrl,
      this.onlineStatus,
      required this.showName,
      this.isShowBigWhenClick = false,
      this.isFromLocalAsset = false,
      this.borderRadius,
      this.type = 1})
      : super(key: key);

  Widget getImageWidget(BuildContext context, TUITheme theme) {
    Widget defaultAvatar() {
      if (type == 1) {
        return Image.asset(
            TencentDeskUtils.checkString(
                    selfInfoViewModel.globalConfig?.defaultAvatarAssetPath) ??
                'images/default_c2c_head.png',
            fit: BoxFit.cover,
            package:
                selfInfoViewModel.globalConfig?.defaultAvatarAssetPath != null
                    ? null
                    : 'tencentcloud_ai_desk_customer');
      } else {
        return Image.asset(
            TencentDeskUtils.checkString(
                    selfInfoViewModel.globalConfig?.defaultAvatarAssetPath) ??
                'images/default_group_head.png',
            fit: BoxFit.cover,
            package:
                selfInfoViewModel.globalConfig?.defaultAvatarAssetPath != null
                    ? null
                    : 'tencentcloud_ai_desk_customer');
      }
    }

    // final emptyAvatarBuilder = coreService.emptyAvatarBuilder;
    if (faceUrl != "") {
      if (isFromLocalAsset) {
        return Image.asset(
          faceUrl,
          fit: BoxFit.cover,
        );
      }
      return CachedNetworkImage(
        imageUrl: faceUrl,
        fadeInDuration: const Duration(milliseconds: 0),
        errorWidget: (BuildContext context, String c, dynamic s) {
          return defaultAvatar();
        },
      );
    } else {
      return defaultAvatar();
    }
  }

  ImageProvider getImageProvider() {
    ImageProvider defaultAvatar() {
      if (type == 1) {
        return Image.asset(
                TencentDeskUtils.checkString(selfInfoViewModel
                        .globalConfig?.defaultAvatarAssetPath) ??
                    'images/default_c2c_head.png',
                fit: BoxFit.cover,
                package:
                    selfInfoViewModel.globalConfig?.defaultAvatarAssetPath !=
                            null
                        ? null
                        : 'tencentcloud_ai_desk_customer')
            .image;
      } else {
        return Image.asset(
                TencentDeskUtils.checkString(selfInfoViewModel
                        .globalConfig?.defaultAvatarAssetPath) ??
                    'images/default_group_head.png',
                fit: BoxFit.cover,
                package:
                    selfInfoViewModel.globalConfig?.defaultAvatarAssetPath !=
                            null
                        ? null
                        : 'tencentcloud_ai_desk_customer')
            .image;
      }
    }

    if (faceUrl != "") {
      if (isFromLocalAsset) {
        return Image.asset(faceUrl).image;
      }
      return CachedNetworkImageProvider(
        faceUrl,
      );
    } else {
      return defaultAvatar();
    }
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (isShowBigWhenClick)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false, // set to false
                  pageBuilder: (_, __, ___) => ImageScreen(imageProvider: getImageProvider(), heroTag: faceUrl),
                ),
              );
            },
            child: Hero(
              tag: faceUrl,
              child: ClipRRect(
                borderRadius: borderRadius ??
                    selfInfoViewModel.globalConfig?.defaultAvatarBorderRadius ??
                    BorderRadius.circular(4.8),
                child: getImageWidget(context, theme),
              ),
            ),
          ),
        if (!isShowBigWhenClick)
          ClipRRect(
            borderRadius:
                borderRadius ?? selfInfoViewModel.globalConfig?.defaultAvatarBorderRadius ?? BorderRadius.circular(4.8),
            child: getImageWidget(context, theme),
          ),
        if (onlineStatus?.statusType != null && onlineStatus?.statusType != 0)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                color: onlineStatus?.statusType == 1
                    ? theme.conversationItemOnlineStatusBgColor
                    : theme.conversationItemOfflineStatusBgColor,
              ),
              child: null,
            ),
          ),
      ],
    );
  }
}
