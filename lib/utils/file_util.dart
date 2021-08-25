import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_app_channel/utils/cmd_Util.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

/**
 * Created by Gao Xuefeng
 * on 12/11/20
 */
class FileUtil {
  static Future<String> getRootFile() async {
    return (await getTemporaryDirectory()).path;
    // return AppData.findOrCreate('flutterAppChannel/').path;
  }

  static Future<File> copyAssetJarFile(String jarAssetFile, String sourceRootFile) async {
    String rootFile = sourceRootFile;
    File saveFile = File(rootFile + "/$jarAssetFile");
    if (!await saveFile.exists()) {
      ByteData data = await rootBundle.load(jarAssetFile);
      final buffer = data.buffer;
      await createFile(saveFile.path);
      await saveFile.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    return saveFile;
  }

  static Future<File> createFile(String path) async {
    File file = File(path);
    if (!file.existsSync()) {
      if (!file.parent.existsSync()) {
        if (GetPlatform.isMacOS) {
          await CmdUtil.runCmd("mkdir", args: ["-p", file.parent.path]);
          await CmdUtil.runCmd("touch", args: [file.path]);
        } else if (GetPlatform.isWindows) {
          //md create_file\test
          await CmdUtil.runCmd("md", args: [file.parent.path]);
          //创建文件
          await CmdUtil.runCmd("type nul >", args: [file.path]);
        } else {
          throw Exception("Platform not support...");
        }
      }
    }
    return file;
  }

  static Future<File?> copyFile(String oriPath, String copyPath) async {
    File oriFile = File(oriPath);
    if (oriFile.existsSync()) {
      File resultFile = await createFile(copyPath);
      resultFile.writeAsBytesSync(oriFile.readAsBytesSync());
      return resultFile;
    }
    return null;
  }
}
