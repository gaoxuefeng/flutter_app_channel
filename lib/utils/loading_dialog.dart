import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_channel/error/toast_exception.dart';
import 'package:get/get.dart';

typedef LoadingFunction = Future<dynamic> Function(CancelToken cancelToken);

/// Created by Gao Xuefeng
/// on 2021/7/21
///
class LoadingDialog extends StatefulWidget {
  /// 默认是catchError的,需要的可以改为不CatchError的
  static Future<dynamic> showLoading(LoadingFunction loadingFun,
      {bool isCatchError = false, bool touchCancelAble = false}) async {
    var result = await Get.dialog(
        LoadingDialog(loadingFun, isCatchError, touchCancelAble));
    if (result is Exception) {
      if (isCatchError) {
        print(result);
      } else {
        throw result;
      }
    } else {
      return result;
    }
  }

  final LoadingFunction loadingFun;
  final bool isCatchError;
  final bool touchCancelAble;
  final CancelToken cancelToken = CancelToken();

  LoadingDialog(this.loadingFun, this.isCatchError, this.touchCancelAble);

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  late CancelableOperation cancellableOperation;
  static const CANCEL_CODE = "333333";

  @override
  void initState() {
    super.initState();
    cancellableOperation = CancelableOperation.fromFuture(
      widget.loadingFun(widget.cancelToken),
      onCancel: () => {widget.cancelToken.cancel("cancel handler")},
    );
    startRunFun();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!cancellableOperation.isCanceled) {
          cancellableOperation.cancel();
          dismiss(ToastException(CANCEL_CODE, null, "cancel handler"));
          return false;
        }
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.touchCancelAble) {
            if (!cancellableOperation.isCanceled) {
              cancellableOperation.cancel();
              dismiss(ToastException(CANCEL_CODE, null, "cancel handler"));
            }
          }
        },
        child: Container(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(18)),
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future startRunFun() async {
    cancellableOperation.value.then((event) {
      debugPrint("结果:$event");
      dismiss(event);
    }).catchError((onError) {
      debugPrint("是否手动取消:${cancellableOperation.isCanceled} ");
      debugPrint("结果onError:$onError");
      dismiss(onError);
    });
  }

  dismiss([dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }
}
