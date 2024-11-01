import 'dart:io';

import 'package:strlog/formatters.dart';
import 'package:strlog/handlers.dart';
import 'package:strlog/strlog.dart';

final _defaultFormatter = TextFormatter.withDefaults();

void main() {
  final logger = Logger.detached()
    ..handler = ConsoleHandler(formatter: _defaultFormatter);

  logger
      .info('A new log with bound PID appears on a screen', [Int('pid', pid)]);
}
