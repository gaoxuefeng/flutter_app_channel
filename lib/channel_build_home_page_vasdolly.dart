import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_channel/loading_custom.dart';
import 'package:flutter_app_channel/r.dart';
import 'package:intl/intl.dart';
import 'package:process_runner/process_runner.dart';

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
  ProcessRunner processRunner;

  @override
  void initState() {
    super.initState();
    log = "正在初始化";
    _scrollController = ScrollController();
    processRunner = ProcessRunner();
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
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Text(
                            "当前打包方式:walle",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) {},
                          child: Container(
                            child: Text(
                              "切换到VasDolly",
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
                    Text(
                      "walle",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                      child: CustomScrollView(
                        controller: _scrollController,
                        reverse: true,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Text(log ?? ""),
                          )
                        ],
                      ),
                    )
                  ],
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
                                borderRadius: BorderRadius.circular(10)),
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
                          await clickAddChannel();
                          await LoadingCustom.hide();
                        },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          width: 100,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Text(
                            isRunning ? "正在执行" : "开始执行",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                        ),
                      ),
                    ],
                  ),
                )
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
      channelList = channelFile?.toString()?.split("/n");
    }
    setState(() {});
  }

  Future runCmd2(String cmd,
      {List<String> args, bool isCreateNew = false}) async {
    if (isCreateNew == true) {
      processRunner = ProcessRunner();
    }
    appendLog("\n-------------------$cmd-${args?.toString() ?? ""}--");
    print("\n-------------------$cmd-${args?.toString() ?? ""}--");
    List<String> list = List();
    list.add(cmd);
    if ((args?.length ?? 0) > 0) {
      list.addAll(args);
    }
    ProcessRunnerResult result = await processRunner
        .runProcess(
      list,
      printOutput: true,
    )
        .catchError((onError) {
      appendLog("错误日志:${onError?.toString() ?? ""}");

      print(onError?.toString() ?? "");
    });
    print('stdout: ${result?.stdout ?? ""}');
    print('stderr: ${result?.stderr ?? ""}');
    print('result: ${result?.output ?? ""}');
    appendLog(result?.output ?? "");
    print("执行结束");
    setState(() {
      _scrollController?.animateTo(0.0,
          duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
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
    if (isRunning) {
      appendLog("正在打包中,请稍后");

      return;
    }

    if (oriApkPath == null) {
      appendLog("APK原始文件不存在");
      return;
    }
    if (channelFile == null) {
      appendLog("请选择渠道文件");
      return;
    }
    setState(() {
      isRunning = true;
    });
    String packageName =
        "渠道包${DateFormat("yyyy年M月d日HH点mm分ss秒").format(DateTime.now())}";

    appendLog("当前时间${packageName}");
    ByteData data = await rootBundle.load(R.jar_walle_cli_all_jar);
    final buffer = data.buffer;
    File saveFile = File(
        File(channelFile.path).parent.path + "/${R.jar_walle_cli_all_jar}");
    if (!await saveFile.exists()) {
      await runCmd2("mkdir", args: ["-p", saveFile.parent.path]);
      await runCmd2("touch", args: [saveFile.path]);
      await saveFile.writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    String outApkPath =
        "${File(oriApkPath.path).parent.path + "/${packageName}/"}";
    await runCmd2("java", args: [
      "-jar",
      "${saveFile.path}",
      "batch",
      "-f",
      "${channelFile.path}",
      "${oriApkPath.path}",
      outApkPath
    ]);
    appendLog("打包已完成");
    appendLog("APK输出路径为:$outApkPath");
    runCmd2("open", args: ["$outApkPath"]);
    isRunning = false;
  }

  @override
  void reassemble() {
    super.reassemble();
    appendLog("页面热重载");
  }
}
