import 'dart:io';

import 'package:process_runner/process_runner.dart';

main() async {
  print("开始执行");
  ProcessRunner _processRunner = ProcessRunner();

  var array = [
    "/Users/gaoxuefeng/Library/Android/sdk/build-tools/33.0.1/apksigner",
    "sign",
    "--ks",
    "/Users/gaoxuefeng/Downloads/keystore.jks",
    "--ks-key-alias",
    "chengjia",
    "--key-pass",
    "fuzzytomato007",
    "/Users/gaoxuefeng/Downloads/vivo_unsign.apk"
  ];
  var stdin = SystemEncoding().encode("chengjia123");

  ProcessRunnerResult result = await _processRunner
      .runProcess(array.toList(growable: true),
          printOutput: true, stdin: Stream.value(stdin))
      .catchError((onError) {
    print("收到错误信息:" + onError.toString());
    throw onError;
  });
  print('stdout: ${result.stdout}');
  print('stderr: ${result.stderr}');
  print('result: ${result.output}');
  print("执行结束:");
  return result.output;
}
