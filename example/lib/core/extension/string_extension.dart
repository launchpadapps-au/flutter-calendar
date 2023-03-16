///extension on the string
extension StringExtension on String {
  ///it will capitalize the word
  String get capitalize {
    final List<String> data = split('').toList();
    return data[0].toUpperCase() + (data.skip(1).join());
  }
}
