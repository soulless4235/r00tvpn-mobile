import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// r00tvpn docks the bottom bar by default; FlClash's floating dock is still a
/// setting, and these tests cover it.
void useFloatingNavigationBar(ProviderContainer container) {
  container
      .read(appSettingProvider.notifier)
      .update((state) => state.copyWith(floatingNavigationBar: true));
}
