import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_channel/r.dart';
import 'package:flutter_app_channel/utils/cmd_Util.dart';
import 'package:flutter_app_channel/utils/file_util.dart';
import 'package:flutter_app_channel/utils/loading_dialog.dart';

/// Created by Gao Xuefeng
/// on 12/11/20
class CheckApkChannelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CheckApkChannelPage();
  }
}

class _CheckApkChannelPage extends State<CheckApkChannelPage> {
  FilePickerResult? oriApkPath;
  String? channelInfo;

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
                    "APK渠道/签名验证",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTapDown: (_) async {
                  LoadingDialog.showLoading((cancelToken) async {
                    await selectApkFile();
                  });
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
              child:
                  Text("当前选择APK:${oriApkPath?.files.first.path ?? "请选择APK"}"),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                    child: Text("当前APK渠道:${channelInfo ?? "渠道未知"}")),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future selectApkFile() async {
    FilePickerResult? myFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["apk"]);
    oriApkPath = myFile;
    File walleFile = await FileUtil.copyAssetJarFile(
        R.jar_walle_cli_all_jar, await FileUtil.getRootFile());
    File vasDollyFile = await FileUtil.copyAssetJarFile(
        R.jar_vasdolly_jar, await FileUtil.getRootFile());
    String result = await CmdUtil.runCmd("java", args: [
      "-jar",
      walleFile.path,
      "show",
      oriApkPath?.files.first.path ?? ""
    ]).catchError((onError) {
      channelInfo = "\nWalle渠道:获取错误";
    });
    if (result.contains("{channel=") == true) {
      channelInfo =
          "\nWalle渠道:${result.substring(result.lastIndexOf("{channel="))}";
    } else {
      channelInfo = "\nWalle渠道:未知";
    }
    String result2 = await CmdUtil.runCmd("java", args: [
      "-jar",
      vasDollyFile.path,
      "get",
      "-c",
      oriApkPath?.files.first.path ?? ""
    ]).catchError((onError) {
      channelInfo = (channelInfo ?? "") + "\nVasDolly渠道:获取错误";
    });
    if (result2.contains("Channel:")) {
      channelInfo = (channelInfo ?? "") +
          "\nVadDolly渠道:${result2.substring(result2.lastIndexOf("Channel:"))}";
    } else {
      channelInfo = (channelInfo ?? "") + "\nVasDolly渠道:未知";
    }

    // apksigner verify -v -print-certs
    await FileUtil.copyAssetJarFile(
        "jar/apksigner.jar", await FileUtil.getRootFile());
    File apkSigner = await FileUtil.copyAssetJarFile(
        R.command_apk_sign, await FileUtil.getRootFile());
    String result3 = await CmdUtil.runCmd(apkSigner.path, args: [
      "verify",
      "-v",
      "-print-certs",
      oriApkPath?.files.first.path ?? ""
    ]).catchError((onError) {
      channelInfo = (channelInfo ?? "") + "\n签名信息:获取错误";
    });
    channelInfo = (channelInfo ?? "") + "\n签名信息:\n" + result3;
    setState(() {});
  }
}
