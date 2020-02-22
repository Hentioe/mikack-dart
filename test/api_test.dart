import 'package:test/test.dart';
import 'package:mikack/mikack.dart';

void main() {
  test('.platforms()', () {
    expect(platforms().length, equals(31));
  });
}
