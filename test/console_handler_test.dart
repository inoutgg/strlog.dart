import 'dart:async' show runZoned, Zone, ZoneDelegate, ZoneSpecification;

import 'package:structlog/formatters.dart';
import 'package:structlog/structlog.dart';
import 'package:test/test.dart';
import 'package:structlog/handlers.dart' show ConsoleHandler;

import 'package:structlog/src/record_impl.dart';

class _DebugOnlyFilter extends Filter {
  @override
  bool filter(Record record) => record.level == Level.debug;
}

void main() {
  group('ConsoleHandler', () {
    final records = <String>[];
    ConsoleHandler handler;

    void newPrint(Zone self, ZoneDelegate parent, Zone zone, String message) =>
        records.add(message);

    final zoneSpec = ZoneSpecification(print: newPrint);

    setUp(() {
      handler = ConsoleHandler(
          formatter: TextFormatter(
              ({message, timestamp, fields, level, name}) => message));
      records.clear();
    });

    test('works correctly', () {
      runZoned<void>(() {
        handler.handle(RecordImpl(
            level: Level.debug,
            timestamp: DateTime.now(),
            message: 'ConsoleHandler test'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(1));
      expect(records[0], 'ConsoleHandler test');
    });

    test('filters record conditionally', () {
      handler.filter = _DebugOnlyFilter();
      runZoned<void>(() {
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(1));

      runZoned<void>(() {
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.info, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.danger, message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(),
            level: Level.warning,
            message: 'Test 1'));
        handler.handle(RecordImpl(
            timestamp: DateTime.now(), level: Level.debug, message: 'Test 2'));
      }, zoneSpecification: zoneSpec);

      expect(records, hasLength(2));
    });
  });
}
