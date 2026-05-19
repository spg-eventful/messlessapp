import 'dart:convert';
import 'package:messless/secure_storage.dart';
import 'package:messless/ws/schema/event/event.dart';

class HistoryService {
  static const String _historyKey = 'recent_events';
  static const int _maxItems = 5;

  Future<void> addToHistory(Event event) async {
    final historyJson = await storage.read(key: _historyKey);
    List<Event> history = [];
    
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      history = decoded.map((e) => Event.fromJson(e)).toList();
    }

    history.removeWhere((item) => item.id == event.id);
    
    history.insert(0, event);

    if (history.length > _maxItems) {
      history = history.sublist(0, _maxItems);
    }

    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await storage.write(key: _historyKey, value: encoded);
  }

  Future<List<Event>> getHistory() async {
    final historyJson = await storage.read(key: _historyKey);
    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((e) => Event.fromJson(e)).toList();
  }
}
