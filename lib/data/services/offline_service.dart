import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class OfflineService {
  static final _supabase = Supabase.instance.client;
  static final _box = Hive.box('offline_transactions');

  static Future<void> saveTransactionOffline(Map<String, dynamic> data) async {
    await _box.add(data);
    debugPrint('Transaction saved offline: ${data['description']}');
  }

  static Future<void> syncTransactions() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    if (_box.isEmpty) return;

    debugPrint('Starting offline sync...');
    final items = _box.values.toList();
    
    for (var i = 0; i < items.length; i++) {
      try {
        final item = Map<String, dynamic>.from(items[i]);
        await _supabase.from('transactions').insert(item);
        await _box.deleteAt(0); // Delete as we sync
        debugPrint('Synced item: ${item['description']}');
      } catch (e) {
        debugPrint('Sync error for item $i: $e');
        break; // Stop if there's an error (maybe connection dropped again)
      }
    }
  }

  static void listenToConnection() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncTransactions();
      }
    });
  }
}
