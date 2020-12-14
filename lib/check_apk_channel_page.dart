import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_channel/loading_custom.dart';
import 'package:flutter_app_channel/r.dart';
import 'package:flutter_app_channel/utils/cmd_Util.dart';
import 'package:flutter_app_channel/utils/file_util.dart';

/**
 * Created by Gao Xuefeng
 * on 12/11/20
 */
class CheckApkChannelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CheckApkChannelPage();
  }
}

class _CheckApkChannelPage extends State<CheckApkChannelPage> {
  FilePickerCross oriApkPath;
  String channelInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue,
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (_) {
                      Navigator.of(context).pop();
                    },
                    child: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                    "APK渠道验证",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTapDown: (_) async {
                  await LoadingCustom.show(context);
                  await selectApkFile().catchError((onError) async {
                    print(onError);
                    await LoadingCustom.hide();
                  });
                  print("消失loading");
                  await LoadingCustom.hide();
                },
                child: Container(
                  width: 100,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3)),
                  child: Center(
                    child: Text(
                      "请选择APK文件:",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("当前选择APK:${oriApkPath?.path ?? "请选择APK"}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("当前APK渠道:${channelInfo ?? "渠道未知"}"),
            )
          ],
        ),
      ),
    );
  }

  Future selectApkFile() async {
    FilePickerCross myFile = await FilePickerCross.importFromStorage(
            type: FileTypeCross.any, fileExtension: 'apk')
        .catchError((onError) async {
      // print("弹框隐藏1");
      // await LoadingCustom.hide();
    });
    if (myFile != null) {
      oriApkPath = myFile;
      Directory apkRootFile = File(oriApkPath.path).parent;
      File walleFile = await FileUtil.copyAssetJarFile(
          R.jar_walle_cli_all_jar, apkRootFile.path);
      File vasDollyFile =
          await FileUtil.copyAssetJarFile(R.jar_vasdolly_jar, apkRootFile.path);
      String result = await CmdUtil.runCmd("java",
              args: ["-jar", walleFile.path, "show", oriApkPath.path])
          .catchError((onError) {
        channelInfo = "\nWalle渠道:获取错误";
      });
      if (result?.contains("{channel=") == true) {
        channelInfo =
            "\nWalle渠道:${result?.substring(result.lastIndexOf("{channel=")) ?? "未知"}";
      } else {
        channelInfo = "\nWalle渠道:未知";
      }
      String result2 = await CmdUtil.runCmd("java",
              args: ["-jar", vasDollyFile.path, "get", "-c", oriApkPath.path])
          .catchError((onError) {
        channelInfo += "\nVadDolly渠道:获取错误";
      });
      if (result2.contains("Channel:")) {
        channelInfo +=
            "\nVadDolly渠道:${result2.substring(result2.lastIndexOf("Channel:"))}";
      } else {
        channelInfo += "\nVadDolly渠道:未知";
      }
    }

    setState(() {});
  }
}
