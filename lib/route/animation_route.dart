import 'package:flutter/material.dart';

/// Created by Gao Xuefeng
/// on 2020/11/3
class AnimationRoute extends PageRouteBuilder {
  final Widget widget;
  AnimEnum? animEnum;
  bool isDialog = false;
  bool canAutoCancel = true;

  //构造方法
  AnimationRoute(this.widget,
      {this.animEnum = AnimEnum.leftInRightOut,
      this.isDialog = false,
      this.canAutoCancel = true})
      : super(
            opaque: !isDialog,
            transitionDuration: Duration(milliseconds: 500), //过渡时间
            pageBuilder: (
              //构造器
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
            ) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              if (animEnum != null) {
                switch (animEnum) {
                  case AnimEnum.leftInRightOut:
                    return rightInLeftOutAnim(animation1, child);
                  case AnimEnum.bottomInAndOut:
                    {
                      if (isDialog) {
                        return dialogBottomInAndOut(
                            animation1, child, canAutoCancel);
                      }
                      return bottomInAndOut(animation1, child);
                    }
                }
              }

              return rightInLeftOutAnim(animation1, child);
            });

  static SlideTransition rightInLeftOutAnim(
      Animation<double> animation1, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animation1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }

  static Widget bottomInAndOut(Animation<double> animation1, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 1), end: Offset(0.0, 0.0))
          .animate(
              CurvedAnimation(parent: animation1, curve: Curves.fastOutSlowIn)),
      child: child,
    );
  }

  static Widget dialogBottomInAndOut(
      Animation<double> animation1, Widget child, bool canAutoCancel) {
    return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black.withOpacity(0.4),
        child: CancelGestureDetector(
            canAutoCancel: canAutoCancel,
            child: bottomInAndOut(animation1, child)));
  }
}

enum AnimEnum { leftInRightOut, bottomInAndOut }

class CancelGestureDetector extends StatelessWidget {
  final bool canAutoCancel;
  final Widget child;

  CancelGestureDetector({required this.child, this.canAutoCancel = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
          onTap: () {
            print("点击内容区");
          },
          behavior: HitTestBehavior.deferToChild,
          child: child),
      onTap: () {
        print("点击消失");
        if (canAutoCancel == true) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
