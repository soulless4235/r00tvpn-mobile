import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'home_card.dart';
import 'home_glyphs.dart';

const _globalGroupName = 'GLOBAL';

bool _isGroup(Proxy proxy) =>
    GroupType.values.any((type) => type.name == proxy.type);

/// A leading flag emoji (two regional indicator symbols), as subscription
/// panels name their nodes; empty when there is none.
String _flagOf(String name) {
  final runes = name.runes.take(2).toList();
  bool isIndicator(int rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF;
  if (runes.length == 2 && runes.every(isIndicator)) {
    return String.fromCharCodes(runes);
  }
  return '';
}

// 🇫🇮 -> "FI"
String _regionOf(String flag) =>
    String.fromCharCodes(flag.runes.map((rune) => rune - 0x1F1E6 + 65));

/// The group the home screen picks a server in, as on the desktop: the first
/// shown group, or GLOBAL in global mode.
Group? watchHomeGroup(WidgetRef ref) {
  final mode = ref.watch(
    patchClashConfigProvider.select((state) => state.mode),
  );
  return ref.watch(
    groupsProvider.select((groups) => homeGroupOf(groups, mode)),
  );
}

Group? homeGroupOf(List<Group> groups, Mode mode) {
  if (mode == Mode.global) {
    final global = groups.getGroup(_globalGroupName);
    if (global != null) {
      return global;
    }
  }
  return groups.firstWhereOrNull((group) => group.hidden == false);
}

/// "Авто · 🇫🇮 VLESS Vision" when the selection is itself a group.
String? watchHomeViaLabel(WidgetRef ref) {
  final group = watchHomeGroup(ref);
  if (group == null) {
    return null;
  }
  final selected = ref.watch(selectedProxyNameProvider(group.name));
  if (selected == null || selected.isEmpty) {
    return null;
  }
  final member = group.all.firstWhereOrNull((proxy) => proxy.name == selected);
  if (member != null && _isGroup(member)) {
    final inner = ref.watch(selectedProxyNameProvider(selected));
    if (inner != null && inner.isNotEmpty) {
      return '$selected · $inner';
    }
  }
  return selected;
}

typedef _Section = ({String key, String title, List<Proxy> items});

/// The desktop home screen's server picker: the main group's members, nodes
/// grouped by country flag.
class ServerList extends ConsumerWidget {
  const ServerList({super.key, required this.group});

  final Group group;

  List<_Section> _sections(AppLocalizations appLocalizations) {
    final groupItems = group.all.where(_isGroup).toList();
    final byFlag = <String, List<Proxy>>{};
    for (final node in group.all.whereNot(_isGroup)) {
      byFlag.putIfAbsent(_flagOf(node.name), () => []).add(node);
    }
    // Prefer the subscription's own country group name, e.g. "🇫🇮 Финляндия"
    String regionTitle(String flag) =>
        groupItems
            .firstWhereOrNull((item) => item.name.startsWith(flag))
            ?.name ??
        '$flag ${_regionOf(flag)}';
    final onlyUnflagged = byFlag.length == 1 && byFlag.containsKey('');
    return [
      if (groupItems.isNotEmpty)
        (
          key: 'groups',
          title: appLocalizations.homeGroupsSection,
          items: groupItems,
        ),
      for (final MapEntry(key: flag, value: items) in byFlag.entries)
        (
          key: flag.isEmpty ? 'other' : flag,
          title: flag.isNotEmpty
              ? regionTitle(flag)
              : onlyUnflagged
              ? appLocalizations.homeNodes
              : appLocalizations.homeOtherNodes,
          items: items,
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final selectable = group.type == GroupType.Selector;
    final selected = ref.watch(selectedProxyNameProvider(group.name));
    final sections = _sections(appLocalizations);
    return HomeCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _Header(group: group),
          if (!selectable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                appLocalizations.homeFixedGroup,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final section in sections)
            Column(
              key: ValueKey(section.key),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 2),
                  child: Text(
                    section.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final member in section.items)
                  _ServerRow(
                    key: ValueKey(member.name),
                    group: group,
                    member: member,
                    label: section.key == 'groups'
                        ? member.name
                        : member.name
                              .substring(_flagOf(member.name).length)
                              .trim()
                              .takeFirstValid([member.name]),
                    selected: member.name == selected,
                    selectable: selectable,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final testing = ref.watch(
      delayTestingGroupsProvider.select((state) => state.contains(group.name)),
    );
    final smallText = context.textTheme.bodySmall?.copyWith(fontSize: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appLocalizations.homeServers,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: smallText?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: testing
                    ? null
                    : () => ref
                          .read(proxiesActionProvider.notifier)
                          .delayTestPageGroup(group.name, matchSearch: false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: AppShape.sm,
                  textStyle: smallText,
                ),
                icon: testing
                    ? const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : GlyphIcon(
                        HomeGlyphs.gauge,
                        size: 14,
                        color: colorScheme.onSurface,
                      ),
                label: Text(appLocalizations.homeTestLatency),
              ),
              TextButton(
                onPressed: () => ref
                    .read(currentPageLabelProvider.notifier)
                    .toPage(PageLabel.proxies),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  shape: AppShape.sm,
                  textStyle: smallText,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(appLocalizations.homeAllGroups),
                    GlyphIcon(
                      AppGlyphs.chevronForward,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServerRow extends ConsumerWidget {
  const _ServerRow({
    super.key,
    required this.group,
    required this.member,
    required this.label,
    required this.selected,
    required this.selectable,
  });

  final Group group;
  final Proxy member;
  final String label;
  final bool selected;
  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final delay = ref.watch(
      delayProvider(proxyName: member.name, testUrl: group.testUrl),
    );
    // A group member shows the node it currently resolves to
    final current = _isGroup(member)
        ? ref.watch(selectedProxyNameProvider(member.name))
        : null;
    final delayText = switch (delay) {
      null => '—',
      <= 0 => appLocalizations.homeNoResponse,
      final ms => appLocalizations.homeLatencyMs(ms),
    };
    return Semantics(
      button: selectable,
      selected: selected,
      child: Material(
        color: selected
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        shape: AppShape.all(12).copyWith(
          side: BorderSide(
            color: selected ? colorScheme.primary : Colors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selectable && !selected
              ? () => ref
                    .read(proxiesActionProvider.notifier)
                    .changeProxy(groupName: group.name, proxyName: member.name)
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (current != null && current.isNotEmpty)
                          Text(
                            current,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    delayText,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: delay == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.delayColor(delay <= 0 ? -1 : delay),
                    ),
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
