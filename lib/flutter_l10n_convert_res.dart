library flutter_l10n_convert_res;

import 'dart:io';

import 'package:flutter_l10n_convert_res/log.dart';
import 'package:xml/xml.dart' as xml;

class ConvertMoudle {
  static final RegExp specifier = new RegExp(
      r'%(?:(\d+)\$)?([\+\-\#0 ]*)(\d+|\*)?(?:\.(\d+|\*))?([a-z%])',
      caseSensitive: false);

  static bool convert(Directory outputDir, Directory inputDir) {
    if (!inputDir.existsSync()) return false;
    if (outputDir.existsSync()) outputDir.deleteSync(recursive: true);
    outputDir.createSync(recursive: true);
    List<FileSystemEntity> resFolders =
        inputDir.listSync(recursive: true).where((f) {
      return FileSystemEntity.isDirectorySync(f.path) &&
          f.path.split(Platform.pathSeparator).last.startsWith('values') &&
          new File(f.path + Platform.pathSeparator + "strings.xml")
              .existsSync();
    }).toList();
    if (resFolders.isEmpty) {
      log.info('No values* folder found in ${inputDir.path}.');
      return false;
    }

    resFolders.forEach((f) {
      File xmlFile = new File(f.path + Platform.pathSeparator + "strings.xml");
      if (xmlFile.existsSync()) {
        List<String> temp = f.path.split("-");
        String name = temp.last;
        if (temp.length <= 1) {
          name = 'en';
        }
        if (name.length == 3)
          name = '${temp[temp.length - 2]}_${name.toLowerCase().substring(1)}';
        Map<String, dynamic> stringsMap = parseXml(xmlFile);
        File arbFile = new File(
            outputDir.path + Platform.pathSeparator + "strings_$name.arb");
        arbFile.createSync();
        writeToFile(arbFile, stringsMap);
      }
    });

    return true;
  }

  static Map<String, dynamic> parseXml(File xmlFile) {
    xml.XmlDocument document = xml.parse(xmlFile.readAsStringSync());
    List<xml.XmlElement> stringDocList =
        document.findAllElements("string").toList();
    Map<String, dynamic> stringMaps = new Map();
    stringDocList.forEach((e) {
      stringMaps.putIfAbsent(
          e.attributes.first.value, () => convertStrings(e.firstChild.text));
    });
    List<xml.XmlElement> pluralsList =
        document.findAllElements("plurals").toList();
    pluralsList.forEach((e) {
      e.findAllElements("item").forEach((child) {
        if (child != null) {
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
  }
}
