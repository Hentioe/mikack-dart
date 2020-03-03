import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../models.dart' as models;
import 'helper.dart' show findDynamicLibraryFile;

final dylib =
    DynamicLibrary.open(findDynamicLibraryFile('mikack_ffi', 'libraries'));

// 获取平台列表
class Platforms extends Struct {
  @Int32()
  int len;
  Pointer<Platform> data;
}

class Platform extends Struct {
  Pointer<Utf8> domain;
  Pointer<Utf8> name;
  Pointer<Utf8> favicon;
  @Uint8()
  int is_usable;
  @Uint8()
  int is_searchable;
  @Uint8()
  int is_pageable;
  @Uint8()
  int is_https;
  Pointer<Tags> tags;
}

extension PlatformsPointer on Pointer<Platforms> {
  List<models.Platform> asList() {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Platform>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      var p =
          models.Platform(Utf8.fromUtf8(item.domain), Utf8.fromUtf8(item.name));
      var favicon = Utf8.fromUtf8(item.favicon);
      if (!favicon.isEmpty) p.favicon = favicon;
      p.isUsable = item.is_usable == 1;
      p.isSearchable = item.is_searchable == 1;
      p.isPageable = item.is_pageable == 1;
      p.isHttps = item.is_https == 1;
      p.tags = item.tags.asList(free: false); // 包含在平台列表释放中
      list.add(p);
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
  List<models.Tag> asList({free = true}) {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Tag>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      list.add(models.Tag(item.value, Utf8.fromUtf8(item.name)));
    }
    if (free) freeTags(this);

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

// 获取 extractor
typedef get_extr_func = Pointer Function(Pointer<Utf8>);
final getExtr = dylib
    .lookup<NativeFunction<get_extr_func>>('get_extr')
    .asFunction<get_extr_func>();

// 获取漫画列表
class Comics extends Struct {
  @Int32()
  int len;
  Pointer<Comic> data;
}

class Comic extends Struct {
  Pointer<Utf8> title;
  Pointer<Utf8> url;
  Pointer<Utf8> cover;
}

extension ComicsPointer on Pointer<Comics> {
  List<models.Comic> asList() {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Comic>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      list.add(models.Comic(Utf8.fromUtf8(item.title), Utf8.fromUtf8(item.url),
          Utf8.fromUtf8(item.cover)));
    }
    // 释放内存
    freeComics(this);

    return list;
  }
}

typedef index_func = Pointer<Comics> Function(Pointer, Int32);
typedef Index = Pointer<Comics> Function(Pointer, int);
final Index index =
    dylib.lookup<NativeFunction<index_func>>('index').asFunction();

typedef free_comic_array_func = Void Function(Pointer<Comics>);
typedef FreeComicArray = void Function(Pointer<Comics>);
final FreeComicArray freeComics = dylib
    .lookup<NativeFunction<free_comic_array_func>>('free_comic_array')
    .asFunction();

// 搜索漫画列表
typedef search_func = Pointer<Comics> Function(Pointer, Pointer<Utf8>);
final search = dylib
    .lookup<NativeFunction<search_func>>('search')
    .asFunction<search_func>();

// 获取章节列表
class Chapters extends Struct {
  @Int32()
  int len;
  Pointer<Chapter> data;
}

class Chapter extends Struct {
  Pointer<Utf8> title;
  Pointer<Utf8> url;
  @Uint32()
  int which;
  Pointer<Headers> page_headers;
}

class Headers extends Struct {
  @Int32()
  int len;
  Pointer<Header> data;
}

class Header extends Struct {
  Pointer<Utf8> key;
  Pointer<Utf8> value;
}

extension ChaptersPointer on Pointer<Chapters> {
  List<models.Chapter> asList() {
    var ref = this.ref;
    var len = ref.len;
    var dataPointer = ref.data;
    var list = new List<models.Chapter>();
    for (var i = 0; i < len; i++) {
      var item = dataPointer[i];
      var phRef = item.page_headers.ref;
      var phLen = phRef.len;
      var phDataPointer = phRef.data;
      var phMap = new Map<String, String>();
      for (var i = 0; i < phLen; i++) {
        var phItem = phDataPointer[i];
        phMap[Utf8.fromUtf8(phItem.key)] = Utf8.fromUtf8(phItem.value);
      }

      list.add(models.Chapter(Utf8.fromUtf8(item.title),
          Utf8.fromUtf8(item.url), item.which, phMap));
    }
    // 释放内存
    freeChapters(this);

    return list;
  }
}

typedef chapters_func = Pointer<Chapters> Function(
    Pointer, Pointer<Utf8>, Pointer<Utf8>);
final chapters = dylib
    .lookup<NativeFunction<chapters_func>>('chapters')
    .asFunction<chapters_func>();

typedef free_chapter_array_func = Void Function(Pointer<Chapters>);
typedef FreeChaptersArray = void Function(Pointer<Chapters>);
final FreeChaptersArray freeChapters = dylib
    .lookup<NativeFunction<free_chapter_array_func>>('free_chapter_array')
    .asFunction();

// 创建原始章节指针
typedef create_chapter_ptr_func = Pointer Function(Pointer<Utf8>);
final createChapterPtr = dylib
    .lookup<NativeFunction<create_chapter_ptr_func>>('create_chapter_ptr')
    .asFunction<create_chapter_ptr_func>();

// 创建迭代器，返回指针和一部分元数据
class CreatedPageIter extends Struct {
  @Int32()
  int count;
  Pointer<Utf8> title;
  Pointer iter;
}

typedef create_page_iter_func = Pointer<CreatedPageIter> Function(
    Pointer, Pointer);
final createPageIter = dylib
    .lookup<NativeFunction<create_page_iter_func>>('create_page_iter')
    .asFunction<create_page_iter_func>();
// 释放迭代器
typedef free_created_page_iter_func = Void Function(Pointer);
typedef FreeCreatedPageIter = void Function(Pointer);
final FreeCreatedPageIter freeCreatedPageIter = dylib
    .lookup<NativeFunction<free_created_page_iter_func>>(
        'free_created_page_iter')
    .asFunction();

// 翻页
typedef next_page_func = Pointer<Utf8> Function(Pointer iter);
final nextPage = dylib
    .lookup<NativeFunction<next_page_func>>('next_page')
    .asFunction<next_page_func>();

// 释放字符串内存
typedef free_string_func = Void Function(Pointer<Utf8>);
typedef FreeString = void Function(Pointer<Utf8>);
final FreeString freeString =
    dylib.lookup<NativeFunction<free_string_func>>('free_string').asFunction();
