import 'src/libmikack.dart' as libmikack;
import 'src/models.dart' as models;
import 'package:ffi/ffi.dart';

List<models.Platform> platforms() => libmikack.platforms().asList();
List<models.Tag> tags() => libmikack.tags().asList();
List<models.Platform> findPlatforms(
    List<models.Tag> includes, List<models.Tag> excludes) {
  var incPointer = includes.asFilters();
  var excPointer = excludes.asFilters();
  var list = libmikack
      .findPlatforms(incPointer, includes.length, excPointer, excludes.length)
      .asList();
  // 释放参数内存
  free(incPointer);
  free(excPointer);

  return list;
}
