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

  Chapter(this.title, this.url, this.which, this.pageHeaders);

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
