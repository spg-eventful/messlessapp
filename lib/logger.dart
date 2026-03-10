import 'package:logging/logging.dart';

void initializeLogging() {
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name} ${record.loggerName}: ${record.time}: ${record.message}');
  });
}
