import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/home/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _RecordingProxiesAction extends ProxiesAction {
  final tested = <String>[];

  @override
  Future<void> delayTestPageGroup(
    String groupName, {
    bool matchSearch = true,
  }) async {
    tested.add(groupName);
  }
}

void main() {
  late _RecordingProxiesAction action;
  late ProviderContainer container;

  setUp(() {
    action = _RecordingProxiesAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            const Profile(id: 1, autoUpdateDuration: Duration.zero),
          ]),
        ),
        proxiesActionProvider.overrideWith(() => action),
      ],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    container.listen(groupsProvider, (_, _) {});
    container.listen(runTimeProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value = 1;
    container.read(groupsProvider.notifier).value = const [
      Group(
        type: GroupType.Selector,
        name: 'Main',
        hidden: false,
        all: [Proxy(name: 'node', type: 'Vless')],
      ),
    ];
  });

  tearDown(() => container.dispose());

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: HomeView()),
      ),
    );
    await tester.pump();
  }

  testWidgets('connecting tests the servers once the routes are up', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(action.tested, isEmpty);

    container.read(runTimeProvider.notifier).value = 1000;
    await tester.pump(const Duration(milliseconds: 1000));
    expect(action.tested, isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    expect(action.tested, ['Main']);

    // Staying connected does not test again
    container.read(runTimeProvider.notifier).value = 2000;
    await tester.pump(const Duration(seconds: 2));
    expect(action.tested, ['Main']);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disconnecting before the delay cancels the test', (
    tester,
  ) async {
    await pumpHome(tester);

    container.read(runTimeProvider.notifier).value = 1000;
    await tester.pump(const Duration(milliseconds: 500));
    container.read(runTimeProvider.notifier).value = null;
    await tester.pump(const Duration(seconds: 2));

    expect(action.tested, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opening the home screen while connected tests nothing', (
    tester,
  ) async {
    container.read(runTimeProvider.notifier).value = 1000;
    await pumpHome(tester);
    await tester.pump(const Duration(seconds: 2));

    expect(action.tested, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
