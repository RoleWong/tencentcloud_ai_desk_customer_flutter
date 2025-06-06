import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_callback.dart';


abstract class TIMState<T extends StatefulWidget> extends State<T> {
  @override
  initState() {
    super.initState();
  }

  // override这个函数来承接处理onTIMCallback回调。
  // 目前base层，会自动触发`TIMCallbackType.FLUTTER_ERROR`类型Flutter Framework异常。
  // 其他类型callback请自行处理。
  void onTIMCallback(TIMCallback callbackValue) {
    // TODO: 这里后续看看要不要默认加上报逻辑。
  }

  bool isAndroidDevice(){
    return !kIsWeb && Platform.isAndroid;
  }

  bool isIosDevice(){
    return !kIsWeb && Platform.isIOS;
  }

  bool isWebDevice(){
    return kIsWeb;
  }

  setTIMState(VoidCallback fn){

  }
  
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      onTIMCallback(TIMCallback(
          type: TIMCallbackType.FLUTTER_ERROR,
          stackTrace: details.stack,
          errorMsg: "Error from Flutter"));
    };

    return timBuild(context);
  }

  // 请override这个方法来render界面
  Widget timBuild(BuildContext context);
}
