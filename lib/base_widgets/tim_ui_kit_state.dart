import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services_implements.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_callback.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_state.dart';
import 'package:tencentcloud_ai_desk_customer/theme/tui_theme_view_model.dart';

class TIMUIKitState<T extends StatefulWidget> extends TIMState<T> {
  final TCustomerCoreServicesImpl _coreServices = serviceLocator<TCustomerCoreServicesImpl>();


  @override
  void onTIMCallback(TIMCallback callbackValue) {
    super.onTIMCallback(callbackValue);
    _coreServices.callOnCallback(callbackValue);
  }

  @override
  Widget timBuild(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: serviceLocator<TUIThemeViewModel>()),
      ],
      builder: (BuildContext context, Widget? w) {
        final theme = Provider.of<TUIThemeViewModel>(context).theme;
        final value = TUIKitBuildValue(theme: theme);
        return tuiBuild(context, value);
      },
    );
  }

  @required
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return Container();
  }
}
