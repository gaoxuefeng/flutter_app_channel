import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_channel/check_apk_channel_page.dart';
import 'package:flutter_app_channel/loading_custom.dart';
import 'package:flutter_app_channel/r.dart';
import 'package:flutter_app_channel/route/animation_route.dart';
import 'package:flutter_app_channel/safe_iterable.dart';
import 'package:flutter_app_channel/utils/CmdUtil.dart';
import 'package:flutter_app_channel/utils/file_util.dart';
import 'package:intl/intl.dart';

/**
 * Created by Gao Xuefeng
 * on 12/3/20
 */
class ChannelBuildHomePage extends StatefulWidget {
  ChannelBuildHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ChannelBuildHomePageState createState() => _ChannelBuildHomePageState();
}

class _ChannelBuildHomePageState extends State<ChannelBuildHomePage> {
  List<ProcessResult> result;
  FilePickerCross oriApkPath;
  String clickTime;
  FilePickerCross channelFile;
  List<String> channelList;
  bool isRunning = false;
  String log = "";
  ScrollController _scrollController;
  int channelBuildType = 0;
  List<String> typeList = ["Walle&VasDolly", "Walle", "VasDolly"];

  @override
  void initState() {
    super.initState();
    log = "正在初始化";
    _scrollController = ScrollController();
    appendLog("初始化完成");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        DropdownButton(
                          value: channelBuildType,
                          onChanged: (value) {
                            setState(() {
                              channelBuildType = value;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(typeList?.elementAt(0)),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(typeList?.elementAt(1)),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(typeList?.elementAt(2)),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTapDown: (_) {
                              Navigator.of(context)
                                  .push(AnimationRoute(CheckApkChannelPage()));
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Text("查看APK渠道"),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Container(
                            child: Text(
                              "当前打包方式:${typeList?.elementAt(channelBuildType)}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(3)),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTapDown: (_) async {
                              appendLog("选择APK文件");
                              await LoadingCustom.show(context);
                              await selectApkFile();
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
                        Text(
                          oriApkPath?.path ?? "请选择APK文件:",
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GestureDetector(
                            onTapDown: (a) async {
                              appendLog("选择渠道文件");
                              await LoadingCustom.show(context);
                              await selectChannelFile();
                              await LoadingCustom.hide();
                            },
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(3)),
                              child: Text(
                                "选择渠道文件:",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                                color: Colors.deepPurpleAccent.withOpacity(0.1),
                                height: 100,
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                // child: Text(channelList?.toString() ?? ""))),
                                child: CustomScrollView(
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Text(channelFile
                                              ?.toString()
                                              ?.replaceAll("\n", "\t||\t") ??
                                          "请选择渠道文件"),
                                    )
                                  ],
                                ))),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              controller: _scrollController,
                              reverse: true,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Text(log ?? ""),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Visibility(
                                  visible: (log?.length ?? 0) > 0,
                                  child: GestureDetector(
                                    onTapDown: (a) {
                                      log = "";
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          "清除log",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTapDown: (_) async {
                                    appendLog("开始打渠道包");
                                    await LoadingCustom.show(context);
                                    await clickAddChannel()
                                        .catchError((onError) async {
                                      appendLog(onError.toString());
                                      await LoadingCustom.hide();
                                    });
                                    await LoadingCustom.hide();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(20),
                                    width: 100,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(
                                      isRunning ? "正在执行" : "开始执行",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  Future selectApkFile() async {
    clickTime = DateTime.now().toString();
    FilePickerCross myFile = await FilePickerCross.importFromStorage(
            type: FileTypeCross.any, fileExtension: 'apk')
        .catchError((onError) async {
      // print("弹框隐藏1");
      // await LoadingCustom.hide();
    });
    if (myFile != null) {
      oriApkPath = myFile;
    }
    setState(() {});
  }

  Future selectChannelFile() async {
    FilePickerCross myFile = await FilePickerCross.importFromStorage(
            type: FileTypeCross.any, fileExtension: "txt")
        .catchError((onError) async {
      appendLog(onError.toString());
    });
    if (myFile != null) {
      channelFile = myFile;
      channelList = channelFile?.toString()?.split("\n");
    }
    setState(() {});
  }

  appendLog(String appendLog) {
    if (log == null) {
      log = appendLog;
    } else {
      log += "\n${appendLog ?? ""}";
    }
    setState(() {
      _scrollController?.animateTo(0.0,
          duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  Future clickAddChannel() async {
    appendLog("开始打包...");

    if (isRunning) {
      appendLog("正在打包中,请稍后");

      return;
    }

    if (oriApkPath == null) {
      appendLog("APK原始文件不存在");
      return;
    }
    if (channelFile == null || (channelList?.length ?? 0) == 0) {
      appendLog("请选择渠道文件");
      return;
    }
    setState(() {
      isRunning = true;
    });
    String packageName =
        "渠道包${(channelBuildType == 0) ? "Walle" : "VasDolly"}${DateFormat("yyyy年M月d日HH点mm分ss秒").format(DateTime.now())}";

    appendLog("当前时间${packageName}");
    String outApkPath =
        "${File(oriApkPath.path).parent.path + "/$packageName/"}";
    int index = 0;
    for (String element in channelList) {
      index++;
      List<String> channelItemInfo = element.split("#");
      String channelName = (channelItemInfo?.safeElementAt(0) ?? "").trim();
      if (channelName.isNotEmpty) {
        String outPutName =
            (channelItemInfo?.safeElementAt(1) ?? channelName).trim();
        if (outPutName.isEmpty) {
          outPutName = channelName;
        }
        String outPutPath = outApkPath +
            oriApkPath.fileName.substring(0, oriApkPath.fileName.length - 4);
        outPutPath += "_${index}_$outPutName.apk";
        if (channelBuildType == 0) {
          await signWalle(channelName, outPutPath);
          await signVasDolly(channelName, outPutPath);
        } else if (channelBuildType == 1) {
          await signWalle(channelName, outPutPath);
        } else if (channelBuildType == 2) {
          await FileUtil.copyFile(oriApkPath.path, outPutPath);
          await signVasDolly(channelName, outPutPath);
        }
      }
    }

    appendLog("打包已完成");
    appendLog("APK输出路径为:$outApkPath");
    await runCmd("open", args: ["$outApkPath"]);
    isRunning = false;
  }

  Future signVasDolly(String channelName, String outPutPath) async {
    File saveJarVasDolly = await FileUtil.copyAssetJarFile(
        R.jar_vasdolly_jar, File(channelFile.path).parent.path);
    await runCmd("java", args: [
      "-jar",
      "${saveJarVasDolly.path}",
      "put",
      "-c",
      "$channelName",
      outPutPath,
      outPutPath
    ]).catchError((onError) {
      File(outPutPath).deleteSync();
    });
  }

  Future signWalle(String channelName, String outPutPath) async {
    File saveJarWalle = await FileUtil.copyAssetJarFile(
        R.jar_walle_cli_all_jar, File(channelFile.path).parent.path);
    // File saveJarWalle = await copyAssetJarFile(R.jar_walle_cli_all_jar);

    await runCmd("java", args: [
      "-jar",
      "${saveJarWalle.path}",
      "put",
      "-c",
      "$channelName",
      "${oriApkPath.path}",
      outPutPath
    ]);
  }

  @override
  void reassemble() {
    super.reassemble();
    appendLog("页面热重载");
  }

  Future<String> runCmd(String s, {List<String> args}) async {
    await Cmdutil.runCmd(s, args: args, appendLog: (addLog) {
      appendLog(addLog);
    });
    setState(() {
      _scrollController?.animateTo(0.0,
          duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }
}
