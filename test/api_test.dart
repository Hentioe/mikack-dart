import 'package:test/test.dart';
import 'package:mikack/mikack.dart';
import 'package:mikack/src/models.dart' as models;
import 'dart:io';

void main() {
  test('.platforms()', () {
    expect(platforms().length, equals(31));
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
