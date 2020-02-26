import 'dart:io' show Platform;

String findDynamicLibraryFile(String name, String dir) {
  if (!dir.endsWith('/')) dir = dir + '/';
  if (Platform.isAndroid) return 'lib${name}.so';
  if (Platform.isLinux) return '${dir}lib${name}.so';
  if (Platform.isMacOS) return '${dir}lib${name}.dylib';
  if (Platform.isWindows) return '${dir}${name}.dll';
  throw Exception("Platform not implemented");
}
