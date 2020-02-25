import 'package:test/test.dart';
import 'package:mikack/mikack.dart';
import 'package:mikack/src/models.dart' as models;
import 'dart:io';

void main() {
  test('.platforms()', () {
    var list = platforms();
    expect(list.length, equals(31));
    list.forEach((p) {
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
        var address = pageIter.next();
        expect(address, isEmpty);
        pageIter.free();
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
    expect(tags().length, equals(4));
  });

  test('.findPlatforms()', () {
    var includes = tags();
    includes.retainWhere((t) => t.name == "中文");
    var excludes = tags();
    excludes.retainWhere((t) => t.name == "NSFW");
    expect(findPlatforms(includes, excludes).length, equals(20));
  });
}

void memtesting(Function() f, {count: 999999}) {
  for (var i = 0; i < count; i++) {
    f();
  }
  print('done.');
  sleep(new Duration(seconds: 999));
}
