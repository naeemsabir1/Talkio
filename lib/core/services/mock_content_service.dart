import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memo_model.dart';

final mockContentServiceProvider = Provider<MockContentService>((ref) => MockContentService());

class MockContentService {
  Future<Memo> getMemoFromUrl(String url, String languageName) async {
    // Simulate network delay for the "Processing" animation
    await Future.delayed(const Duration(seconds: 3));
    
    // Always return the "Aura" example for this demo, with dynamic platform detection
    return _getAuraMemo(url);
  }

  Memo _getAuraMemo(String url) {
    throw UnimplementedError('Mock data removed.');
  }
}
