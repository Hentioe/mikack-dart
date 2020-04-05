class MikackException implements Exception {
  final message;

  MikackException(this.message);

  String toString() {
    return message;
  }
}
