library flutter_l10n_convert_res;

import 'dart:io';

import 'package:flutter_l10n_convert_res/log.dart';
import 'package:path/path.dart' as Path;
import 'package:xml/xml.dart' as xml;

class ConvertMoudle {
  static final RegExp specifier = new RegExp(
      r'%(?:(\d+)\$)?([\+\-\#0 ]*)(\d+|\*)?(?:\.(\d+|\*))?([a-z%])',
      caseSensitive: false);
  static const List<String> _pluralEnding = <String>[
    'zero',
    'one',
    'two',
    'few',
    'many',
    'other'
  ];

  static bool convert(Directory outputDir, Directory inputDir,
      {String namePrefix = 'strings'}) {
    if (!inputDir.existsSync()) return false;
    outputDir.createSync(recursive: true);
    List<FileSystemEntity> resFolders =
        inputDir.listSync(recursive: true).where((f) {
      return FileSystemEntity.isDirectorySync(f.path) &&
          Path.basename(f.path).startsWith('values') &&
          new File(f.path + Platform.pathSeparator + "strings.xml")
              .existsSync();
    }).toList();
    if (resFolders.isEmpty) {
      log.info('No values* folder found in ${inputDir.path}.');
      return false;
    }
    if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
    resFolders.forEach((f) {
      File xmlFile = new File(f.path + Platform.pathSeparator + "strings.xml");
      if (xmlFile.existsSync()) {
        String folderName = Path.basename(f.path);
        List<String> temp = folderName.split("-");
        String name = temp.last;
        if (temp.length <= 1) {
          name = 'en';
        }
        if (name.length == 3 && name.startsWith("r"))
          name = '${temp[temp.length - 2]}_${name.toLowerCase().substring(1)}';
        Map<String, dynamic> stringsMap = parseXml(xmlFile);
        File arbFile = new File(outputDir.path +
            Platform.pathSeparator +
            "${namePrefix}_${name}.arb");
        arbFile.createSync(recursive: true);
        writeToFile(arbFile, stringsMap);
      }
    });

    return true;
  }

  static Map<String, dynamic> parseXml(File xmlFile) {
    xml.XmlDocument document = xml.parse(xmlFile.readAsStringSync());
    Map<String, dynamic> stringMaps = document
        .findAllElements("string")
        .where((element) =>
            element?.attributes?.isNotEmpty &&
            element?.attributes?.first?.value != null &&
            element?.firstChild?.text != null)
        .toList()
        .asMap()
        .map((index, e) => new MapEntry(
            e.attributes.first.value, convertStrings(e.firstChild.text)));

    List<xml.XmlElement> pluralsList = document
        .findAllElements("plurals")
        .where((element) => element?.children?.isNotEmpty)
        .toList();
    pluralsList.forEach((e) {
      e.findAllElements("item").forEach((child) {
        if (child?.attributes?.isNotEmpty &&
            _pluralEnding.contains(child?.attributes?.first?.value) &&
            child?.text != null) {
          final pluralsName =
              child.attributes.first.value.substring(0, 1).toUpperCase() +
                  child.attributes.first.value.substring(1);
          stringMaps.putIfAbsent(e.attributes.first.value + pluralsName,
              () => convertStrings(child.text));
        }
      });
    });
    return stringMaps;
  }

  static String convertStrings(String text) {
    int current_nums = 0;
    String newString = text.replaceAllMapped(specifier, (match) {
      ++current_nums;
      return "\$param${current_nums}";
    });
    return newString;
  }

  static bool writeToFile(File f, Map<String, dynamic> map) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("{");
    List keyList = map.keys.toList();
    for (int i = 0; i < keyList.length; ++i) {
      buffer.write('    "${keyList[i]}": "${map[keyList[i]]}"');
      if (i != keyList.length - 1) buffer.write(',');
      buffer.writeln();
    }

    buffer.write("}");
    f.writeAsStringSync(buffer.toString(), flush: true);
    return true;
  }
}
