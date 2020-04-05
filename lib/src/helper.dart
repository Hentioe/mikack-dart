import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'exceptions.dart';
import 'libmikack.dart' as libmikack;

String findDynamicLibraryFile(String name, String dir) {
  if (!dir.endsWith('/')) dir = dir + '/';
  if (Platform.isAndroid) return 'lib${name}.so';
  if (Platform.isLinux) return '${dir}lib${name}.so';
  if (Platform.isMacOS) return '${dir}lib${name}.dylib';
  if (Platform.isWindows) return '${dir}${name}.dll';
  throw MikackException("Platform not implemented");
}

MikackException checkError() {
  var errLen = libmikack.lastErrorLength();
  if (errLen > 0) {
    // 发生错误，直接抛出异常
    var errBuf = Utf8.toUtf8('');
    libmikack.lastErrorMessage(errBuf, errLen);
    var errMsg = Utf8.fromUtf8(errBuf);
    free(errBuf);
    return MikackException(errMsg);
  }
  return null;
}
