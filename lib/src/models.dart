import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'libmikack.dart' as libmikack;

class Platform {
  String domain;
  String name;

  Platform(this.domain, this.name);
}

class Tag {
  int value;
  String name;

  Tag(this.value, this.name);
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
