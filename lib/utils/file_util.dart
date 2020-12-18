import 'dart:io';

import 'package:dart_app_data/dart_app_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_channel/utils/cmd_Util.dart';

/**
 * Created by Gao Xuefeng
 * on 12/11/20
 */
class FileUtil {
  static String getRootFile() {
    return AppData.findOrCreate('flutterAppChannel/').path;
  }

  static Future<File> copyAssetJarFile(
      String jarAssetFile, String sourceRootFile) async {
    String rootFile = sourceRootFile;
    File saveFile = File(rootFile + "/$jarAssetFile");
    if (!await saveFile.exists()) {
      ByteData data = await rootBundle.load(jarAssetFile);
      final buffer = data.buffer;
      await createFile(saveFile.path);
      await saveFile.writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    return saveFile;
  }

  static Future<File> createFile(String path) async {
    File file = File(path);
    if (!file.existsSync()) {
      if (!file.parent.existsSync()) {
        await CmdUtil.runCmd("mkdir", args: ["-p", file.parent.path]);
        await CmdUtil.runCmd("touch", args: [file.path]);
      }
    }
    return file;
  }

  static Future<File> copyFile(String oriPath, String copyPath) async {
    File oriFile = File(oriPath);
    if (oriFile.existsSync()) {
      File resultFile = await createFile(copyPath);
      resultFile.writeAsBytesSync(oriFile.readAsBytesSync());
      return resultFile;
    }
    return null;
  }
}
