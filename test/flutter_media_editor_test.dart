import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_media_editor/flutter_media_editor.dart';

void main() {
  test('adds one to input values', () {
    File? file;

    if (file != null) {
      final media = MediaEditor(file: file,fileType: FileType.image,);
      expect((media.file), file);
    }
  });
}
