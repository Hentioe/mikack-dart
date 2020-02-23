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

class Platform extends Struct {
  Pointer<Utf8> domain;
  Pointer<Utf8> name;
}

extension PlatformsPointer on Pointer<Platforms> {
  List<models.Platform> asList() {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Platform>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      list.add(models.Platform(
          Utf8.fromUtf8(item.domain), Utf8.fromUtf8(item.name)));
    }
    // 释放内存
    freePlatforms(this);

    return list;
  }
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

// 获取标签列表
class Tags extends Struct {
  @Int32()
  int len;
  Pointer<Tag> data;
}

class Tag extends Struct {
  @Int32()
  int value;
  Pointer<Utf8> name;
}

extension TagsPointer on Pointer<Tags> {
  List<models.Tag> asList() {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Tag>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      list.add(models.Tag(item.value, Utf8.fromUtf8(item.name)));
    }
    // 释放内存
    freeTags(this);

    return list;
  }
}

typedef tags_func = Pointer<Tags> Function();
final tags =
    dylib.lookup<NativeFunction<tags_func>>('tags').asFunction<tags_func>();

typedef free_tag_array_func = Void Function(Pointer<Tags>);
typedef FreeTagArray = void Function(Pointer<Tags>);
final FreeTagArray freeTags = dylib
    .lookup<NativeFunction<free_tag_array_func>>('free_tag_array')
    .asFunction();

// 搜索平台列表
typedef find_platforms_func = Pointer<Platforms> Function(
    Pointer<Int32>, Int32, Pointer<Int32>, Int32);
typedef FindPlatforms = Pointer<Platforms> Function(
    Pointer<Int32>, int, Pointer<Int32>, int);
final FindPlatforms findPlatforms = dylib
    .lookup<NativeFunction<find_platforms_func>>('find_platforms')
    .asFunction();
