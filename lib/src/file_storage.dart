import 'dart:typed_data';

import 'stroage.dart';
import 'package:mp_file/mp_file.dart';

///Save cookies in  files

class FileStorage implements Storage {
  FileStorage([this.dir]);

  /// [dir]: where the cookie files saved in, it must be a directory path.
  final String? dir;

  late String _curDir;

  String? Function(Uint8List list)? readPreHandler;

  List<int> Function(String value)? writePreHandler;

  @override
  Future<void> delete(String key) async {
    final file = File('$_curDir$key');
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await Directory(_curDir).delete(recursive: true);
  }

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    final sandboxDir = await FileManager.getFileManager().appSandboxDirectory();
    _curDir = '${sandboxDir.path}/${dir ?? '.cookies'}/';
    if (!_curDir.endsWith('/')) {
      _curDir = _curDir + '/';
    }
    _curDir =
        _curDir + 'ie${ignoreExpires ? 1 : 0}_ps${persistSession ? 1 : 0}/';
    await _makeCookieDir();
  }

  @override
  Future<String?> read(String key) async {
    final file = File('$_curDir$key');
    if (await file.exists()) {
      if (readPreHandler != null) {
        return readPreHandler!(await file.readAsBytes());
      } else {
        return file.readAsString();
      }
    }
    return null;
  }

  @override
  Future<void> write(String key, String value) async {
    await _makeCookieDir();
    final file = File('$_curDir$key');
    if (writePreHandler != null) {
      await file.writeAsBytes(writePreHandler!(value));
    } else {
      await file.writeAsString(value);
    }
  }

  Future<void> _makeCookieDir() async {
    final directory = Directory(_curDir);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
  }
}
