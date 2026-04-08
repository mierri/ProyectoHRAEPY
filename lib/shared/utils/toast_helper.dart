import 'package:flutter/material.dart' show IconData;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Shows a centered toast with an icon, title and optional subtitle.
void showCenteredToast(
  BuildContext context, {
  required String title,
  String? subtitle,
  required IconData icon,
  required Color iconColor,
  ToastLocation location = ToastLocation.bottomCenter,
}) {
  showToast(
    context: context,
    location: location,
    builder: (context, overlay) => SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const Gap(10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (subtitle != null) ...[
                    const Gap(2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

