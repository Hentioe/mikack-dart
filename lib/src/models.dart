import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'libmikack.dart' as libmikack;

class Platform {
  String domain;
  String name;

  Platform(String domain, String name) {
    this.domain = domain;
    this.name = name;
  }

  List<Comic> index(int page) {
    var domainPointer = Utf8.toUtf8(domain);
    var extr = libmikack.getExtr(domainPointer);
    free(domainPointer);

    return libmikack.index(extr, page).asList();
  }

  List<Comic> search(String keywords) {
    var domainPointer = Utf8.toUtf8(domain);
    var extr = libmikack.getExtr(domainPointer);
    free(domainPointer);
    var keywordsPointer = Utf8.toUtf8(keywords);
    var list = libmikack.search(extr, keywordsPointer).asList();
    free(keywordsPointer);

    return list;
  }

  void fetchChapters(Comic comic) {
    var domainPointer = Utf8.toUtf8(domain);
    var extr = libmikack.getExtr(domainPointer);
    free(domainPointer);
    var urlPointer = Utf8.toUtf8(comic.url);
    comic.chapters = libmikack.chapters(extr, urlPointer).asList();
    free(urlPointer);
  }
}

class Tag {
  int value;
  String name;

  Tag(this.value, this.name);
}

class Comic {
  String title;
  String url;
  String cover;
  List<Chapter> chapters;

  Comic(this.title, this.url, this.cover);

  String toString() {
    return "title: ${this.title}, url: ${this.url}, cover: ${this.cover}";
  }
}

class Chapter {
  String title;
  String url;
  int which;
  Map<String, String> pageHeaders;

  Chapter(this.title, this.url, this.which, this.pageHeaders);

  String toString() {
    return "title: ${this.title}, url: ${this.url}, which: ${this.which}";
  }
}

extension TagList on List<Tag> {
  Pointer<Int32> asFilters() {
    var int32Pointer = allocate<Int32>(count: this.length);
    if (this.length > 0) {
      for (var i = 0; i < this.length; i++) {
        int32Pointer[i] = this[i].value;
      }
    }
    return int32Pointer;
  }
}
