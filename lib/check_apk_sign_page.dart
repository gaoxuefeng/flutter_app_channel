import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_channel/r.dart';
import 'package:flutter_app_channel/utils/cmd_Util.dart';
import 'package:flutter_app_channel/utils/file_util.dart';
import 'package:flutter_app_channel/utils/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Created by Gao Xuefeng
/// on 12/11/20
class ApkSignPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ApkSignPage();
  }
}

class _ApkSignPage extends State<ApkSignPage> {
  FilePickerResult? oriApkPath;
  File? oriJKSPath;
  String signResultInfo = "";
  TextEditingController keyStorePasswordController = TextEditingController();
  TextEditingController keyAliasController = TextEditingController();
  TextEditingController keyPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    final prefs = await SharedPreferences.getInstance();
    keyStorePasswordController.text =
        prefs.getString("keyStorePasswordController") ?? "";
    keyAliasController.text = prefs.getString("keyAliasController") ?? "";
    keyPasswordController.text = prefs.getString("keyPasswordController") ?? "";
    var jksFile = prefs.getString("oriJKSPath");
    if (jksFile != null && new File(jksFile).existsSync() == true) {
      oriJKSPath = File(jksFile);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
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
                    "APK签名",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTapDown: (_) async {
                      LoadingDialog.showLoading((cancelToken) async {
                        await selectApkFile();
                      });
                    },
                    child: Container(
                      width: 200,
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
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTapDown: (_) async {
                      await startSignApk();
                    },
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(3)),
                      child: Center(
                        child: Text(
                          "开始签名",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text("当前选择APK:${oriApkPath?.files.first.path ?? "请选择APK"}"),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTapDown: (_) async {
                  LoadingDialog.showLoading((cancelToken) async {
                    await selectJksFile();
                  });
                },
                child: Container(
                  width: 200,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(3)),
                  child: Center(
                    child: Text(
                      "请选择JKS文件:",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("当前选择JKS:${oriJKSPath?.path ?? "请选择JKS"}"),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: keyStorePasswordController,
                      decoration: InputDecoration(
                          labelText: "keyStorePassword:",
                          labelStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: keyAliasController,
                      decoration: InputDecoration(
                          labelText: "keyAlias:",
                          labelStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: keyPasswordController,
                      decoration: InputDecoration(
                          labelText: "keyPassword:",
                          labelStyle: TextStyle(color: Colors.black)),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("当前签名信息:\n" + signResultInfo),
            )
          ],
        ),
      ),
    );
  }

  Future selectApkFile() async {
    FilePickerResult? myFile = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ["apk"], allowMultiple: true);
    oriApkPath = myFile;
    setState(() {});
  }

  Future selectJksFile() async {
    FilePickerResult? myFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ["jks"]);
    var file = myFile?.files.first.path;
    if (file != null) {
      oriJKSPath = File(file);
    }

    setState(() {});
  }

  startSignApk() async {
    bool isFailure = false;
    if (oriApkPath == null || oriApkPath!.files.isEmpty) {
      isFailure = true;
      signResultInfo = "请选择APK路径";
    }

    if (oriJKSPath == null && !isFailure) {
      isFailure = true;
      signResultInfo = "请选择JKS路径";
    }
    if (keyStorePasswordController.text.isEmpty && !isFailure) {
      isFailure = true;
      signResultInfo = "请输入Store密码";
    }
    if (keyAliasController.text.isEmpty && !isFailure) {
      isFailure = true;
      signResultInfo = "请输入Alias别名";
    }
    if (keyPasswordController.text.isEmpty && !isFailure) {
      isFailure = true;
      signResultInfo = "请输入密码";
    }
    if (isFailure) {
      setState(() {});
      return;
    }
    List<PlatformFile> apkFiles = oriApkPath!.files;
    signResultInfo = "开始签名,共:${apkFiles.length}个apk";
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "keyStorePasswordController", keyStorePasswordController.text);
    prefs.setString("keyAliasController", keyAliasController.text);
    prefs.setString("keyPasswordController", keyPasswordController.text);
    prefs.setString("oriJKSPath", oriJKSPath?.path ?? "");
    await FileUtil.copyAssetJarFile(
        "jar/apksigner.jar", await FileUtil.getRootFile());
    File apkSigner = await FileUtil.copyAssetJarFile(
        R.command_apk_sign, await FileUtil.getRootFile());
    await LoadingDialog.showLoading((cancelToken) async {
      var index = 0;
      for (PlatformFile apkItem in apkFiles) {
        index++;
        var apkFile = new File(apkItem.path ?? "");
        var saveFile = new File(
            apkFile.parent.path + "/" + "${index}_signed_" + apkItem.name);
        signResultInfo += "开始签名第${index}:${apkFile.path}";
        String? result = await CmdUtil.runCmd(apkSigner.path, args: [
          "sign",
          "--ks",
          oriJKSPath?.path ?? "",
          "--ks-key-alias",
          keyAliasController.text,
          "--key-pass",
          "pass:${keyPasswordController.text}",
          "--ks-pass",
          "pass:${keyStorePasswordController.text}",
          // "--v1-signing-enabled",
          // "true",
          // "--v2-signing-enabled",
          // "true",
          // "--v3-signing-enabled",
          // "true",
          "--v4-signing-enabled",
          "false",
          "--in",
          apkFile.path,
          "--out",
          saveFile.path
        ]);
        signResultInfo += "\n签名结果:${saveFile.path}:${result ?? ""}";
        sleep(Duration(seconds: 1));
        if (saveFile.existsSync()) {
          signResultInfo += "\n签名成功:${index}";
          print("打开结果:${index == apkFiles.length}");
          if (index == apkFiles.length) {
            signResultInfo += "\n签名已结束";
            if (Platform.isMacOS) {
              print("打开结果路径:" + saveFile.parent.path);
              await CmdUtil.runCmd("open", args: [saveFile.parent.path]);
            } else if (Platform.isWindows) {
              print("打开结果路径:" + saveFile.parent.path);
              await CmdUtil.runCmd("explorer", args: [saveFile.parent.path]);
            }
          }
        } else {
          signResultInfo += "\n签名失败,请检测文件:${index}";
          signResultInfo += "\n停止签名";
          break;
        }
        setState(() {});
      }
    });
  }
}
