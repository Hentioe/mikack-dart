import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'src/libmikack.dart' as libmikack;

class Platform {
  String domain;
  String name;
  String favicon;
  bool isUsable;
  bool isSearchable;
  bool isPageable;
  bool isHttps;
  List<Tag> tags = [];

  Platform(String domain, String name) {
    this.domain = domain;
    this.name = name;
  }

  String toString() {
    return 'domain: $domain, name: $name, favicon: $favicon, isUsable: $isUsable, isSearchable: $isSearchable, isPageable: $isPageable, isHttps: $isHttps';
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
    var titlePointer = Utf8.toUtf8(comic.title);
    comic.chapters =
        libmikack.chapters(extr, urlPointer, titlePointer).asList();
    free(urlPointer);
    free(titlePointer);
  }

  PageIterator createPageIter(Chapter chapter) {
    var urlPointer = Utf8.toUtf8(chapter.url);
    var chapterPointer = libmikack.createChapterPtr(urlPointer);
    free(urlPointer);
    var domainPointer = Utf8.toUtf8(domain);
    var extr = libmikack.getExtr(domainPointer);
    free(domainPointer);

    var createdIterPointer = libmikack.createPageIter(extr, chapterPointer);
    var createdIterRef = createdIterPointer.ref;
    chapter.pageCount = createdIterRef.count;
    chapter.title = Utf8.fromUtf8(createdIterRef.title);
    var headers = libmikack.readHeadersFromPtr(createdIterRef.headers);
    if (headers.length > 0) chapter.pageHeaders = headers;

    return PageIterator(createdIterPointer, createdIterRef.iter);
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
  Map<String, String> headers = {};

  Comic(this.title, this.url, this.cover);

  String toString() {
    return "title: ${this.title}, url: ${this.url}, cover: ${this.cover}";
  }
}

class Chapter {
  String title;
  String url;
  int which;
  int pageCount = 0;
  Map<String, String> pageHeaders;

  Chapter({
    this.title,
    this.url,
    this.which,
    this.pageHeaders,
  });

  String toString() {
    return "title: ${this.title}, url: ${this.url}, which: ${this.which}";
  }
}

class PageIterator {
  Pointer createdIterPointer;
  Pointer iterPointer;

  PageIterator(this.createdIterPointer, this.iterPointer);

  void free() {
    libmikack.freeCreatedPageIter(this.createdIterPointer);
  }

  String next() {
    var addressPointer = libmikack.nextPage(this.iterPointer);
    var address = Utf8.fromUtf8(addressPointer);
    libmikack.freeString(addressPointer);

    return address;
  }

  String toString() {
    return 'PageIterator(iter: $iterPointer)';
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
