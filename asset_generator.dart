// Copyright 2018 DebuggerX <dx8917312@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

var preview_server_port = 2228;

void main() async {
  bool working = false;
  var pubSpec = new File('pubspec.yaml');
  var pubLines = pubSpec.readAsLinesSync();
  var newLines = <String>[];
  var varNames = <String>[];
  var resource = <String>[];
  for (var line in pubLines) {
    if (line.contains('begin') &&
        line.contains('#') &&
        line.contains('assets')) {
      working = true;
      newLines.add(line);
    }
    if (line.contains('end') && line.contains('#') && line.contains('assets'))
      working = false;

    if (working) {
      if (line.trim().startsWith('#') && line.trim().endsWith('*')) {
        newLines.add(line);
        var directory =
            new Directory(line.replaceAll('#', '').replaceAll('*', '').trim());
        if (directory.existsSync()) {
          var list = directory.listSync(recursive: true);
          for (var file in list) {
            String oriPath = file.absolute.path;
            if (oriPath.contains("/drawable-xxxhdpi/") ||
                oriPath.contains("/drawable-xxhdpi/") ||
                oriPath.contains("/drawable-xhdpi/")) {
              File oldFile = new File(file.path);
              File outFile = new File(oriPath
                  .replaceAll("/drawable-xxxhdpi/", "/3.0x/")
                  .replaceFirst("/drawable-xxhdpi/", "/2.0x/")
                  .replaceFirst("/drawable-xhdpi/", "/"));
              copyFile(oldFile, outFile);
            } else if (oriPath.contains("@2x.") || oriPath.contains("@3x.")) {
              String centerPath = getPathName(oriPath);
              File oldFile = new File(file.path);
              String name = oldFile.path.replaceFirst(oldFile.parent.path, "");
              name = name.replaceFirst("@2x", "").replaceFirst("@3x", "");
              String outPath = "${oldFile.parent.path}${centerPath}$name";
              File outFile = new File(outPath);
              copyFile(oldFile, outFile);
            } else if (oriPath.endsWith(".DS_Store")) {
              new File(oriPath).deleteSync();
            }
          }
          //重新获取列表
          list = directory.listSync(recursive: true);
          for (var file in list) {
            print(file);
            String path = file.path;
            if (path.contains("/2.0x/") || path.contains("/3.0x/")) {
              String newPath =
                  path.replaceFirst("/2.0x/", "/").replaceFirst("/3.0x/", "/");
              File file = new File(newPath);
              if (file.existsSync()) {
                continue;
              }
            }
            if (new File(file.path).statSync().type ==
                FileSystemEntityType.file) {
              var path = file.path.replaceAll('\\', '/');
              var varName =
                  path.replaceAll('/', '_').replaceAll('.', '_').toLowerCase();
              // var pos = 0;
              // String char;
              // while (true) {
              //   pos = varName.indexOf('_', pos);
              //   if (pos == -1) break;
              //   char = varName.substring(pos + 1, pos + 2);
              //   varName =
              //       varName.replaceFirst('_$char', '_${char.toUpperCase()}');
              //   pos++;
              // }
              // varName = varName.replaceAll('_', '').replaceAll("-", "_");
              varName = varName.replaceAll("-", "_");
              varName = varName
                  .replaceAll("drawable_xhdpi", "")
                  .replaceAll("_3.0x_", "");
              if (varName.endsWith("_png")) {
                varName = varName.substring(0, varName.length - 4);
              }

              resource
                  .add("/// ![](http://127.0.0.1:$preview_server_port/$path)");
              resource.add("static final String $varName = '$path';");
              varNames.add("    $varName,");
              // newLines.add('    - $path');
            }
          }
        } else {
          throw new FileSystemException('Directory wrong');
        }
      }
    } else {
      newLines.add(line);
    }
  }

  var r = new File('lib/r.dart');
  if (r.existsSync()) {
    r.deleteSync();
  }
  r.createSync();
  var content = 'class R {\n';
  for (var line in resource) {
    content = '$content  $line\n';
  }
  content = '$content\n  static final values = [\n';
  for (var line in varNames) {
    content = '$content  $line\n';
  }
  content = '$content  ];\n}\n';
  r.writeAsStringSync(content);

  var spec = '';
  for (var line in newLines) {
    spec = '$spec$line\n';
  }
  pubSpec.writeAsStringSync(spec);

  await syncResource(0);
}

void copyFile(File oldFile, File outFile) {
  if (!outFile.parent.existsSync()) {
    outFile.parent.createSync();
  }
  oldFile.copySync(outFile.path);
  oldFile.deleteSync();
  if (oldFile.parent.existsSync() &&
      // ignore: unrelated_type_equality_checks
      oldFile.parent.listSync().length == 0) {
    oldFile.parent.deleteSync();
  }
}

Future syncResource(int time) async {
  try {
    var ser = await HttpServer.bind('127.0.0.1', preview_server_port);
    print('成功启动图片预览服务器于本机<$preview_server_port>端口');
    ser.listen(
      (req) {
        var index = req.uri.path.lastIndexOf('.');
        var subType = req.uri.path.substring(index + 1);
        print(subType);
        req.response
          ..headers.contentType = new ContentType('image', subType)
          ..add(new File('.${req.uri.path}').readAsBytesSync())
          ..close();
      },
    );
  } catch (e) {
    print('图片预览服务器已启动或端口被占用');
    if (time < 5) {
      preview_server_port += 1;
      print("更换端口:${preview_server_port}");
      syncResource(time + 1);
    }
  }
}

String getPathName(String oriPath) {
  if (oriPath.contains("@2x.")) {
    return "/2.0x";
  } else {
    return "/3.0x";
  }
}
