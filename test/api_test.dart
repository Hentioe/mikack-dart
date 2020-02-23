import 'package:test/test.dart';
import 'package:mikack/mikack.dart';
import 'dart:io';

void main() {
  test('.platforms()', () {
    expect(platforms().length, equals(31));
  });

  test('.tags()', () {
    expect(tags().length, equals(4));
  });
}

void memtesting(Function() f, {count: 999999}) {
  for (var i = 0; i < count; i++) {
    f();
  }
  print('done.');
  sleep(new Duration(seconds: 999));
}
