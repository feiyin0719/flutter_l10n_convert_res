import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_l10n_convert_res/flutter_l10n_convert_res.dart';

void main() {

  test('convert', () {
    final inputDir = new Directory("");
    final inputDir1 = new Directory("../res");
    final inputDir2 = new Directory("res");

//    inputDir.createSync();
    final outputDir = new Directory("res/l10n");
//    outputDir.createSync();
//    outputDir.createSync();
    expect(ConvertMoudle.convert(outputDir, inputDir), false);
    expect(ConvertMoudle.convert(outputDir, inputDir1), false);
    expect(ConvertMoudle.convert(outputDir, inputDir2), true);
  });
}
