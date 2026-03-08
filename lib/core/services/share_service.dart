import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());

class ShareService {
  // Native Channels
  static const _methodChannel = MethodChannel('com.talkio.share/data');
  static const _eventChannel = EventChannel('com.talkio.share/events');

  Future<String?> getInitialUrl() async {
    try {
      final String? initialText = await _methodChannel.invokeMethod('getInitialContent');
      print("📱 ShareService: getInitialUrl() returned: $initialText");
      return initialText;
    } on PlatformException catch (e) {
      // Create a sensible fallback or log error
      print("❌ ShareService: Failed to get initial shared text: '${e.message}'.");
      return null;
    }
  }

  Stream<String?> get intentStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      print("📱 ShareService: Event received from native channel: $event");
      return event as String?;
    });
  }
}
