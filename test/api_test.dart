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
        expect(p.search("猎人")[0].title, equals("+猎人"));
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
