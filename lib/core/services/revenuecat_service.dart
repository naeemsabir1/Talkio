import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

class RevenueCatService {
  static const String _apiKey = 'appl_xSBdKwPbKQsjFaTefETTxBaZnor';
  static const String _entitlementId = 'premium';
  
  bool _isInitialized = false;
  CustomerInfo? _customerInfo;

  bool get isInitialized => _isInitialized;
  CustomerInfo? get customerInfo => _customerInfo;

  Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      PurchasesConfiguration configuration;
      // In a real app we'd configure for both iOS/Android appropriately.
      // Assuming iOS based on the share extension context.
      configuration = PurchasesConfiguration(_apiKey);
      
      await Purchases.configure(configuration);
      _isInitialized = true;
      
      _customerInfo = await Purchases.getCustomerInfo();
      
      // Setup listener for changes
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo = info;
      });
      
      debugPrint('💰 RevenueCat initialized successfully.');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization failed: $e');
    }
  }

  bool isPremiumUser() {
    if (_customerInfo == null) return false;
    // Check if the entitlement is active
    return _customerInfo!.entitlements.all[_entitlementId]?.isActive == true;
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return null;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);
      _customerInfo = result.customerInfo;
      return isPremiumUser();
    } catch (e) {
      debugPrint('❌ Error purchasing package: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      return isPremiumUser();
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      return false;
    }
  }
}
