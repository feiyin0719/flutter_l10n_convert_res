import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_l10n_convert_res/flutter_l10n_convert_res.dart';
import 'package:flutter_l10n_convert_res/log.dart';

import 'package:path/path.dart';

const String sourceKey = 'source';
const String sourceDefault = './res';

const String outputKey = 'output';
const String outputDefault = './res/arbs';





Future<void> main(List<String> arguments) async {
  final ArgParser parser = ArgParser()
    ..addOption(
      sourceKey,
      abbr: 's',
      help: 'Specify where to search for the arb files.',
      valueHelp: sourceDefault,
      defaultsTo: sourceDefault,
    )
    ..addOption(
      outputKey,
      abbr: 'o',
      help: 'Specify where to save the generated dart files.',
      valueHelp: outputDefault,
      defaultsTo: outputDefault,
    );
  initLog();
  if (arguments.isNotEmpty && arguments[0] == 'help') {
    stdout.writeln(parser.usage);
    return;
  }

  final ArgResults result = parser.parse(arguments);

  final String source = canonicalize(absolute(result[sourceKey]));
  final String output = canonicalize(absolute(result[outputKey]));


  final Directory sourceDir = Directory(source);
  final Directory outputDir = Directory(output);
  if(!sourceDir.existsSync()){
    log.info('source folder not existe.');
  }else{
    if(ConvertMoudle.convert(outputDir, sourceDir))
      log.info('convert done.');
    else
      log.info('convert failed.');
  }
}
