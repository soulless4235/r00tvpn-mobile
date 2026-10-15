import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/widgets/profile_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'home_card.dart';
import 'home_glyphs.dart';
import 'server_list.dart';

const _expiryWarningDays = 3;
const _sparklineSamples = 30;

/// The desktop home screen's connection card: profile, subscription, status
/// and connected time, the power button, traffic and the routing mode.
class ConnectionCard extends ConsumerWidget {
  const ConnectionCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionInfo = profile.subscriptionInfo;
    return HomeCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          _ProfileHeader(profile: profile),
          if (subscriptionInfo != null)
            _SubscriptionInfo(subscriptionInfo: subscriptionInfo),
          const _Status(),
          const _PowerButton(),
          const _Traffic(),
          const _ModeSwitcher(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: Text(
            profile.realLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (profile.type == ProfileType.url)
          SizedBox.square(
            dimension: 36,
            child: isUpdating
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: context.appLocalizations.update,
                    padding: EdgeInsets.zero,
                    onPressed: () => syncProfile(ref, profile),
                    icon: GlyphIcon(
                      AppGlyphs.sync,
                      size: 18,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
      ],
    );
  }
}

class _SubscriptionInfo extends StatelessWidget {
  const _SubscriptionInfo({required this.subscriptionInfo});

  final SubscriptionInfo subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final total = subscriptionInfo.total;
    final expire = subscriptionInfo.expire;
    final expiresAt = expire > 0
        ? DateTime.fromMillisecondsSinceEpoch(expire * 1000)
        : null;
    final now = DateTime.now();
    final daysRemaining = expiresAt == null
        ? 0
        : max(0, expiresAt.difference(now).inDays);
    final expireDate = expiresAt == null
        ? appLocalizations.homeNever
        : MaterialLocalizations.of(context).formatCompactDate(expiresAt);
    if (expiresAt != null && daysRemaining <= _expiryWarningDays) {
      final expired = expiresAt.isBefore(now);
      return _ExpiryNotice(
        title: expired
            ? appLocalizations.homeSubscriptionExpired
            : daysRemaining == 0
            ? appLocalizations.homeSubscriptionExpiringToday
            : appLocalizations.homeSubscriptionExpiring(daysRemaining),
        hint: expired
            ? appLocalizations.homeSubscriptionExpiredHint
            : appLocalizations.homeSubscriptionExpiringHint(expireDate),
      );
    }
    final used = subscriptionInfo.upload + subscriptionInfo.download;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          spacing: 4,
          children: [
            _Stat(
              label: appLocalizations.homeTrafficRemaining,
              value: total > 0 ? max(0, total - used).traffic.show : '∞',
            ),
            _Stat(
              label: appLocalizations.homeDaysRemaining,
              value: expiresAt != null ? '$daysRemaining' : '∞',
            ),
            _Stat(label: appLocalizations.homeExpires, value: expireDate),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        spacing: 2,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              height: 1.2,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryNotice extends StatelessWidget {
  const _ExpiryNotice({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                spacing: 10,
                children: [
                  GlyphIcon(
                    HomeGlyphs.calendarClock,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                hint,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Status extends ConsumerWidget {
  const _Status();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final isStart = ref.watch(isStartProvider);
    final via = watchHomeViaLabel(ref);
    final statusColor = isStart
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          spacing: 8,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isStart
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            Text(
              isStart
                  ? appLocalizations.homeConnected
                  : appLocalizations.homeDisconnected,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
        Consumer(
          builder: (_, ref, _) {
            final runTime = ref.watch(runTimeProvider);
            return Text(
              getTimeText(isStart ? runTime : null),
              maxLines: 1,
              style: context.textTheme.displaySmall?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isStart
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            );
          },
        ),
        if (via != null)
          Text(
            appLocalizations.homeVia(via),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _PowerButton extends ConsumerWidget {
  const _PowerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final isStart = ref.watch(isStartProvider);
    final foreground = isStart ? colorScheme.onSurface : colorScheme.onPrimary;
    return SizedBox(
      height: 48,
      child: Material(
        color: isStart ? Colors.transparent : colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isStart
              ? BorderSide(color: colorScheme.outlineVariant)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref.read(commonActionProvider.notifier).toggleRunning(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              GlyphIcon(HomeGlyphs.power, size: 16, color: foreground),
              Text(
                isStart
                    ? appLocalizations.homeDisconnect
                    : appLocalizations.homeConnect,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Traffic extends ConsumerWidget {
  const _Traffic();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final total = ref.watch(totalTrafficProvider);
    final style = context.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget amount(Glyph glyph, num value) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        GlyphIcon(glyph, size: 14, color: colorScheme.onSurfaceVariant),
        Text(value.traffic.show, style: style),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            amount(AppGlyphs.arrowUp, total.up),
            amount(AppGlyphs.arrowDown, total.down),
          ],
        ),
        const _TrafficSparkline(),
      ],
    );
  }
}

/// Download speed over the last samples, as bars; flat while disconnected.
class _TrafficSparkline extends ConsumerWidget {
  const _TrafficSparkline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final isStart = ref.watch(isStartProvider);
    final traffics = ref.watch(trafficsProvider).list;
    final samples = [
      for (var i = traffics.length; i < _sparklineSamples; i++) 0.0,
      for (final traffic in traffics.skip(
        max(0, traffics.length - _sparklineSamples),
      ))
        isStart ? traffic.down.toDouble() : 0.0,
    ];
    final peak = max(1.0, samples.fold(0.0, max<double>));
    return ExcludeSemantics(
      child: SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 3,
          children: [
            for (final value in samples)
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: isStart ? max(0.08, value / peak) : 0.08,
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isStart
                          ? colorScheme.primary.withValues(alpha: 0.85)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitcher extends ConsumerWidget {
  const _ModeSwitcher();

  static const _glyphs = {
    Mode.rule: HomeGlyphs.route,
    Mode.global: HomeGlyphs.globe,
    Mode.direct: HomeGlyphs.chevronsRight,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return Semantics(
      label: context.appLocalizations.homeRoutingMode,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              for (final item in Mode.values)
                Expanded(
                  child: _ModeButton(
                    glyph: _glyphs[item]!,
                    label: item.label,
                    selected: item == mode,
                    onTap: () =>
                        ref.read(setupActionProvider.notifier).changeMode(item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Glyph glyph;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = selected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: SizedBox(
            height: 34,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                GlyphIcon(glyph, size: 14, color: color),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
