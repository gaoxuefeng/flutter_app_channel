import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class LoadingCustom {
  static ProgressDialog _static_pr;
  static int _widgetHashCode;

  static show(BuildContext context) async {
    ProgressDialog progressDialog = _getLoading(context);
    await progressDialog?.show();
  }

  static hide() async {
    print("隐藏");
    if (_static_pr != null) {
      await Future.delayed(Duration(milliseconds: 200));
      await _static_pr.hide();
      _static_pr = null;
      _widgetHashCode = null;
    }
  }

  static ProgressDialog _getLoading(BuildContext context) {
    if (_static_pr != null && _widgetHashCode == context.widget.hashCode) {
      return _static_pr;
    } else {
      if (_static_pr != null) {
        if (_static_pr.isShowing()) {
          _static_pr.hide();
          _static_pr = null;
          _widgetHashCode = null;
        }
      }
      final ProgressDialog pr = ProgressDialog(
        context,
        customBody: _getCustomView(),
        showLogs: true,
      );
      pr.style(backgroundColor: Colors.transparent, elevation: 0);
      _static_pr = pr;
      return pr;
    }
  }

  static Widget _getCustomView() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
        ),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
