import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_app_channel/utils/CmdUtil.dart';

/**
 * Created by Gao Xuefeng
 * on 12/11/20
 */
class FileUtil {
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
        await Cmdutil.runCmd("mkdir", args: ["-p", file.parent.path]);
        await Cmdutil.runCmd("touch", args: [file.path]);
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
