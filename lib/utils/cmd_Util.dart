import 'package:process_runner/process_runner.dart';

/// Created by Gao Xuefeng
/// on 12/11/20
class CmdUtil {
  static ProcessRunner _processRunner = ProcessRunner();

  static Future<String> runCmd(String cmd,
      {List<String>? args, Function(String)? appendLog}) async {
    if (appendLog != null) {
      appendLog("\n-------------------$cmd-${args?.toString() ?? ""}--");
    }
    print("\n-------------------$cmd-${args?.toString() ?? ""}--");
    List<String> list = List.empty(growable: true);
    list.add(cmd);
    if ((args?.length ?? 0) > 0) {
      list.addAll(args!);
    }
    ProcessRunnerResult result = await _processRunner
        .runProcess(
      list,
      printOutput: true,
    )
        .catchError((onError) {
      if (appendLog != null) {
        appendLog("错误日志:${onError?.toString() ?? ""}");
      }
      print(onError?.toString() ?? "");
      throw onError;
    });
    print('stdout: ${result.stdout}');
    print('stderr: ${result.stderr}');
    print('result: ${result.output}');
    if (appendLog != null) {
      appendLog(result.output);
    }
    print("执行结束");
    return result.output;
  }
}
