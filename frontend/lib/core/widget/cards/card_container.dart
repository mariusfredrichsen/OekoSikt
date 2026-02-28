import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class CardContainer extends StatelessWidget {
  final Color? color;
  final Widget? title;
  final Widget? body;
  final Widget? footer;
  final List<Widget>? actions;

  const CardContainer({
    super.key,
    this.color,
    this.title,
    this.body,
    this.footer,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (title != null) title!,
            if (body != null) body!,

            if (footer != null || (actions != null && actions!.isNotEmpty))
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (footer != null) footer!,
                  if (actions != null && actions!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: actions!,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
