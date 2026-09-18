import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A reusable app-bar that renders a ← back chevron + "kembali" text button.
///
/// Replaces the copy-pasted GestureDetector + TextButton pattern in
/// [EmptyPage], [SessionOffPage], [GpsInactivePage], and [WebViewPage].
///
/// ```dart
/// appBar: const BackButtonAppBar(),
/// ```
class BackButtonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  const BackButtonAppBar({
    super.key,
    this.label = 'Kembali',
    this.actions = const [],
    this.bottom,
  });

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 150,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.chevron_left, color: Colors.black87, size: 24),
          TextButton(
            onPressed: () {
              if (context.canPop()) context.pop();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
