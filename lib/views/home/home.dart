import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'connection_card.dart';
import 'home_card.dart';
import 'home_glyphs.dart';
import 'server_list.dart';

const _twoColumnWidth = 720.0;
const _gap = 12.0;
// Routes need a moment after connecting before a delay test reflects them
const _autoTestDelay = Duration(milliseconds: 1500);

/// r00tvpn's home screen, the desktop app's "Graphite" home: the connection
/// card and the server list, side by side when there is room.
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  Timer? _autoTest;

  @override
  void initState() {
    super.initState();
    // Once a connection comes up the servers are tested on their own, as the
    // button would, like on the desktop
    ref.listenManual(isStartProvider, (previous, next) {
      _autoTest?.cancel();
      if (previous == false && next) {
        _autoTest = Timer(_autoTestDelay, _testServers);
      }
    });
  }

  void _testServers() {
    if (!mounted) {
      return;
    }
    final group = homeGroupOf(
      ref.read(groupsProvider),
      ref.read(patchClashConfigProvider).mode,
    );
    if (group != null) {
      ref
          .read(proxiesActionProvider.notifier)
          .delayTestPageGroup(group.name, matchSearch: false);
    }
  }

  @override
  void dispose() {
    _autoTest?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    if (profile == null) {
      return const _NoProfiles();
    }
    final group = watchHomeGroup(ref);
    final connection = ConnectionCard(profile: profile);
    final servers = group != null ? ServerList(group: group) : null;
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth < _twoColumnWidth) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(_gap, 20, _gap, _gap),
              children: [
                connection,
                if (servers != null) ...[const SizedBox(height: _gap), servers],
              ],
            );
          }
          Widget column(int flex, Widget child) => Expanded(
            flex: flex,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: _gap),
              child: child,
            ),
          );
          return Padding(
            padding: const EdgeInsets.fromLTRB(_gap, 20, _gap, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: _gap,
              children: [
                column(300, connection),
                if (servers != null) column(340, servers),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NoProfiles extends StatelessWidget {
  const _NoProfiles();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: HomeCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  GlyphIcon(
                    HomeGlyphs.wifiOff,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Text(
                    appLocalizations.homeEmptyTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    appLocalizations.homeEmptyDescription,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => showAddProfilePage(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: AppShape.all(12),
                    ),
                    icon: const GlyphIcon(
                      AppGlyphs.addCircle,
                      size: 20,
                      fill: 1,
                    ),
                    label: Text(appLocalizations.addProfile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
