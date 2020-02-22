import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'models.dart' as models;

final dylib = DynamicLibrary.open('libraries/libmikack_ffi.so');

// 获取平台列表
class Platforms extends Struct {
  @Int32()
  int len;
  Pointer<Platform> data;
}

extension PlatformsPointer on Pointer<Platforms> {
  List<models.Platform> asList() {
    var platforms = this.ref;
    var len = platforms.len;
    var dataPointer = platforms.data;
    var list = new List<models.Platform>();
    for (var i = 0; i < len; i++) {
      var platform = dataPointer[i];
      list.add(models.Platform(
          Utf8.fromUtf8(platform.domain), Utf8.fromUtf8(platform.name)));
    }
    // 释放内存
    freePlatforms(this);

    return list;
  }
}

class Platform extends Struct {
  Pointer<Utf8> domain;
  Pointer<Utf8> name;
}

typedef platforms_func = Pointer<Platforms> Function();
final platforms = dylib
    .lookup<NativeFunction<platforms_func>>('platforms')
    .asFunction<platforms_func>();

typedef free_platform_array_func = Void Function(Pointer<Platforms>);
typedef FreePlatformArray = void Function(Pointer<Platforms>);
final FreePlatformArray freePlatforms = dylib
    .lookup<NativeFunction<free_platform_array_func>>('free_platform_array')
    .asFunction();
