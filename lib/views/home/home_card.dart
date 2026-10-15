import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// A card of the desktop home screen: card colour, hairline border, 18 corners.
class HomeCard extends StatelessWidget {
  const HomeCard({super.key, required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
