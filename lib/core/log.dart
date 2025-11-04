import 'package:logger/logger.dart';

final log = Logger(
  filter: ProductionFilter(), // en release no imprime nada
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, 
  ),
  level: Level.debug,
);
