import 'package:test/test.dart';
import 'package:mikack/mikack.dart';
import 'dart:io';

void main() {
  test('.platforms()', () {
    var list = platforms();
    expect(list.length, equals(34));
    list.forEach((p) {
      expect(p.tags, isNotEmpty);
      if (p.domain == "manhua.dmzj.com") {
        var comic = p.search("灌篮高手全国大赛篇(全彩版本)")[0];
        expect(comic.chapters, isNull);
        expect(comic.title, equals("灌篮高手全国大赛篇(全彩版本)"));
        p.fetchChapters(comic);
        var chapters = comic.chapters;
        expect(chapters, isNotEmpty);
        expect(chapters.length, equals(80));
        chapters.forEach((c) {
          expect(c.pageHeaders["Referer"], equals(c.url));
        });
        var chapter = chapters[0];
        expect(chapter.pageCount, equals(0));
        var pageIter = p.createPageIter(chapter);
        expect(chapter.pageCount, equals(21));
        for (var i = 0; i < chapter.pageCount; i++) {
          var address = pageIter.next();
          expect(address, isNotEmpty);
          expect(address.startsWith("http"), isTrue);
        }
        try {
          pageIter.next();
        } on MikackException catch (e) {
          expect(e.toString(), equals('No next page'));
        }
        pageIter.free();
      }
      if (p.domain == "www.wuqimh.com") {
        expect(p.isSearchPageable, isTrue);
      }
      // if (p.domain == "8comic.se") {
      //   var comic = p.search("生存遊戲")[0];
      //   expect(comic.cover, isEmpty);
      //   expect(comic.chapters, isNull);
      //   expect(comic.title, equals("生存遊戲"));
      //   p.fetchChapters(comic);
      //   expect(comic.cover, isNotEmpty);
      // }
      if (p.domain == "e-hentai.org") {
        var comic = p.index(1)[0];
        expect(comic.title, isNotEmpty);
        p.fetchChapters(comic);
        expect(comic.chapters.first.title, isNotEmpty);
      }
    });
    var firstPlatform = list[0];
    var comics = firstPlatform.index(1);
    expect(comics, isNotEmpty);
    comics.forEach((comic) {
      expect(comic.title, isNotEmpty);
      expect(comic.url, isNotEmpty);
      expect(comic.cover, isNotEmpty);
    });
  });

  test('.tags()', () {
    expect(tags().length, equals(5));
  });

  test('.findPlatforms()', () {
    var includes = tags();
    includes.retainWhere((t) => t.name == "中文");
    var excludes = tags();
    excludes.retainWhere((t) => t.name == "NSFW");
    expect(findPlatforms(includes, excludes).length, equals(22));
  });
}

void memtesting(Function() f, {count: 999999}) {
  for (var i = 0; i < count; i++) {
    f();
  }
  print('done.');
  sleep(new Duration(seconds: 999));
}
